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
    update_requires_condition => 0,
    delete_requires_condition => 0,
    view     => { name => 'people' },
    elements => [
        {
            name => 'first_name',
        },
        {
            name => 'last_name',
        },
        {
            name => 'user_id',
        },
    ],
    links => [],
  
};

my $container = {
    last_name  => 'Bloggings',
    first_name => 'Bill',
};

my $tests = [
{
        caption  => "group by with 3 elements",
        key   => 'gather',
        gather => {
        elements => [
            {
                name => 'first_name',
            },
            {
                name => 'last_name',
            },
            {
                name => 'user_id',
            }
        ]
            },
        retrieve => {
            sql =>
"SELECT people.first_name, people.last_name, people.user_id FROM people GROUP BY people.first_name, people.last_name, people.user_id",
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
"UPDATE people SET first_name = ?, last_name = ?",
            params => [ 'Bill', 'Bloggings' ]
        },
        delete => {
            sql    => "DELETE FROM people",
         },
    },
    {
        caption  => "group by with 3 elements mixed",
        key   => 'gather',
        gather => {
        elements => [
            {
                name => 'first_name',
            },
            {
               function => 'left',
                              left     => { name => 'last_name',    },
                              right    => { param => 11 },
            },
            {
                name => 'user_id',
            }
        ]
            },
        retrieve => {
            params => ['11'],
            sql =>
"SELECT people.first_name, people.last_name, people.user_id FROM people GROUP BY people.first_name, LEFT(people.last_name,?), people.user_id",
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
"UPDATE people SET first_name = ?, last_name = ?",
            params => [ 'Bill', 'Bloggings' ]
        },
        delete => {
            sql    => "DELETE FROM people",
        },
    },
    {
        caption  => "group by with 3 elements and 1 having",
        key   => 'gather',
        gather => {
        elements => [
            {
                name => 'first_name',
            },
            {
                name => 'last_name',
            },
            {
                name => 'user_id',
            }
        ],
        conditions=>[{
                left => {
                    name => 'last_name',
                },
                right             => { value => 'Bloggings' },
                operator          => '=',
            },],
            },
        retrieve => {
             params =>  ['Bloggings' ],
            sql =>
"SELECT people.first_name, people.last_name, people.user_id FROM people GROUP BY people.first_name, people.last_name, people.user_id HAVING people.last_name = ?",
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
"UPDATE people SET first_name = ?, last_name = ?",
            params => [ 'Bill', 'Bloggings' ]
        },
        delete => {
            sql    => "DELETE FROM people",
         },
    },
    {
         caption  => "group by with 3 elements mixed 1 havging",
        key   => 'gather',
        gather => {
        elements => [
            {
                name => 'first_name',
            },
            {
               function => 'left',
                              left     => { name => 'last_name',    },
                              right    => { param => 11 },
            },
            {
                name => 'user_id',
            }
        ],
        conditions=>[{
                left => {
                    name => 'last_name',
                },
                right             => { value => 'Bloggings' },
                operator          => '=',
            },]
            },
        retrieve => {
            params => ['11','Bloggings'],
            sql =>
"SELECT people.first_name, people.last_name, people.user_id FROM people GROUP BY people.first_name, LEFT(people.last_name,?), people.user_id HAVING people.last_name = ?",
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
"UPDATE people SET first_name = ?, last_name = ?",
            params => [ 'Bill', 'Bloggings' ]
        },
        delete => {
            sql    => "DELETE FROM people",
        },
    },
       {
         caption  => "group by with 3 elements mixed 2 havging",
        key   => 'gather',
        gather => {
        elements => [
            {
                name => 'first_name',
            },
            {
               function => 'left',
                              left     => { name => 'last_name',    },
                              right    => { param => 11 },
            },
            {
                name => 'user_id',
            }
        ],
        conditions=>[{
                left => {
                    name => 'last_name',
                },
                right             => { value => 'Bloggings' },
                operator          => '=',
            },{
                condition =>'OR',
                left => {
                    name => 'last_name',
                },
                right             => { value => 'Biggles' },
                operator          => '=',
            }]
            },
        retrieve => {
            params => ['11','Bloggings','Biggles'],
            sql =>
"SELECT people.first_name, people.last_name, people.user_id FROM people GROUP BY people.first_name, LEFT(people.last_name,?), people.user_id HAVING people.last_name = ? OR people.last_name = ?",
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
"UPDATE people SET first_name = ?, last_name = ?",
            params => [ 'Bill', 'Bloggings' ]
        },
        delete => {
            sql    => "DELETE FROM people",
        },
    },
   
];




use Test::More  tests => 34;

my $utils =  Test::Utils->new();

$utils->sql_param_ok($in_hash,$tests);

# my $utils =  Test::Utils->new();



# my $da     = Database::Accessor->new($in_hash);
# my $dbh = $utils->connect();



# foreach my $test (@{$tests}){
   
  # $utils->sql_param_ok($dbh,$in_hash,$test);


# }                  

