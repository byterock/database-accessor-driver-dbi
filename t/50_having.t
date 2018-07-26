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
        caption  => "Having Link with 1 condition",
         index => 0,
            key   => 'links',
            links => {
                type       => 'LEFT',
                to         => { name => 'address' },
                conditions => [
                    {
                        left  => { name => 'id' },
                        right => {
                            name => 'user_id',
                            view => 'address'
                        }
                    }
                ]
            },
        retrieve => {
            sql =>
"SELECT people.first_name, people.last_name, people.id, address.street FROM people LEFT JOIN address ON people.id = address.user_id WHERE people.first_name = ?",
            params => ['test1']
        },
        create  => {
            container => $container,
            sql =>
              "INSERT INTO people ( first_name, last_name ) VALUES( ?, ? )",
            params =>  [ 'Bill', 'Bloggings' ]
        },
        update => {
            container => $container,
            sql =>
"UPDATE people SET first_name = ?, last_name = ? LEFT JOIN address ON people.id = address.user_id WHERE people.first_name = ?",
            params => [ 'Bill', 'Bloggings', 'test1' ]
        },
        delete => {
            sql    => "DELETE FROM people LEFT JOIN address ON people.id = address.user_id WHERE people.first_name = ?",
            params => ['test1']
        },
    },
    {
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
$utils->sql_param_ok($in_hash,$tests);

# my $utils =  Test::Utils->new();



# my $da     = Database::Accessor->new($in_hash);
# my $dbh = $utils->connect();



# foreach my $test (@{$tests}){
   
  # $utils->sql_param_ok($dbh,$in_hash,$test);


# }                  

