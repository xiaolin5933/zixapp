#！perl
use Test::More;
use Zeta::Run;
use ZAPP::DT;
use DateTime;


plan tests => 8;

my $cfg = do "$ENV{ZIXAPP_HOME}/conf/zixapp.conf";
my $cfg->{dbh} = zkernel->zapp_dbh();
my $zdt = ZAPP::DT->new($cfg);
$cfg->{dbh}->rollback();
$cfg->{dbh}->disconnect();



ok $zdt->week_last('2013-09-30')  eq '2013-10-06';
ok $zdt->week_last('2013-10-01')  eq '2013-10-06';
ok $zdt->week_last('2013-10-02')  eq '2013-10-06';
ok $zdt->week_last('2013-10-03')  eq '2013-10-06';
ok $zdt->week_last('2013-10-04')  eq '2013-10-06';
ok $zdt->week_last('2013-10-05')  eq '2013-10-06';
ok $zdt->week_last('2013-10-06')  eq '2013-10-06';
ok $zdt->week_last('2013-10-07')  eq '2013-10-13';


done_testing();
