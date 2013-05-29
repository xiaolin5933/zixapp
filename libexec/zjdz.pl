#!/usr/bin/perl
use strict;
use warnings;
use Carp;
use Getopt::Long;
use DBI;
use DateTime;
use constant {
    DEBUG   => $ENV{ZAPP_DEBUG} || 0,
    SEQ     => 0,
    INS     => 1,
};


BEGIN {
    require Data::Dump if DEBUG;
}

my $date;
my $rtn = GetOptions(
    "d|data=s"  => \$date,
) or &usage;

unless ($date) {
    my $dt = DateTime->now('time_zone' => 'local');
    $date = $dt->ymd('');
}

unless ($date =~ /(\d{4})(\d{2})(\d{2})/) {
    &usage;
}
$date = $1 . '-' . $2 . '-' . $3;

my $ret = &gen_job($date);
if ($ret == 1) {
    warn "生成对账任务成功" if DEBUG;
}
else {
    warn "生成对账任务失败" if DEBUG;
}


sub gen_job {
    my $date = shift;

    my $dbh  = &dbh();
    my $sths = &setup($dbh);

    my $accts = $dbh->selectall_arrayref(q/select * from dim_acct/, { Slice => {} }); 
    for my $hs_acct (@$accts) {
        $sths->[SEQ]->execute();
        my ($id) = $sths->[SEQ]->fetchrow_array();
        $sths->[SEQ]->finish();
        $sths->[INS]->execute($id, $date, $hs_acct->{sub_type}, $hs_acct->{sub_id}, 1); 
    }
    $dbh->commit();

    return 1;
}

sub setup {
    my $dbh  = shift;

    my $seq_sql = qq/values nextval for seq_job_dz/;

    my $ins_sql = qq/insert into job_dz(id, zjdz_date, type, b_acct, status) values(?, ?, ?, ?, ?)/;

    my $sth_seq = $dbh->prepare($seq_sql); 
    my $sth_ins = $dbh->prepare($ins_sql);

    my @sths;
    $sths[SEQ] = $sth_seq;
    $sths[INS] = $sth_ins;

    return \@sths;
}

sub dbh {
    my $dbh       = DBI->connect(
        "dbi:DB2:$ENV{DB_NAME}",
        $ENV{DB_USER},
        $ENV{DB_PASS},
        {
            RaiseError          => 1,
            PrintError          => 0,
            AutoCommit          => 0,
            FetchHashKeyName    => 'NAME_lc',
            ChopBlanks          => 1,
            InactiveDestroy     => 1,
        }
    );
    $dbh->do("set current schema $ENV{DB_SCHEMA}");
    unless ($dbh) {
        confess "can not connect db[$ENV{DB_NAME}, $ENV{DB_USER}, $ENV{DB_PASS}]";
    }

    return $dbh;
}


sub usage {
    die <<EOF;
usage: 
    zjdz.pl -d 20130528        
EOF
}
