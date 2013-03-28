#!perl

use Carp;
use DBI;
use Data::Dump;

$dsn    = 'dbi:DB2:zdb_dev';
$user   = 'ypinst';
$pass   = 'ypinst';
$schema = 'ypinst';

# 连接数据库
my $dbh = DBI->connect(
    $dsn,
    $user,
    $pass,
    {
        RaiseError       => 1,
        PrintError       => 0,
        AutoCommit       => 0,
        FetchHashKeyName => 'NAME_lc',
        ChopBlanks       => 1,
    }
);
unless($dbh) {
    zlogger->error("can not connet db[@{$cfg->{db}}{qw/dsn user pass/}], quit");
    exit 0;
}
# 设置默认schema
$dbh->do("set current schema $schema") or confess "can not set current schema $schema";

use ZAPP::BIP::Config;

my $config = ZAPP::BIP::Config->new( dbh => $dbh);
# my $bi = $config->bip(10);
# Data::Dump->dump($bi);
# Data::Dump->dump($config->{dept_bi});
Data::Dump->dump($config);

   
