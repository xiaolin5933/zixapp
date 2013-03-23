package ZAPP::PROC::Test;
use strict;
use warnings;
use DBI;
use Test::Differences;
use ZAPP::PROC;
use Carp;

#
# ZAPP::PROC::Test->new();
#
sub new {

    my $class = shift;
    
    # 连接数据库, 设置默认schema
    my $dbh = DBI->connect(
        "dbi:DB2:$ENV{DB_NAME}",
        @ENV{qw/DB_USER DB_PASS/},
        {
            RaiseError       => 1,
            PrintError       => 0,
            AutoCommit       => 0,
            FetchHashKeyName => 'NAME_lc',
            ChopBlanks       => 1,
        }
    );
    unless($dbh) {
        zlogger->error("can not connet db[@ENV{qw/DB_ANME DB_USER DB_PASS/}]");
        exit 0;
    }
    $dbh->do("set current schema $ENV{DB_SCHEMA}") or confess "can not set current schema $ENV{DB_SCHEMA}";

    # 找出所有book 
    my $books = $dbh->selectcol_arrayref(qq/select value from dict_book/);
    my %book_sth;
    for my $name (@$books) {

        # 取得@fld
        my $sql_nhash = "select * from book_$name";
        my $sth_nhash = $dbh->prepare("select * from book_$name") or return;
        my %nhash = %{$sth_nhash->{NAME_hash}};
        delete $nhash{TS_C};
        $sth_nhash->finish();
        %nhash = reverse %nhash;
        my @idx = sort keys %nhash;
        my @fld = @nhash{@idx};

        my $sth_sel = $dbh->prepare("select " . join(', ', @fld) . " from book_$name order by id");
        my $sth_del = $dbh->prepare("delete from book_$name where id < 99999999999");
        $book_sth{$name} = [ $sth_sel, $sth_del ];
    }

    # 找出所有book 
    my %yspz_sth;
    my $yspz = $dbh->selectcol_arrayref(qq/select code from dict_yspz/);
    for (@$yspz) {
    } 

    my $self = bless { 
        dbh  => $dbh, 
        book => \%book_sth,
    }, $class;

}

#
#  $test->execute( 
#     '0001',
#     { },
#     {
#        bamt_yhyf => [],
#        bfee_yhyf => [],
#     },
#     'test name',
#  }
#
sub execute {

    my ($self, $yspz, $src, $exp, $name) = @_;
    my $dbh  = $self->{dbh};
    my $book = $self->{book};

    # 清理数据库
    my @book = keys %$exp;
    for (@book) {
        $dbh->do("alter sequence seq_$_ restart with 1");
        $book->{$_}->[1]->execute();
    }
    $dbh->do("alter sequence seq_jzpz restart with 1");
    $dbh->commit();

    # 构建proc对象 
    my $file = "$ENV{ZIXAPP_HOME}/conf/proc/$yspz.proc";
    unless(-f $file) {
        die "$file does not exists";
    }
    my $sub  = do $file  or die "can not do file[$file] error[$@]";
    my %proc = ( $yspz => $sub );
    my $proc = ZAPP::PROC->new( dbh => $dbh, proc => \%proc);

    # 处理凭证
    $proc->handle($src);

    # 查询数据库, 获取result
    my %result;
    for (keys %$exp) {
        $result{$_} = $dbh->selectall_arrayref($book->{$_}->[0]);
    }

    # 比较%result 与 $exp
    eq_or_diff(\%result, $exp, $name);
}

#
#
#
sub teardown {

    my $self = shift; 
    $self->{dbh}->rollback();
    for ( keys %{$self->{book}}) {
        $self->{book}->{$_}->[0]->finish();
        $self->{book}->{$_}->[1]->finish();
    }
    $self->{dbh}->disconnect();
}

1;

__END__

