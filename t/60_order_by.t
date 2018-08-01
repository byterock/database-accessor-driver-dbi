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

 my $container = {
    last_name  => 'Bloggings',
    first_name => 'Bill',
};

my $tests = [
{   key  =>'sorts',
    sorts => [{name=>'last_name'},
              {name=>'first_name'}
              ],
    caption => "Simple Order by ",
    retrieve => {
            sql => "SELECT people.first_name, people.last_name, people.user_id FROM people ORDER BY people.last_name, people.first_name",
    },
    create =>{
        sql=>"INSERT INTO people ( first_name, last_name ) VALUES( ?, ? )",
        container=>$container,
        params=> [ 'Bill', 'Bloggings' ],  
    },
    update =>{
        sql=>"UPDATE people SET first_name = ?, last_name = ?",
        container=>$container,
        params=>['Bill', 'Bloggings'],  
    },
    delete =>{
        sql=>"DELETE FROM people",
    }
}
,{
    key  =>'sorts',
    sorts => [$expression],
    caption => "Complex Expression in Order by ",
    retrieve => {
        sql     => "SELECT people.first_name, people.last_name, people.user_id FROM people ORDER BY ((abs((people.salary + ?)) * ?) * people.overtime) + ((abs((people.salary + ?)) * ?) * people.doubletime)",
        params  => ['0.5','1.5','0.5','2'],
    },
    create =>{
        sql=>"INSERT INTO people ( first_name, last_name ) VALUES( ?, ? )",
        container=>$container,
        params=>['Bill', 'Bloggings'],  
    },
    update =>{
        sql=>"UPDATE people SET first_name = ?, last_name = ?",
        container=>$container,
        params=>['Bill', 'Bloggings'],  
    },
    delete =>{
        sql=>"DELETE FROM people",       
    }
},
{   key  =>'sorts',
    sorts => [{name=>'last_name',
                order=>'DESC'},
              {name=>'first_name',
               order=>'ASC'}
              ],
    caption => "Simple Order by with ASC and DESC",
    retrieve => {
            sql => "SELECT people.first_name, people.last_name, people.user_id FROM people ORDER BY people.last_name DESC, people.first_name ASC",
    },
    create =>{
        sql=>"INSERT INTO people ( first_name, last_name ) VALUES( ?, ? )",
        container=>$container,
        params=> [ 'Bill', 'Bloggings' ],  
    },
    update =>{
        sql=>"UPDATE people SET first_name = ?, last_name = ?",
        container=>$container,
        params=>['Bill', 'Bloggings'],  
    },
    delete =>{
        sql=>"DELETE FROM people",
    }
}
,];

use Test::More  tests =>13;
my $utils =  Test::Utils->new();
$utils->sql_param_ok($in_hash,$tests);

