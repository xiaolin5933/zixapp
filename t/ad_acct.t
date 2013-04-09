#!/usr/bin/perl

use Data::Dump;
use Zark;
use Zark::Proc;

#my $p = Zark->new(dbh => Zark->dbh());
my $p = Zark::Proc->new(dbh => Zark->dbh());

my $src = 
{
    _type => "0000",
    data  => {
               cause    => "cin",
               jd_books => {
                             "0" => {
                                      d_book => { _type => 22, bfj_acct => 1, d => 10000, zjbd_date => '2013-04-09', zjbd_type => 1 },
                                      j_book => { _type => 14, bfj_acct => 1, j => 10000 },
                                    },
                           },
               period   => "2013-04-09",
             },
    sys   => { oper_user => 1 },
};

$p->handle($src);

print Data::Dump->dump($p);

