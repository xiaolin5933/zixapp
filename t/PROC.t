#!perl
use Test::More;
use Test::Differences::Color;
use ZAPP::PROC::Test;
use ZAPP::PROC;

plan tests => 2;

my $dbh = ZAPP::PROC::Test->dbh();
my $sub = do "$ENV{ZIXAPP_HOME}/conf/proc/0001.proc";
my $proc = ZAPP::PROC->new(
    dbh  => $dbh,
    proc => $sub,
);

ok  0;
ok  $proc->jzpz_id();

done_testing();

