#!perl
use Test::More tests => 88;
use Test::Fatal;
use lib ('D:\GitHub\database-accessor\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\t\lib');
use Data::Dumper;
use Database::Accessor;
use Test::Deep;
use Test::Utils;
my $utils   = Test::Utils->new();

# SELECT ProductName,
       # CASE WHEN Price < 10 THEN 'under 10$'
            # WHEN Price >=10 AND Price <= 30 THEN '10~30'
            # WHEN Price >30 and Price <= 100 THEN '30~100'
            # ELSE 'Over 100' END AS price_group
  # FROM Products
  
my $in_hash = {
    da_compose_only           => 1,
    update_requires_condition => 0,
    delete_requires_condition => 0,
    view                      => { name => 'ProductName' },
    elements =>[{case=>[{ left      => { name => 'Price', },
                          right     => { value => '10' },
                          operator  => '<',
                          expression=>{value=>'under 10$'}},
                        [{left      => { 'Price'},
                          right     => { value => '10' },
                          operator   => '>=',
                         },
                         { condition => 'and',
                           left      => {name=>'Price'}
                           right     => { value => '30' },
                           operator  => '<=',
                           expression=>{value=>'10~30$'}}
                        ],
                        [{left      => { 'Price'},
                          right     => { value => '30' },
                          operator   => '>',
                         },
                         { condition => 'and',
                           left      => {name=>'Price'}
                           right     => { value => '100' },
                           operator  => '<=',
                           expression=>{value=>'30~100$'}}
                        ],
                        { expression=>{value=>'Over 100$'}},
                        ]
                 alias=>'price_group'}]};
                        
my $container = {
    last_name  => 'Bloggings',
    first_name => 'Bill',
};

my $tests = [
   
];

# my $test = pop(@{$tests});

$utils->sql_param_ok( $in_hash, $tests );

