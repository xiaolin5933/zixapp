#！perl
use Test::More;
use Zeta::Run;
use ZAPP::DT;
use DateTime;
plan tests  => 4;

my $cfg = do "$ENV{ZIXAPP_HOME}/conf/zixapp.conf";
my $cfg->{dbh} = zkernel->zdbh();
my $zdt = ZAPP::DT->new($cfg);
$cfg->{dbh}->rollback();
$cfg->{dbh}->disconnect();

ok $zdt->next_n_wday('2012-12-30',  10)  eq  '2013-01-13';
ok $zdt->next_n_wday('2012-12-30',  11)  eq  '2013-01-14';
ok $zdt->next_n_wday('2012-12-30',  12)  eq  '2013-01-15';
ok $zdt->is_wday('2013-01-01');

done_testing();

__END__

ok $zdt->next_n_wday(DateTime->new(time_zone => 'local', year => 2012, month => 12, day => 30), 10)->ymd('-')    eq  '2013-01-14';
ok $zdt->next_n_wday(DateTime->new(time_zone => 'local', year => 2012, month => 12, day => 30), 11)->ymd('-')    eq  '2013-01-15';
ok $zdt->next_n_wday(DateTime->new(time_zone => 'local', year => 2012, month => 12, day => 30), 12)->ymd('-')    eq  '2013-01-16';


