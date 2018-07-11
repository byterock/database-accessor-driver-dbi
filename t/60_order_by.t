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
        #    view => 'people'
        },
        {
            name => 'last_name',
        #    view => 'people'
        },
        {
            name => 'user_id',
        #    view => 'people'
        },
    ],
};
my $expression = {
    expression => '+',
    left       => {
        expression        => '*',
        open_parentheses  => 1,
        close_parentheses => 1,
        left              => {
            expression        => '*',
            open_parentheses  => 1,
            close_parentheses => 1,
            left              => {
                function => 'abs',
                left     => {
                    open_parentheses  => 1,
                    close_parentheses => 1,
                    expression => '+',
                    left       => { name => 'salary' },
                    right      => { value => '0.5' }
                },
            },
            right => { value => '1.5' },
        },
        right => { name => 'overtime' },
    },
    right => {
        expression        => '*',
        open_parentheses  => 1,
        close_parentheses => 1,
        left              => {
            expression        => '*',
            open_parentheses  => 1,
            close_parentheses => 1,
            left              => {
                function => 'abs',
                left     => {
                    open_parentheses  => 1,
                    close_parentheses => 1,
                    expression => '+',
                    left       => { name => 'salary' },
                    right      => { value => '0.5' }
                },
            },
            right => { value => '2' },
        },
        right => { name => 'doubletime' },
    },
};

 
my $tests = [{
    key  =>'sorts',
    sorts => [
             {name => 'last_name',
            #  view => 'people'
            },
            {
              name => 'first_name',
              #view => 'people'
            },
            ],
    caption => "Simple Order by ",
    sql     => "SELECT people.first_name, people.last_name, people.user_id FROM people ORDER BY people.last_name, people.first_name",
},{
    key  =>'sorts',
    sorts => [$expression],
    caption => "Complex Expression in Order by ",
    sql     => "SELECT people.first_name, people.last_name, people.user_id FROM people ORDER BY ((abs((people.salary + ?)) * ?) * people.overtime) + ((abs((people.salary + ?)) * ?) * people.doubletime)",
    params  => ['0.5','1.5','0.5','2']
}];

use Test::More  tests =>2;
my $utils =  Test::Utils->new();
$utils->sql_param_ok($in_hash,$tests);

