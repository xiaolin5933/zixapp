#！perl
use Test::More;
use Zeta::Run;
use ZAPP::DT;
use DateTime;


plan tests => 20;

my $cfg = do "$ENV{ZIXAPP_HOME}/conf/zixapp.conf";
my $cfg->{dbh} = zkernel->zdbh();
my $zdt = ZAPP::DT->new($cfg);
$cfg->{dbh}->rollback();
$cfg->{dbh}->disconnect();



ok $zdt->month_last('2013-09-27')  eq '2013-09-30';
ok $zdt->month_last('2013-09-28')  eq '2013-09-30';
ok $zdt->month_last('2013-09-29')  eq '2013-09-30';
ok $zdt->month_last('2013-09-30')  eq '2013-09-30';
ok $zdt->month_last('2013-10-01')  eq '2013-10-31';
ok $zdt->month_last('2013-10-02')  eq '2013-10-31';
ok $zdt->month_last('2013-10-03')  eq '2013-10-31';
ok $zdt->month_last('2013-10-04')  eq '2013-10-31';
ok $zdt->month_last('2013-02-02')  eq '2013-02-28';
ok $zdt->month_last('2013-02-01')  eq '2013-02-28';


ok $zdt->month_last('2012-02-27')  eq '2012-02-29';
ok $zdt->month_last('2012-02-27')  eq '2012-02-29';
ok $zdt->month_last('2012-09-27')  eq '2012-09-30';
ok $zdt->month_last('2012-09-28')  eq '2012-09-30';
ok $zdt->month_last('2012-09-29')  eq '2012-09-30';
ok $zdt->month_last('2012-09-30')  eq '2012-09-30';
ok $zdt->month_last('2012-10-01')  eq '2012-10-31';
ok $zdt->month_last('2012-10-02')  eq '2012-10-31';
ok $zdt->month_last('2012-10-03')  eq '2012-10-31';
ok $zdt->month_last('2012-10-04')  eq '2012-10-31';
done_testing();
