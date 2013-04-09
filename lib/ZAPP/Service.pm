package ZAPP::Service;
use strict;
use warnings;
use base qw/Zark/;
use Zark::Constant;
use constant {
	DEBUG => $ENV{ZAPP_DEBUG} || 0,
};

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

1;
