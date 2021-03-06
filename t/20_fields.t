#!perl
use Test::More tests => 88;
use Test::Fatal;
use lib ('D:\GitHub\database-accessor\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\t\lib');
use Data::Dumper;
use Database::Accessor;
use Test::Deep;
use Test::Utils;
my $utils   = Test::Utils->new();
my $in_hash = {
    da_compose_only           => 1,
    update_requires_condition => 0,
    delete_requires_condition => 0,
    view                      => { name => 'people' },
    elements => [ { name => 'first_name', }, { name => 'last_name', }, ],
};
my $container = {
    last_name  => 'Bloggings',
    first_name => 'Bill',
};

my $tests = [
    {
        caption => 'Fields only',
        create  => {
            container => $container,
            sql =>
              "INSERT INTO people ( first_name, last_name ) VALUES( ?, ? )",
            params => [ 'Bill', 'Bloggings' ]
        },

        retrieve =>
          { sql => "SELECT people.first_name, people.last_name FROM people" },
        update => {
            container => { first_name => 'Robert' },
            sql       => "UPDATE people SET first_name = ?",
            params    => ['Robert']
        },
        delete => { sql => "DELETE FROM people" },
    },
    {
        caption  => '2 Fields and 2 params',
        key      => 'elements',
        elements => [
            { value => 'User Name:' },
            { name  => 'first_name', },
            { value => 'Address:' },
            { name  => 'last_name', },
        ],
        create => {
            container => $container,
            sql =>
              "INSERT INTO people ( first_name, last_name ) VALUES( ?, ? )",
            params => [ 'Bill', 'Bloggings' ]
        },

        retrieve => {
            sql =>
              "SELECT ?, people.first_name, ?, people.last_name FROM people",
            params => [ 'User Name:', 'Address:' ]
        },
        update => {
            container => { first_name => 'Robert' },
            sql       => "UPDATE people SET first_name = ?",
            params    => ['Robert']
        },
        delete => { sql => "DELETE FROM people" },
    },
    {
        caption  => '2 Fields and 2 parama with Alias',
        key      => 'elements',
        elements => [
            {
                value => 'User Name:',
                alias => 'Name'
            },
            {
                name  => 'first_name',
                alias => 'Name2'
            },
            {
                value => 'Address:',
                alias => 'Name3'
            },
            {
                name  => 'last_name',
                alias => 'Name 4'
            },
        ],
        create => {
            container => $container,
            sql =>
              "INSERT INTO people ( first_name, last_name ) VALUES( ?, ? )",
            params => [ 'Bill', 'Bloggings' ]
        },

        retrieve => {
            sql =>
'SELECT ? Name, people.first_name Name2, ? Name3, people.last_name "Name 4" FROM people',
            params => [ 'User Name:', 'Address:' ]
        },
        update => {
            container => { first_name => 'Robert' },
            sql       => "UPDATE people SET first_name = ?",
            params    => ['Robert']
        },
        delete => { sql => "DELETE FROM people" },
    },
    {
        caption  => '2 Fields and a function with 1 param',
        key      => 'elements',
        elements => [
            { name => 'first_name', },
            { name => 'last_name', },
            {
                function => 'left',
                left     => { name => 'username' },
                right    => { param => 11 }
            },
        ],
        create => {
            container => $container,
            sql =>
              "INSERT INTO people ( first_name, last_name ) VALUES( ?, ? )",
            params => [ 'Bill', 'Bloggings' ]
        },

        retrieve => {
            sql =>
"SELECT people.first_name, people.last_name, LEFT(people.username,?) FROM people",
            params => ['11']
        },
        update => {
            container => { first_name => 'Robert' },
            sql       => "UPDATE people SET first_name = ?",
            params    => ['Robert']
        },
        delete => { sql => "DELETE FROM people" },
    },
    {
        caption  => '2 Fields and a function with 2 params',
        key      => 'elements',
        elements => [
            { name => 'first_name', },
            { name => 'last_name', },
            {
                function => 'substr',
                left     => { name => 'username' },
                right    => [ { param => 3 }, { param => 5 } ]
            }
        ],
        create => {
            container => $container,
            sql =>
              "INSERT INTO people ( first_name, last_name ) VALUES( ?, ? )",
            params => [ 'Bill', 'Bloggings' ]
        },

        retrieve => {
            sql =>
"SELECT people.first_name, people.last_name, SUBSTR(people.username,?,?) FROM people",
            params => [ '3', '5' ]
        },
        update => {
            container => { first_name => 'Robert' },
            sql       => "UPDATE people SET first_name = ?",
            params    => ['Robert']
        },
        delete => { sql => "DELETE FROM people" },
    },
    {
        caption  => '2 Fields and a function within a function',
        key      => 'elements',
        elements => [
            { name => 'first_name', },
            { name => 'last_name', },
            {
                function => 'substr',
                left     => { name => 'username' },
                right    => [
                    { param => 3 },
                    {
                        function => 'left',
                        left     => { name => 'address' },
                        right    => { param => 4 }
                    }
                ]
            }
        ],
        create => {
            container => $container,
            sql =>
              "INSERT INTO people ( first_name, last_name ) VALUES( ?, ? )",
            params => [ 'Bill', 'Bloggings' ]
        },

        retrieve => {
            sql =>
"SELECT people.first_name, people.last_name, SUBSTR(people.username,?,LEFT(people.address,?)) FROM people",
            params => [ '3', '4' ]
        },
        update => {
            container => { first_name => 'Robert' },
            sql       => "UPDATE people SET first_name = ?",
            params    => ['Robert']
        },
        delete => { sql => "DELETE FROM people" },
    },
    {
        caption  => '2 Fields and an expression',
        key      => 'elements',
        elements => [
            { name => 'first_name', },
            { name => 'last_name', },
            {
                expression => '+',
                left       => { name => 'salary' },
                right      => { param => 10 }
            }
        ],
        create => {
            container => $container,
            sql =>
              "INSERT INTO people ( first_name, last_name ) VALUES( ?, ? )",
            params => [ 'Bill', 'Bloggings' ]
        },

        retrieve => {
            sql =>
"SELECT people.first_name, people.last_name, people.salary + ? FROM people",
            params => ['10']
        },
        update => {
            container => { first_name => 'Robert' },
            sql       => "UPDATE people SET first_name = ?",
            params    => ['Robert']
        },
        delete => { sql => "DELETE FROM people" },
    },
    {
        caption  => '2 Fields and an expression in an expression',
        key      => 'elements',
        elements => [
            { name => 'first_name', },
            { name => 'last_name', },
            {
                expression => '+',
                left       => { name => 'salary' },
                right      => {
                    expression => '*',
                    left       => { name => 'bonus' },
                    right      => { param => 0.05 }
                }
            }
        ],
        create => {
            container => $container,
            sql =>
              "INSERT INTO people ( first_name, last_name ) VALUES( ?, ? )",
            params => [ 'Bill', 'Bloggings' ]
        },

        retrieve => {
            sql =>
"SELECT people.first_name, people.last_name, people.salary + people.bonus * ? FROM people",
            params => ['0.05']
        },
        update => {
            container => { first_name => 'Robert' },
            sql       => "UPDATE people SET first_name = ?",
            params    => ['Robert']
        },
        delete => { sql => "DELETE FROM people" },
    },
    {
        caption  => '2 Fields and an expression in a function',
        key      => 'elements',
        elements => [
            { name => 'first_name', },
            { name => 'last_name', },
            {
                function => 'abs',
                left     => {
                    expression => '*',
                    left       => { name => 'bonus' },
                    right      => { param => -0.05 }
                }
            }
        ],
        create => {
            container => $container,
            sql =>
              "INSERT INTO people ( first_name, last_name ) VALUES( ?, ? )",
            params => [ 'Bill', 'Bloggings' ]
        },

        retrieve => {
            sql =>
"SELECT people.first_name, people.last_name, ABS(people.bonus * ?) FROM people",
            params => [-0.05]
        },
        update => {
            container => { first_name => 'Robert' },
            sql       => "UPDATE people SET first_name = ?",
            params    => ['Robert']
        },
        delete => { sql => "DELETE FROM people" },
    },
    {
        caption  => '2 Fields and a function in an expression',
        key      => 'elements',
        elements => [
            { name => 'first_name', },
            { name => 'last_name', },
            {
                expression => '*',
                left       => { name => 'bonus' },
                right      => {
                    function => 'abs',
                    left     => { param => '-0.1' }
                }
            }
        ],
        create => {
            container => $container,
            sql =>
              "INSERT INTO people ( first_name, last_name ) VALUES( ?, ? )",
            params => [ 'Bill', 'Bloggings' ]
        },

        retrieve => {
            sql =>
"SELECT people.first_name, people.last_name, people.bonus * ABS(?) FROM people",
            params => [-0.1]
        },
        update => {
            container => { first_name => 'Robert' },
            sql       => "UPDATE people SET first_name = ?",
            params    => ['Robert']
        },
        delete => { sql => "DELETE FROM people" },
    },
    {
        caption =>
'2 Fields and a function in an expression and function in an expression all with alias',
        key      => 'elements',
        elements => [
            {
                name  => 'first_name',
                alias => 'first'
            },
            {
                name  => 'last_name',
                alias => 'last'
            },
            {
                expression => '*',
                left       => { name => 'bonus' },
                right      => {
                    function => 'abs',
                    left     => { param => '-0.1' }
                },

                alias => 'Bonus'
            },
            {
                function => 'abs',
                left     => {
                    expression => '*',
                    left       => { name => 'bonus' },
                    right      => { param => -0.05 }
                },
                alias => 'Secondary Bonus'
            }
        ],
        create => {
            container => $container,
            sql =>
              "INSERT INTO people ( first_name, last_name ) VALUES( ?, ? )",
            params => [ 'Bill', 'Bloggings' ]
        },

        retrieve => {
            sql =>
'SELECT people.first_name first, people.last_name last, people.bonus * ABS(?) Bonus, ABS(people.bonus * ?) "Secondary Bonus" FROM people',
            params => [ -0.1, -0.05 ]
        },
        update => {
            container => { first_name => 'Robert' },
            sql       => "UPDATE people SET first_name = ?",
            params    => ['Robert']
        },
        delete => { sql => "DELETE FROM people" },
    },
    {
        caption =>
'2 Fields and a function in an expression and function in an expression all with alias even sub expression/functions',
        key      => 'elements',
        elements => [
            {
                name  => 'first_name',
                alias => 'first'
            },
            {
                name  => 'last_name',
                alias => 'last'
            },
            {
                expression => '*',
                left       => { name => 'bonus' },
                right      => {
                    function => 'abs',
                    left     => { param => '-0.1' },
                    alias    => 'do not show function alias'
                },

                alias => 'Bonus'
            },
            {
                function => 'abs',
                left     => {
                    expression => '*',
                    left       => { name => 'bonus' },
                    right      => { param => -0.05 },
                    alias      => 'do not show expression alias'
                },
                alias => 'Secondary Bonus'
            }
        ],
        create => {
            container => $container,
            sql =>
              "INSERT INTO people ( first_name, last_name ) VALUES( ?, ? )",
            params => [ 'Bill', 'Bloggings' ]
        },

        retrieve => {
            sql =>
'SELECT people.first_name first, people.last_name last, people.bonus * ABS(?) Bonus, ABS(people.bonus * ?) "Secondary Bonus" FROM people',
            params => [ -0.1, -0.05 ]
        },
        update => {
            container => { first_name => 'Robert' },
            sql       => "UPDATE people SET first_name = ?",
            params    => ['Robert']
        },
        delete => { sql => "DELETE FROM people" },
    },
    {
        caption  => 'The expression from hell with alias',
        key      => 'elements',
        elements => [
            {
                alias      => 'This is Hell',
                expression => '+',
                left       => {
                    expression        => '*',
                    alias             => 'do not show',
                    open_parentheses  => 1,
                    close_parentheses => 1,
                    left              => {
                        alias      => 'do not show',
                        expression => '*',

                        open_parentheses  => 1,
                        close_parentheses => 1,
                        left              => {
                            alias    => 'do not show',
                            function => 'abs',
                            left     => {
                                expression => '+',
                                alias      => 'do not show',
                                left =>
                                  { alias => 'do not show', name => 'salary' },
                                right =>
                                  { alias => 'do not show', value => '0.5' }
                            },
                        },
                        right => { alias => 'do not show', value => '1.5' },
                    },
                    right => {
                        name  => 'overtime',
                        alias => 'do not show',
                    },
                },
                right => {
                    expression        => '*',
                    open_parentheses  => 1,
                    close_parentheses => 1,
                    left              => {
                        alias             => 'do not show',
                        expression        => '*',
                        open_parentheses  => 1,
                        close_parentheses => 1,
                        left              => {
                            function => 'abs',
                            alias    => 'do not show',
                            left     => {
                                alias      => 'do not show',
                                expression => '+',
                                left =>
                                  { alias => 'do not show', name => 'salary' },
                                right =>
                                  { alias => 'do not show', value => '0.5' }
                            },
                        },
                        right => { alias => 'do not show', value => '2' },
                    },
                    right => { alias => 'do not show', name => 'doubletime' },
                }
            },
        ],
        retrieve => {
            sql =>
'SELECT ((ABS(people.salary + ?) * ?) * people.overtime) + ((ABS(people.salary + ?) * ?) * people.doubletime) "This is Hell" FROM people',
            params => [ '0.5', '1.5', '0.5', '2' ]
        },
    },
    {
        caption  => 'Can not have a an aggregate in an aggregate',
        type     => 'exception',
        key      => 'elements',
        elements => [
            {
                function => 'COUNT',
                left     => {
                    function => 'avg',
                    left     => { name => 'bonus' },
                },
            }
        ],
        retrieve =>
          { message => 'An Element can have only one Aggregate function!' },
    },
    {
        caption  => '2 Fields and two Aggregate',
        key      => 'elements',
        elements => [
            {
                name  => 'first_name',
                alias => 'first'
            },
            {
                name  => 'last_name',
                alias => 'last'
            },
            {
                function => 'count',
                left     => { name => 'first_name' },
            },
            {
                function => 'count',
                left     => { name => 'last_name' },
            }
        ],
        retrieve => {
            sql =>
'SELECT people.first_name first, people.last_name last, COUNT(people.first_name), COUNT(people.last_name) FROM people',
        },
    },
    {
        caption  => 'Can not have a an aggregate in an aggregate complex',
        type     => 'exception',
        key      => 'elements',
        elements => [
            {
                function => 'COUNT',
                left     => {
                    function => 'abs',
                    left     => {
                        function => 'avg',
                        left     => { name => 'bonus' }
                    },
                    
                },
            }
        ],
        retrieve =>
          { message => 'An Element can have only one Aggregate function!' },
    },
];

# my $test = pop(@{$tests});

$utils->sql_param_ok( $in_hash, $tests );

