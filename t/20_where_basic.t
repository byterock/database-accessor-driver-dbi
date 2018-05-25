#!perl
use Test::More  tests => 11;
use Test::Fatal;
use lib ('D:\GitHub\database-accessor\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\t\lib');
use Data::Dumper;
use Database::Accessor;

use Test::Utils;
my $utils = Test::Utils->new();
my $in_hash = {
    da_compose_only=>1,
    view     => { name => 'people' },
    elements => [
        {
            name => 'first_name',
            view => 'People'
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
                name => 'first_name',
                view => 'people'
            },
            right           => { value => 'test1' },
            operator        => '=',
            open_parenthes  => 1,
            close_parenthes => 0,
        },
        {
            condition => 'AND',
            left      => {
                name => 'last_name',
                view => 'people'
            },
            right           => { value => 'test2' },
            operator        => '=',
            open_parenthes  => 0,
            close_parenthes => 1
        }
      ]

    ,
};

my $da     = Database::Accessor->new($in_hash);
ok($da->retrieve( $utils->connect() ),"selected something");
ok($da->result()->query() eq "SELECT people.first_name, people.last_name, people.user_id FROM people WHERE ( people.first_name = ? AND people.last_name = ? )","Select SQL correct");
use Data::Dumper;
warn("results=".Dumper($da->result));