package ZAPP::YSPZ::Load;
use strict;
use warnings;
use Zark::Constant;
use Zark;

use ZAPP::BIP::Config;

use constant {
    DEBUG              => $ENV{ZAPP_YSPZ_LOAD_DEBUG} || 0, # 测试: 
    COMMIT_BATCH_SIZE  => 100,  # 数据库提交批次大小
};

BEGIN {
    require Data::Dump if DEBUG;
}

#
# 参数:
# (
#     dbh   => $dbh,
#     zark  => $zark,
#     bip   => $bip,
#     batch => $batch_size,
#     load  => \%load,    # 导入凭证配置
# )
#
# 对象结构:
# (
#     dbh    => $dbh,
#     zark   => $zark,
#     batch  => $batch_size,
#     config => $config,
#     load   => \%load,
# )
#
sub new {
    my $self   = bless { }, shift;
    my $args   = { @_ };

    $self->{dbh}    = $args->{dbh};
    $self->{zark}   = $args->{zark};
    $self->{batch}  = $args->{batch};
    $self->{config} = $args->{bip};
    $self->{load}   = $args->{load};
    return $self;
}

#
#  $file   : 待处理文件
#  $type   : 文件类型
#
sub handle {
    my ($self, $file, $type) = @_;

    # 打开文件
    my $fh = IO::File->new("<$file");
    unless ($fh) {
        warn "can not open file[$file]";
        return;
    }

    my $rotation = 0;   # 当前批次  
    my $size = 0;       # 当前批次第几条
    my $line = -1;      # 当前行
    while(<$fh>) {
        ++$line;

        s/^\s+|\s+$//;

        # 生成原始凭证
        my $yspz = $self->{load}->{$type}->($self, $_);  
        unless($yspz) {
            warn sprintf("非法数据行: file[$file] line[%06d] batch[%010d] index[%03d]", $line, $rotation, $size);
            next;
        }

        # db
        eval { 
            # 插入原始凭证(处理成功)
            $yspz->{id} = $self->{zark}->yspz_ins( $yspz->{_type}, @{$yspz}{@{ $self->{zark}->{meta}->[YSPZ]->{$yspz->{_type}}->[YSPZ_FLIST] }} );

            # 处理原始凭证, 登记账簿
            $self->{zark}->handle($yspz);
    
            # 更新原始凭证处理状态
            $self->{zark}->yspz_upd($yspz->{_type}, '1', $yspz->{period}, $yspz->{id});

        };
        if ($@) {
            warn sprintf("不能处理原始凭证: file[$file] line[%06d] batch[%010d] index[%03d] errmsg[$@]", $line, $rotation, $size);
            $self->{dbh}->rollback();

            # 重置批次:
            $size = 0;
            ++$rotation;
            next;
        }


        ++$size;

        # 批次完成， 提交批次
        if ($size == $self->{batch}) {
            warn sprintf("开始提交第[%010d]批, 批大小[%03d], file[$file] line[%06d]", $rotation, $self->{batch}, $line);
            unless($self->{dbh}->commit()) {
                my $errmsg = sprintf("批提交失败，批次号[%010d],批大小[%03d], file[$file] line[%06d]", $rotation, $self->{batch}, $line);
                warn $errmsg;
                confess $errmsg;
            }
            ++$rotation;
            $size = 0;
        }

    }
 
    # 最后一个批次
    if ( $size ) {
        warn sprintf("开始提交第[%010d]批, 批大小[%03d], file[$file] line[%06d] -- 最后一批", $rotation, $size, $line);
        unless ($self->{dbh}->commit()) {
            my $errmsg = sprintf("批提交失败，批次号[%010d],批大小[%03d], file[$file] line[%06d]", $rotation, $self->{batch}, $line);
            warn $errmsg;
            confess $errmsg;
        }
    }
    return $self;
}

1;

__END__

