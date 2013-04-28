#！perl
use Test::More;
use Zeta::Run;
use ZAPP::DT;
use DateTime;


plan tests => 16;

my $cfg = do "$ENV{ZIXAPP_HOME}/conf/zixapp.conf";
my $cfg->{dbh} = zkernel->zapp_dbh();
my $zdt = ZAPP::DT->new($cfg);
$cfg->{dbh}->rollback();
$cfg->{dbh}->disconnect();


ok $zdt->semi_year_last('2013-02-28')  eq '2013-06-30';
ok $zdt->semi_year_last('2013-03-28')  eq '2013-06-30';
ok $zdt->semi_year_last('2013-04-28')  eq '2013-06-30';
ok $zdt->semi_year_last('2013-05-29')  eq '2013-06-30';

ok $zdt->semi_year_last('2013-07-02')  eq '2013-12-31';
ok $zdt->semi_year_last('2013-08-01')  eq '2013-12-31';
ok $zdt->semi_year_last('2013-10-03')  eq '2013-12-31';
ok $zdt->semi_year_last('2013-11-04')  eq '2013-12-31';

ok $zdt->semi_year_last('2012-02-29')  eq '2012-06-30';
ok $zdt->semi_year_last('2012-03-28')  eq '2012-06-30';
ok $zdt->semi_year_last('2012-04-28')  eq '2012-06-30';
ok $zdt->semi_year_last('2012-05-29')  eq '2012-06-30';

ok $zdt->semi_year_last('2012-07-02')  eq '2012-12-31';
ok $zdt->semi_year_last('2012-08-01')  eq '2012-12-31';
ok $zdt->semi_year_last('2012-10-03')  eq '2012-12-31';
ok $zdt->semi_year_last('2012-11-04')  eq '2012-12-31';

done_testing();
