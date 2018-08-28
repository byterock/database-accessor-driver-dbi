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


  
my $in_hash = {
    da_compose_only           => 1,
    update_requires_condition => 0,
    delete_requires_condition => 0,
    view                      => { name => 'Products' },
    elements =>[{whens=>[{ left      => { name => 'Price', },
                          right     => { value => '10' },
                          operator  => '<',
                          statement=>{value=>'under 10$'}},
                        [{left      => { name =>'Price'},
                          right     => { value => '10' },
                          operator   => '>=',
                         },
                         { condition => 'and',
                           left      => {name=>'Price'},
                           right     => { value => '30' },
                           operator  => '<=',
                           statement=>{value=>'10~30$'}}
                        ],
                        [{left      => {name => 'Price'},
                          right     => { value => '30' },
                          operator   => '>',
                         },
                         { condition => 'and',
                           left      => {name=>'Price'},
                           right     => { value => '100' },
                           operator  => '<=',
                           statement=>{value=>'30~100$'}}
                        ],
                        { statement=>{value=>'Over 100$'}},
                        ],
                 alias=>'price_group'}]};
                        
my $container = {
    last_name  => 'Bloggings',
    first_name => 'Bill',
};

my $tests = [
 {
        caption => 'Retrieve with case statement in elements',
        retrieve => {
            sql =>"SELECT CASE WHEN Price < ? THEN ? WHEN Price >=? AND Price <= ? THEN ? WHEN Price >? and Price <= ? THEN ? ELSE ? END AS price_group FROM Products",
            params => [10,'under 10$',10,30,'10~30$',30,100,'30~100$','Over 100$']
        },
  }
];

# my $test = pop(@{$tests});

$utils->sql_param_ok( $in_hash, $tests );

