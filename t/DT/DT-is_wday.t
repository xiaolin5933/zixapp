#！perl
use Test::More;
use Zeta::Run;
use ZAPP::DT;
use DateTime;

plan tests => 8;

do "$ENV{ZIXAPP_HOME}/libexec/plugin.pl";
my $dbh = zkernel->zapp_dbh();
my $zdt = ZAPP::DT->new( dbh => $dbh );

ok !$zdt->is_wday('2013-10-01');
ok !$zdt->is_wday('2013-10-02');
ok !$zdt->is_wday('2013-10-03');
ok !$zdt->is_wday('2013-10-04');
ok !$zdt->is_wday('2013-10-05');
ok !$zdt->is_wday('2013-10-06');
ok !$zdt->is_wday('2013-10-07');
ok $zdt->is_wday('2013-10-08');

done_testing();
