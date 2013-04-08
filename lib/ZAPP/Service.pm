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
	warn "Service args" . Data::Dump->dump($args);
	for my $key (keys $args)  {
		warn "key : $key";
		$self->{$key} = $args->{$key};
	}
	print $self;
	return $self;
}

sub handle {
    my ($self, $req)  = @_;
    warn "-----------------got request------------------\n";
    Data::Dump->dump($req);
    return $self->{svc}->{$req->{svc}}->($self, $req);
}

#
# 通过会计几件和记账原始凭证类型和id查询记账凭证
#
sub jzpz_sel {
    my $self    = shift;
	my $period  = shift;
	my $ys_type = shift;
	my $ys_id	= shift;

    $self->{meta}->[JZPZ]->[JZPZ_SEL]->execute($period, $ys_type, $ys_id);
    return \$self->{meta}->[JZPZ]->[JZPZ_SEL]->fetchrow_array();
}

1;
