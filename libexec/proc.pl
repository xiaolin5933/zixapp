#!/usr/bin/perl
use strict;
use warnings;
use Zeta::Run;
use Net::Stomp;
use DBI;
use Carp;

use constant {
    DEBUG => $ENV{ZAPP_DEBUG} || 0,
};

BEGIN {
    require Data::Dump if DEBUG;
}

sub {
 
    # 获取配置
    my $cfg = zkernel->zconfig();
    $cfg->{dbh} = zkernel->zdbh();
   
    # zark重置 
    my $zark = $cfg->{zark};
    $zark->setup($cfg->{dbh});

    # 构建stomp客户端
    my $stp = zkernel->zstomp();

    # 订阅
    $stp->subscribe(
        {   
            'destination'           => $cfg->{stomp}->{queue}->{proc},
            'ack'                   => 'client',
            'activemq.prefetchSize' => 1,
        }
    ) or confess "can not subscribe to $cfg->{stomp}->{queue}->{proc}";

    # 序列化工具对象
    my $ser = $cfg->{serializer};

    # 开始loop: 接收原始凭证， 处理原始凭证
    while (1) {

         my $frame = $stp->receive_frame;
         zlogger->debug("recv frame:\n" . Data::Dump->dump($frame)) if DEBUG;

         # 反序列化获取原始配置
         my $src = $ser->deserialize($frame->body);  
         unless($src) {
             zlogger->error("can not deserialize src[" . $frame->body . "]");
             $stp->ack( { frame => $frame } );
             next;
         }
         zlogger->debug("recv src:\n" . Data::Dump->dump($src)) if DEBUG;

         # 凭证处理
         my $source;
         unless($source = $zark->handle($src)) {
             zlogger->error("can not handle src[" . $src . "]");
             $stp->ack( { frame => $frame } );
             next;
         }
         # 设置凭证处理状态为成功 1
         $zark->yspz_upd($source->{_type}, '1', $source->{period}, $source->{id});
         $zark->commit;

         $stp->ack( { frame => $frame } );
    }
};

__END__





