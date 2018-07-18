#!perl
use Test::More tests => 18;
use Test::Fatal;
use lib ('D:\GitHub\database-accessor\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\t\lib');
use Data::Dumper;
use Database::Accessor;
use Test::Deep;
use Test::Utils;
my $utils = Test::Utils->new();

my $in_hash = {
    da_compose_only           => 1,
    update_requires_condition => 0,
    delete_requires_condition => 0,
    view                      => {
        name  => 'people',
        alias => 'sys_users'
    },
    elements => [ { name => 'last_name', }, { name => 'first_name', }, ],
};

# my $container =  {first_name=>'Bill',
# last_name =>'Bloggings'};
# my $da  = Database::Accessor->new($in_hash);

my $tests = [
    {
        caption => 'Basic table alias',
        create  => {
            container => {
                first_name => 'Bill',
                last_name  => 'Bloggings'
            },
            sql =>
              "INSERT INTO people ( first_name, last_name ) VALUES( ?, ? )",
            params => [ 'Bill', 'Bloggings' ]
        },

        retrieve => {
            sql =>
"SELECT sys_users.last_name, sys_users.first_name FROM people sys_users"
        },
        update => {
            container => { first_name => 'Robert' },
            sql       => "UPDATE people SET first_name = ?",
            params    => ['Robert']
        },
        delete => { sql => "DELETE FROM people" },

    },
    {
        caption  => 'Basic field alias',
        key      => 'elements',
        elements => [
            {
                name  => 'last_name',
                alias => 'last'
            },
            {
                name  => 'first_name',
                alias => 'first'
            }
        ],
        create => {
            container => {
                first_name => 'Bill',
                last_name  => 'Bloggings'
            },
            sql =>
              "INSERT INTO people ( first_name, last_name ) VALUES( ?, ? )",
            params => [ 'Bill', 'Bloggings' ]
        },

        retrieve => {
            sql =>
"SELECT sys_users.last_name last, sys_users.first_name first FROM people sys_users"
        },
        update => {
            container => { first_name => 'Robert' },
            sql       => "UPDATE people SET first_name = ?",
            params    => ['Robert']
        },
        delete => { sql => "DELETE FROM people" },

    },
        {
        caption  => 'Field alias with spaces',
        key      => 'elements',
        elements => [
            {
                name  => 'last_name',
                alias => 'Last Name'
            },
            {
                name  => 'first_name',
                alias => 'First Name'
            }
        ],
        create => {
            container => {
                first_name => 'Bill',
                last_name  => 'Bloggings'
            },
            sql =>
              "INSERT INTO people ( first_name, last_name ) VALUES( ?, ? )",
            params => [ 'Bill', 'Bloggings' ]
        },

        retrieve => {
            sql =>
'SELECT sys_users.last_name "Last Name", sys_users.first_name "First Name" FROM people sys_users'
        },
        update => {
            container => { first_name => 'Robert' },
            sql       => "UPDATE people SET first_name = ?",
            params    => ['Robert']
        },
        delete => { sql => "DELETE FROM people" },

    },
];

$utils->sql_param_ok( $in_hash, $tests );

# $in_hash->{elements}= [
# {
# name => 'last_name',
# alias=>  'last'
# },
# {
# name => 'first_name',
# alias=> 'first'
# },
# ];

# $tests->[0]->{retrieve}->{sql}="";
# $tests->[0]->{caption} = "Basic Field alias";
# $utils->sql_param_ok($in_hash,$tests);

# $tests->[0]->{retrieve}->{sql}="SELECT sys_users.last_name last, sys_users.first_name first FROM people sys_users";
# $tests->[0]->{caption} = "Space in Field alias";
# $utils->sql_param_ok($in_hash,$tests);

