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
            name => 'user_id',
            view => 'people'
        },
    ],
};
 
my $tests = [{
    key  =>'sorts',
    sorts => [
             {name => 'last_name',
              view => 'people'
            },
            {
              name => 'first_name',
              view => 'people'
            },
            ],
    caption => "Order by ",
    sql     => "SELECT people.first_name, people.last_name, people.user_id FROM people ORDER BY people.last_name, people.first_name",
}];




use Test::More  tests => 2;

my $utils =  Test::Utils->new();



my $da     = Database::Accessor->new($in_hash);
my $dbh = $utils->connect();



foreach my $test (@{$tests}){
   
  $utils->sql_param_ok($dbh,$in_hash,$test);


}                  

