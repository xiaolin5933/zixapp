#!perl
use Test::More;
use DBI;
use DateTime;
use ZAPP::DT;


my $dt = DateTime->now( time_zone => 'local');
my $first = DateTime->new(
             year       => '2013',
             month      => 1,
             day        => 1,
             hour       => 1,
             minute     => 1,
             second     => 1,
             nanosecond => 500000000,
             time_zone  => 'local',
         );


# 连接数据库
my $dbh = DBI->connect(
    "dbi:DB2:$ENV{DB_NAME}",
    $ENV{DB_USER},
    $ENV{DB_PASS},
    {
        RaiseError => 1,
        AutoCommit => 0,
        FetchHashKeyName => 'NAME_lc',
        ChopBlanks       => 1,
    },
);
$dbh->do("set current schema $ENV{DB_SCHEMA}");

my $zdt = ZAPP::DT->new(dbh => $dbh);

# Data::Dump->dump($zdt);
plan tests => 2;
ok $first->day_of_year() == 1;
ok $zdt;

warn $zdt->next_n_wday('2012-01-01', 1), "\n";
warn $zdt->next_n_wday('2012-01-01', 2), "\n";
warn $zdt->next_n_wday('2012-01-01', 3), "\n";
warn $zdt->next_n_wday('2012-01-01', 4), "\n";
warn $zdt->next_n_wday('2012-01-01', 5), "\n";
warn $zdt->next_n_wday('2012-01-01', 6), "\n";
warn $zdt->next_n_wday('2012-01-01', 7), "\n";
warn $zdt->next_n_wday('2012-01-01', 8), "\n";

warn "--------------------\n";
warn $zdt->next_n_wday('2013-01-01', -1), "\n";
warn $zdt->next_n_wday('2013-01-01', -2), "\n";
warn $zdt->next_n_wday('2013-01-01', -3), "\n";
warn $zdt->next_n_wday('2013-01-01', -4), "\n";
warn $zdt->next_n_wday('2013-01-01', -5), "\n";
warn $zdt->next_n_wday('2013-01-01', -6), "\n";
warn $zdt->next_n_wday('2013-01-01', -200), "\n";
# warn $zdt->next_n_wday('2013-01-01', -300), "\n";
warn "--------------------\n";
warn "week last for[2013-04-10] is " .  $zdt->week_last('2013-04-10'), "\n";
warn "week last for[2013-04-11] is " .  $zdt->week_last('2013-04-11'), "\n";
warn "week last for[2013-04-12] is " .  $zdt->week_last('2013-04-12'), "\n";

warn "--------------------\n";
warn "month last for[2013-04-10] is " .  $zdt->month_last('2013-04-10'), "\n";
warn "month last for[2013-04-11] is " .  $zdt->month_last('2013-04-11'), "\n";
warn "month last for[2013-04-12] is " .  $zdt->month_last('2013-04-12'), "\n";

warn "--------------------\n";
warn "quarter last for[2013-01-10] is " .  $zdt->quarter_last('2013-01-10'), "\n";
warn "quarter last for[2013-03-11] is " .  $zdt->quarter_last('2013-03-11'), "\n";
warn "quarter last for[2013-07-12] is " .  $zdt->quarter_last('2013-07-12'), "\n";

warn "--------------------\n";
warn "semi_year last for[2013-04-10] is " .  $zdt->semi_year_last('2013-04-10'), "\n";
warn "semi_year last for[2013-04-11] is " .  $zdt->semi_year_last('2013-04-11'), "\n";
warn "semi_year last for[2013-04-12] is " .  $zdt->semi_year_last('2013-04-12'), "\n";
warn "semi_year last for[2013-07-10] is " .  $zdt->semi_year_last('2013-07-10'), "\n";
warn "semi_year last for[2013-07-11] is " .  $zdt->semi_year_last('2013-07-11'), "\n";
warn "semi_year last for[2013-07-12] is " .  $zdt->semi_year_last('2013-07-12'), "\n";

warn "--------------------\n";
warn "year last for[2013-04-10] is " .  $zdt->year_last('2013-04-10'), "\n";
warn "year last for[2013-04-11] is " .  $zdt->year_last('2013-04-11'), "\n";
my $dt = DateTime->new( time_zone => 'local', year => '2013', month => 4, day => 11);
warn "year last for[2013-04-11] is " .  $zdt->year_last_dt($dt)->ymd('-'), "\n";

