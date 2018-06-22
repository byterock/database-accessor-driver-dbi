#!perl
use Test::Fatal;
use lib ('D:\GitHub\database-accessor\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\t\lib');
use Data::Dumper;
use Database::Accessor;
use Test::Deep;
use Test::Utils;

my $in_hash = {
    da_compose_only=>1,
    view     => { name => 'people' },
    elements => [
        {
            name => 'first_name',
            view => 'people'
        },
        {
            name => 'last_name',
            view => 'people'
        },
        {
            name => 'id',
            view => 'people'
        },
        {
            name => 'street',
            view => 'address'
        },
    ],
    conditions => [
        {
            left => {
                name => 'first_name',
                view => 'people'
            },
            right           => { value => 'test1' },
        },
        ],
    links => []
};

my $tests = [{
    index=>0,
    key  =>'links',
    links =>{type=>'LEFT',
               to  =>{name=>'address'},
               predicates=>[{left=>{name=>'id'},
                            right=>{name=>'user_id',
                                    view=>'address'}
                           }]},
    caption => "Left Link with 1 param",
    sql     => "SELECT people.first_name, people.last_name, people.id, address.street FROM people LEFT JOIN address ON people.id = address.user_id WHERE people.first_name = ?",
params  => ['test1']
}];




use Test::More  tests => 2;

my $utils =  Test::Utils->new();



my $da     = Database::Accessor->new($in_hash);
my $dbh = $utils->connect();

foreach my $test (@{$tests}){
   
  $utils->sql_param_ok($dbh,$in_hash,$test);


}                  

