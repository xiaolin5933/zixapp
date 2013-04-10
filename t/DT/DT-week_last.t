#！perl
use Test::More;
use Zeta::Run;
use ZAPP::DT;
use DateTime;


plan tests => 8;

do "$ENV{ZIXAPP_HOME}/libexec/plugin.pl";
my $dbh = zkernel->zapp_dbh();
my $zdt = ZAPP::DT->new( dbh => $dbh );


ok $zdt->week_last('2013-09-30')  eq '2013-10-06';
ok $zdt->week_last('2013-10-01')  eq '2013-10-06';
ok $zdt->week_last('2013-10-02')  eq '2013-10-06';
ok $zdt->week_last('2013-10-03')  eq '2013-10-06';
ok $zdt->week_last('2013-10-04')  eq '2013-10-06';
ok $zdt->week_last('2013-10-05')  eq '2013-10-06';
ok $zdt->week_last('2013-10-06')  eq '2013-10-06';
ok $zdt->week_last('2013-10-07')  eq '2013-10-13';


done_testing();
