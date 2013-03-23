package ZAPP::PROC;
use strict;
use warnings;
use Data::Dump;

#
#  @para = (
#     dbh  => $dbh,
#     proc => {
#         0001  => sub { ... },
#     }
#  );
#-----------------------------------------------------------------
# 动态添加的功能:
# $proc->jzpz_id()                   : 返回id
# $proc->jzpz($f1, $f2, $f3, ....)   : 插入记账凭证
# $proc->bamt_yhyf($f1, $f2,...)     : 插入账簿记录， 返回j_id or d_id
# $proc->yspz_0000($ys_id, $pstat)   : 更新原始凭证状态
#
sub new {

    my $class = shift;
    my $self  = bless { @_ }, $class;
    unless( $self->{dbh} && $self->{proc} ) {
        return;
    }

    # 产生所有账簿插入语句
    my $book = $self->{dbh}->selectcol_arrayref(qq/select value from dict_book/);
    Data::Dump->dump($book);
    $self->_book_insert($_) for @$book;

    # 产生所有原始配置更新语句
    my $yspz = $self->{dbh}->selectcol_arrayref(qq/select code from dict_yspz/);
    Data::Dump->dump($yspz);
    $self->_yspz_update($_) for @$yspz;

    # 记账凭证id生成语句
    $self->_jzpz_id();

    # 记账凭证插入语句
    $self->_jzpz_insert();

    return $self;
}

#
# 记账配置id
#
sub jzpz_id {
    my $self = shift; 
    $self->{jzpz_id}->execute();
    my ($id) = $self->{jzpz_id}->fetchrow_array();
    return $id;
}

#
# 插入记账凭证
#
sub jzpz {
    my $self = shift;
    $self->{jzpz}->execute(@_);
}

#
# 提交
#
sub commit {
    my $self = shift;
    $self->{dbh}->commit(); 
}

#
# 处理
#
sub handle {
    my ($self, $src) = @_;
    my $proc = $self->{proc}->{$src->{_type}};
    return unless $proc;
    $proc->($self, $src) or return;
}

#
sub _book_fld {

    my ($self, $name) = @_;

    # 取得nhash
    my $sql_nhash = "select * from book_$name";
    warn "sql_nhash[$sql_nhash]" if $ENV{ZAPP_DEBUG};
    my $sth_nhash = $self->{dbh}->prepare("select * from book_$name") or return;
    my %nhash = %{$sth_nhash->{NAME_hash}};
    warn "nhash:\n" .  Data::Dump->dump(\%nhash) if $ENV{ZAPP_DEBUG};
    delete $nhash{TS_C};
    $sth_nhash->finish();

    # @key && @val
    %nhash = reverse %nhash;
    my @idx = sort keys %nhash;
    return [ @nhash{@idx} ];
}

# 账簿出入语句生成
sub _book_insert {

    my ($self, $name) = @_;

    # 获取域名
    my $fld = $self->_book_fld($name);
    my $fstr  = join ', ', @$fld;
    my $mark  = join ', ', ('?') x @$fld;

    # 产生insert sth
    my $sql_ins = "insert into book_$name($fstr, TS_C) values ($mark, current timestamp)";
    warn "sql_ins[$sql_ins]" if $ENV{ZAPP_DEBUG};
    my $sth_ins = $self->{dbh}->prepare($sql_ins) or return;

    # 产生 seq sth
    my $sql_seq = "values nextval for seq_$name";
    warn "sql_seq[$sql_seq]" if $ENV{ZAPP_DEBUG};
    my $sth_seq = $self->{dbh}->prepare($sql_seq) or return;

    # 保存sth_seq, sth_ins
    $self->{book}->{$name} = [ $sth_seq, $sth_ins ];

    # 产生账簿插入函数
    no strict 'refs';
    *{__PACKAGE__ . "::$name"} = sub {
        my $self = shift;

        # 获取id
        $self->{book}->{$name}->[0]->execute();
        my ($id) = $self->{book}->{$name}->[0]->fetchrow_array();
 
        # 插入记录
        warn "execute with[$id @_]";
        $self->{book}->{$name}->[1]->execute($id, @_);
 
        # 返回id
        return $id;
   };
}


# 原始凭证更新语句生成
sub _yspz_update {

    my ($self, $name) = @_;

    # 准备yspz更新的sth
    my $sql = qq/update yspz_$name set pstat = ? where id = ?/;
    $self->{yspz}->{$name} = $self->{dbh}->prepare($sql) or return;

    no strict 'refs';
    *{ __PACKAGE__ . "::yspz_$name" } = sub {
        my ($self, $id, $pstat) = @_;
        $self->{yspz}->{$name}->execute($pstat, $id);
        return $self;
    };
}

# 产生记账配置插入语句
sub _jzpz_insert {
    my $self = shift;
    $self->{jzpz}  = $self->{dbh}->prepare(
         qq/insert into jzpz(id, j_id, j_book, d_id, d_book, ys_type, ys_id, ts_c) values(?,?,?,?,?,?,?,current timestamp)/
    ) or return;

    return $self;
}

# 记账凭证: id生产语句
sub _jzpz_id {
    my $self = shift;
    # 记账凭证: id成， jzpz插入
    $self->{jzpz_id} = $self->{dbh}->prepare(qq/values nextval for seq_jzpz/) or return;

    return $self;
}



1;

__END__

