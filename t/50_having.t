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
    links => []
};

my $tests = [{
    key  =>'gather',
    gather =>{
        elements => [
            {
                name => 'first_name',
                #view => 'people'
            },
            {
                name => 'last_name',
                view => 'people'
            },
            {
                name => 'user_id',
                view => 'people'
            }
        ],
        conditions => [
            {
                left => {
                    name => 'last_name',
                },
                right             => { value => 'Bloggings' },
                operator          => '=',
            },
        ]
      },
    caption => "Having with 1 param",
    sql     => "SELECT people.first_name, people.last_name, people.user_id FROM people GROUP BY people.first_name, people.last_name, people.user_id HAVING people.last_name = ?",
    params  => ['Bloggings']
}];




use Test::More  tests => 2;

my $utils =  Test::Utils->new();



my $da     = Database::Accessor->new($in_hash);
my $dbh = $utils->connect();



foreach my $test (@{$tests}){
   
  $utils->sql_param_ok($dbh,$in_hash,$test);


}                  

