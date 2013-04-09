#!perl
use Data::Dump;
use Zark;
use ZAPP::Service;


my $svc = ZAPP::Service->new(
    dbh     => Zark->dbh(),
    proc    => {}
);

my $proc    = do "$ENV{ZIXAPP_HOME}/conf/svc/revoke.svc";



#
# 撤销原始凭证
#



#
# $svc对象:  {
#     dbh        => $dbh
#     stomp      => $stomp,
#     serializer => $ser,
#     service    => $svc, 
# }
#--------------------------------------
# req:  {
#     data => {
#         revoke_cause => "",
#         rk_user      => 1,
#         ys_id        => 1,
#         ys_type      => "0001",
#         period       => '2013-04-06'
#     },
#     svc  => "revoke",
#     sys  => { oper_user => 1 },
# }
#
# res:  {
#     status => 0,  # 0 成功, 其他失败
#     errmsg => '',
#     ret    => ''
# }
#



my $req =
{
    data => {
        revoke_cause => "caining",
        rk_user      => 1,
        ys_id        => 1503,
        ys_type      => "0000",
        period       => '2013-04-09'
    },
    svc  => "revoke",
    sys  => { oper_user => 1 },
};


ZAPP::Service->revoke($svc, $req);


1;

   

