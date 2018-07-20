#!perl
use Test::More  tests => 6;
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
    da_compose_only=>1,
    update_requires_condition => 0,
    delete_requires_condition => 0,
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
        }
    ],
};

my $container = [{first_name=>'Bill',last_name =>'Bloggings'},
              {first_name=>'Jane',last_name =>'Doe'},
              {first_name=>'John',last_name =>'Doe'},
              {first_name=>'Joe',last_name =>'Blow'},
              ];
my $expected  = [
              ['Bill','Jane','John','Joe'],
              ['Bloggings','Doe','Doe','Blow'],
              ];

my $tests = [
    {
        caption => 'Array execute tests',
        create  => {
            container => $container,
            sql =>
              "INSERT INTO people ( first_name, last_name ) VALUES( ?, ? )",
            params =>$expected
        },

        retrieve =>
          { sql => "SELECT people.first_name, people.last_name, people.user_id FROM people" },
        update => {
            container => $container,
            sql       => "UPDATE people SET first_name = ?, last_name = ?",
            params    => $expected
        },
        delete => { sql => "DELETE FROM people" },
    },
    ];

$utils->sql_param_ok( $in_hash, $tests );


