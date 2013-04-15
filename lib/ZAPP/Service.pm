package ZAPP::Service;
use strict;
use warnings;
use base qw/Zark/;
use Zark::Constant;
use ZAPP::BIP::Config;
use constant {
	DEBUG => $ENV{ZAPP_DEBUG} || 0,
};

BEGIN {
    require Data::Dump if DEBUG;
}

#
# $dbh,    
# {
#   stomp       => $args->{stomp},
#   serrializer => $args->{serializer},
#   svc         => { xxx => sub { ... }, }
# }
#
sub _init {
    my $self = shift;
    my $args = { @_ };
    for my $key (keys $args)  {
        $self->{$key} = $args->{$key};
    }
    # Config(计费模块) 对象，只有一个 (可以计算银行手续费，划付等)
    $self->{bip_cfg} = ZAPP::BIP::Config->new( dbh => $self->{dbh} );
    return $self;
}

sub handle {
    my ($self, $req)  = @_;
    warn "-----------------got request------------------\n";
    Data::Dump->dump($req);
    return $self->{svc}->{$req->{svc}}->($self, $req);
}


################################################################
# interface 外部接口
###############################################################
#

#
# 获取账薄元数据中的核算项字段列表
#
sub book_flist {
    my $self = shift;
    my $bid  = shift;
    my $name = $self->{meta}->[DICT]->[DICT_BOOK]->{$bid}->{value};
    return $self->{meta}->[BOOK]->{$name}->[BOOK_FLIST];
}

#
# 获取原始凭证元数据中的核算项字段列表
#
sub yspz_flist {
    my $self  = shift;
    my $name  = shift;
    return $self->{meta}->[YSPZ]->{$name}->[YSPZ_FLIST];
}

#
# 获取所有的核算项信息
#
sub dims {
    my $self = shift;
    return $self->{meta}[DIM];
}

1;
