#!perl
use Test::More;
use Test::Differences::Color;
use ZAPP::PROC::Test;

my $t = ZAPP::PROC::Test->new();

plan tests => 3;

eq_or_diff( [ [ 1, 2 ], [1, 3 ] ], [ [ 1, 2 ], [1, 3 ] ] );  

$t->execute(
   '0001',    # type

   # 原始凭证数据
   { 
       _type => '0001',
   }, 

   # 期望值
   {
       bamt_yhyf => [ 
           [ '1', '1', '1', '2012-04-24', '2012-04-24', '100', '100', '1', '2', '1' ],
       ],
       bfee_yhyf => [ 
           [ '1', '1', '1', '2012-04-24', '2012-04-24', '100', '100', '1', '2', '1' ],
       ],
   },

   # 名称
   'kkkk',
);

$t->execute(
   '0001', 
   { 
       _type => '0001',
   }, 
   {
       bamt_yhyf => [ 
           [ '1', '1', '1', '2012-04-24', '2012-04-24', '100', '100', 1, 2, 1 ],
       ],
       bfee_yhyf => [ 
           [ '1', '1', '1', '2012-04-24', '2012-04-24', '100', '100', 1, 2, 1 ],
       ],
   },
   'kkkk',
);

$t->teardown();

done_testing();

