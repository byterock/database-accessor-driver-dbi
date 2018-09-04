#!perl
use Test::Fatal;
use lib ('D:\GitHub\database-accessor\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\t\lib');
use Data::Dumper;
use Database::Accessor;
use Test::Deep;
use Test::Utils;
use Test::More tests => 86;

my $in_hash = {
    da_compose_only => 1,
    view            => { name => 'people' },
    elements        => [
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

    ,
};

my $container = {
    last_name  => 'Bloggings',
    first_name => 'Bill',
};
my $params = [ 'Bill', 'Bloggings' ];

my $tests = [
    {
        caption => 'One field conditions',
        create  => {
            container => $container,
            sql =>
              "INSERT INTO people ( first_name, last_name ) VALUES( ?, ? )",
            params => $params
        },
        key        => 'conditions',
        conditions => [
            {
                left => {
                    name => 'first_name',
                    view => 'people'
                },
                right     => { value => 'test1' },
                operator  => '=',
                condition => 'AND'
            },
        ],
        retrieve => {
            sql =>
"SELECT people.first_name, people.last_name, people.user_id FROM people WHERE people.first_name = ?",
            params => ['test1']
        },

        update => {
            container => $container,
            sql =>
"UPDATE people SET first_name = ?, last_name = ? WHERE people.first_name = ?",
            params => [ 'Bill', 'Bloggings', 'test1' ]
        },
        delete => {
            sql    => "DELETE FROM people WHERE people.first_name = ?",
            params => ['test1']
        },
    },

    {
        caption    => 'Two field conditions',
        key        => 'conditions',
        conditions => [
            {
                left => {
                    name => 'first_name',
                    view => 'people'
                },
                right    => { value => 'test1' },
                operator => '=',
            },
            {
                condition => 'AnD',
                left      => {
                    name => 'last_name',
                    view => 'people'
                },
                right    => { value => 'test2' },
                operator => '=',
            }
        ],
        create => {
            container => $container,
            sql =>
              "INSERT INTO people ( first_name, last_name ) VALUES( ?, ? )",
            params => $params
        },

        retrieve => {
            sql =>
"SELECT people.first_name, people.last_name, people.user_id FROM people WHERE people.first_name = ? AND people.last_name = ?",
            params => [ 'test1', 'test2' ]
        },

        update => {
            container => $container,
            sql =>
"UPDATE people SET first_name = ?, last_name = ? WHERE people.first_name = ? AND people.last_name = ?",
            params => [ 'Bill', 'Bloggings', 'test1', 'test2' ]
        },
        delete => {
            sql =>
"DELETE FROM people WHERE people.first_name = ? AND people.last_name = ?",
            params => [ 'test1', 'test2' ]
        },
    },
    {
        caption => 'One function conditions',
        create  => {
            container => $container,
            sql =>
              "INSERT INTO people ( first_name, last_name ) VALUES( ?, ? )",
            params => $params
        },
        key        => 'conditions',
        conditions => [
            {
                left => {
                    function => 'substr',
                    left     => { name => 'username' },
                    right    => [ { param => 3 }, { param => 5 } ]
                },
                right     => { value => 'tes' },
                operator  => '=',
                condition => 'AND'
            },
        ],
        retrieve => {
            sql =>
"SELECT people.first_name, people.last_name, people.user_id FROM people WHERE SUBSTR(people.username,?,?) = ?",
            params => [ '3', '5', 'tes' ]
        },

        update => {
            container => $container,
            sql =>
"UPDATE people SET first_name = ?, last_name = ? WHERE SUBSTR(people.username,?,?) = ?",
            params => [ 'Bill', 'Bloggings', '3', '5', 'tes' ]
        },
        delete => {
            sql => "DELETE FROM people WHERE SUBSTR(people.username,?,?) = ?",
            params => [ '3', '5', 'tes' ]
        },
    },

    {
        caption    => 'Two function conditions',
        key        => 'conditions',
        conditions => [
            {
                left => {
                    function => 'substr',
                    left     => { name => 'username' },
                    right    => [ { param => 3 }, { param => 5 } ]
                },
                right    => { value => 'tes' },
                operator => '=',
            },
            {
                condition => 'AND',
                left      => {
                    function => 'left',
                    left     => { name => 'first_name' },
                    right    => [ { param => 4 } ]
                },
                right    => { value => 'test' },
                operator => '=',
            }
        ],
        create => {
            container => $container,
            sql =>
              "INSERT INTO people ( first_name, last_name ) VALUES( ?, ? )",
            params => $params
        },

        retrieve => {
            sql =>
"SELECT people.first_name, people.last_name, people.user_id FROM people WHERE SUBSTR(people.username,?,?) = ? AND LEFT(people.first_name,?) = ?",
            params => [ '3', '5', 'tes', '4', 'test' ]
        },

        update => {
            container => $container,
            sql =>
"UPDATE people SET first_name = ?, last_name = ? WHERE SUBSTR(people.username,?,?) = ? AND LEFT(people.first_name,?) = ?",
            params => [ 'Bill', 'Bloggings', '3', '5', 'tes', '4', 'test' ]
        },
        delete => {
            sql =>
"DELETE FROM people WHERE SUBSTR(people.username,?,?) = ? AND LEFT(people.first_name,?) = ?",
            params => [ '3', '5', 'tes', '4', 'test' ]
        },
    },
    {
        caption => 'One expression conditions',
        create  => {
            container => $container,
            sql =>
              "INSERT INTO people ( first_name, last_name ) VALUES( ?, ? )",
            params => $params
        },
        key        => 'conditions',
        conditions => [
            {
                left => {
                    expression => '*',
                    left       => { name => 'salary' },
                    right      => { param => '0.1' }
                },
                right     => { value => '1000' },
                operator  => '>=',
                condition => 'AND'
            },
        ],
        retrieve => {
            sql =>
"SELECT people.first_name, people.last_name, people.user_id FROM people WHERE people.salary * ? >= ?",
            params => [ '0.1', '1000' ]
        },

        update => {
            container => $container,
            sql =>
"UPDATE people SET first_name = ?, last_name = ? WHERE people.salary * ? >= ?",
            params => [ 'Bill', 'Bloggings', '0.1', '1000' ]
        },
        delete => {
            sql    => "DELETE FROM people WHERE people.salary * ? >= ?",
            params => [ '0.1', '1000' ]
        },
    },

    {
        caption    => 'Two function conditions',
        key        => 'conditions',
        conditions => [
            {
                left => {
                    expression => '*',
                    left       => { name => 'salary' },
                    right      => { param => '0.1' }
                },
                right    => { value => '1000' },
                operator => '>=',
            },
            {
                condition => 'OR',
                left      => {
                    expression => '*',
                    left       => { name => 'bonus' },
                    right      => { param => '0.15' }
                },
                right    => { value => '1500' },
                operator => '<=',
            }
        ],
        create => {
            container => $container,
            sql =>
              "INSERT INTO people ( first_name, last_name ) VALUES( ?, ? )",
            params => $params
        },

        retrieve => {
            sql =>
"SELECT people.first_name, people.last_name, people.user_id FROM people WHERE people.salary * ? >= ? OR people.bonus * ? <= ?",
            params => [ '0.1', '1000', '0.15', '1500' ]
        },

        update => {
            container => $container,
            sql =>
"UPDATE people SET first_name = ?, last_name = ? WHERE people.salary * ? >= ? OR people.bonus * ? <= ?",
            params => [ 'Bill', 'Bloggings', '0.1', '1000', '0.15', '1500' ]
        },
        delete => {
            sql =>
"DELETE FROM people WHERE people.salary * ? >= ? OR people.bonus * ? <= ?",
            params => [ '0.1', '1000', '0.15', '1500' ]
        },
    },

    {
        caption    => 'Element and a expression condition',
        key        => 'conditions',
        conditions => [
            {
                left => {
                    name => 'first_name',
                    view => 'people'
                },
                right    => { value => 'test1' },
                operator => '!=',
            },
            {

                condition => 'AND',
                left      => {
                    expression => '*',
                    left       => { name => 'bonus' },
                    right      => { param => '0.15' }
                },
                right    => { value => '1500' },
                operator => '<=',
            }
        ],
        create => {
            container => $container,
            sql =>
              "INSERT INTO people ( first_name, last_name ) VALUES( ?, ? )",
            params => $params
        },

        retrieve => {
            sql =>
"SELECT people.first_name, people.last_name, people.user_id FROM people WHERE people.first_name != ? AND people.bonus * ? <= ?",
            params => [ 'test1', '0.15', '1500' ]
        },

        update => {
            container => $container,
            sql =>
"UPDATE people SET first_name = ?, last_name = ? WHERE people.first_name != ? AND people.bonus * ? <= ?",
            params => [ 'Bill', 'Bloggings', 'test1', '0.15', '1500' ]
        },
        delete => {
            sql =>
"DELETE FROM people WHERE people.first_name != ? AND people.bonus * ? <= ?",
            params => [ 'test1', '0.15', '1500' ]
        },
    },
    {
        caption    => 'Element, expression and a function condition',
        key        => 'conditions',
        conditions => [
            {
                left => {
                    name => 'first_name',
                    view => 'people'
                },
                right    => { value => 'test1' },
                operator => '!=',
            },
            {

                condition => 'AND',
                left      => {
                    expression => '*',
                    left       => { name => 'bonus' },
                    right      => { param => '0.15' }
                },
                right    => { value => '1500' },
                operator => '<=',
            },
            {
                condition => 'AND',
                left      => {
                    function => 'left',
                    left     => { name => 'first_name' },
                    right    => [ { param => 1 } ]
                },
                right    => { value => 'b' },
                operator => '!=',
            }
        ],
        create => {
            container => $container,
            sql =>
              "INSERT INTO people ( first_name, last_name ) VALUES( ?, ? )",
            params => $params
        },

        retrieve => {
            sql =>
"SELECT people.first_name, people.last_name, people.user_id FROM people WHERE people.first_name != ? AND people.bonus * ? <= ? AND LEFT(people.first_name,?) != ?",
            params => [ 'test1', '0.15', '1500', '1', 'b' ]
        },

        update => {
            container => $container,
            sql =>
"UPDATE people SET first_name = ?, last_name = ? WHERE people.first_name != ? AND people.bonus * ? <= ? AND LEFT(people.first_name,?) != ?",
            params => [ 'Bill', 'Bloggings', 'test1', '0.15', '1500', '1', 'b' ]
        },
        delete => {
            sql =>
"DELETE FROM people WHERE people.first_name != ? AND people.bonus * ? <= ? AND LEFT(people.first_name,?) != ?",
            params => [ 'test1', '0.15', '1500', '1', 'b' ]
        },
    },
    {
        caption =>
'Elements with alias and Element, expression and a function condition',
        keys      => [ 'elements', 'conditions' ],
        elements => [
            {
                name => 'first_name',
                alias=> 'First',
                
            },
            {
                name => 'last_name',
                view => 'people',
                alias=> 'Last'
            },
            {
                name => 'user_id',
                view => 'people',
                alias=> 'User ID'
            }
        ],
        conditions => [
            {
                left => {
                    name => 'first_name',
                    view => 'people'
                },
                right    => { value => 'test1' },
                operator => '!=',
            },
            {

                condition => 'AND',
                left      => {
                    expression => '*',
                    left       => { name => 'bonus' },
                    right      => { param => '0.15' }
                },
                right    => { value => '1500' },
                operator => '<=',
            },
            {
                condition => 'AND',
                left      => {
                    function => 'left',
                    left     => { name => 'first_name' },
                    right    => [ { param => 1 } ]
                },
                right    => { value => 'b' },
                operator => '!=',
            }
        ],
        create => {
            container => $container,
            sql =>
              "INSERT INTO people ( first_name, last_name ) VALUES( ?, ? )",
            params => $params
        },

        retrieve => {
            sql =>
'SELECT people.first_name First, people.last_name Last, people.user_id "User ID" FROM people WHERE people.first_name != ? AND people.bonus * ? <= ? AND LEFT(people.first_name,?) != ?',
            params => [ 'test1', '0.15', '1500', '1', 'b' ]
        },

        update => {
            container => $container,
            sql =>
"UPDATE people SET first_name = ?, last_name = ? WHERE people.first_name != ? AND people.bonus * ? <= ? AND LEFT(people.first_name,?) != ?",
            params => [ 'Bill', 'Bloggings', 'test1', '0.15', '1500', '1', 'b' ]
        },
        delete => {
            sql =>
"DELETE FROM people WHERE people.first_name != ? AND people.bonus * ? <= ? AND LEFT(people.first_name,?) != ?",
            params => [ 'test1', '0.15', '1500', '1', 'b' ]
        },
    },
      {
        caption =>"Condition from hell",
        key      => 'conditions' ,
        conditions => [
            {
                left =>  {
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
                right    => { value => '42' },
                operator => '!=',
            },
        ],
        create => {
            container => $container,
            sql =>
              "INSERT INTO people ( first_name, last_name ) VALUES( ?, ? )",
            params => $params
        },

        retrieve => {
            sql =>
'SELECT people.first_name First, people.last_name Last, people.user_id "User ID" FROM people WHERE ((ABS(people.salary + ?) * ?) * people.overtime) + ((ABS(people.salary + ?) * ?) * people.doubletime) != ?',
            params => [ '0.5', '1.5', '0.5', '2','42' ]
        },

        update => {
            container => $container,
            sql =>
"UPDATE people SET first_name = ?, last_name = ? WHERE ((ABS(people.salary + ?) * ?) * people.overtime) + ((ABS(people.salary + ?) * ?) * people.doubletime) != ?",
            params => [ 'Bill', 'Bloggings', '0.5', '1.5', '0.5', '2','42' ]
        },
        delete => {
            sql =>
"DELETE FROM people WHERE ((ABS(people.salary + ?) * ?) * people.overtime) + ((ABS(people.salary + ?) * ?) * people.doubletime) != ?",
            params => [ '0.5', '1.5', '0.5', '2','42' ]
        },
    },
     {
        caption => 'One Case left field conditions',
        key        => 'conditions',
        conditions => [
            {
                left => {ifs=>[{ left      => { name => 'Price', },
                          right     => { value => '10' },
                          operator  => '<',
                          then=>{value=>'under 10$'}},
                        [{left      => { name =>'Price'},
                          right     => { value => '10' },
                          operator   => '>=',
                         },
                         { condition => 'and',
                           left      => {name=>'Price'},
                           right     => { value => '30' },
                           operator  => '<=',
                           then=>{value=>'10~30$'}}
                        ],
                        [{left      => {name => 'Price'},
                          right     => { value => '30' },
                          operator   => '>',
                         },
                         { condition => 'and',
                           left      => {name=>'Price'},
                           right     => { value => '100' },
                           operator  => '<=',
                           then=>{value=>'30~100$'}}
                        ],
                        { then=>{value=>'Over 100$'}},
                        ],},
                right     => { value => 'test1' },
                operator  => '=',
                condition => 'AND'
            },
        ],
        retrieve => {
            sql =>
'SELECT people.first_name First, people.last_name Last, people.user_id "User ID" FROM people WHERE CASE WHEN people.Price < ? THEN ? WHEN people.Price >= ? AND people.Price <= ? THEN ? WHEN people.Price > ? AND people.Price <= ? THEN ? ELSE ? END = ?',
            params => [10,'under 10$',10,30,'10~30$',30,100,'30~100$','Over 100$','test1']
        },

        update => {
            container => $container,
            sql =>
"UPDATE people SET first_name = ?, last_name = ? WHERE CASE WHEN people.Price < ? THEN ? WHEN people.Price >= ? AND people.Price <= ? THEN ? WHEN people.Price > ? AND people.Price <= ? THEN ? ELSE ? END = ?",
            params => [ 'Bill', 'Bloggings', 10,'under 10$',10,30,'10~30$',30,100,'30~100$','Over 100$','test1' ]
        },
        delete => {
            sql    => "DELETE FROM people WHERE CASE WHEN people.Price < ? THEN ? WHEN people.Price >= ? AND people.Price <= ? THEN ? WHEN people.Price > ? AND people.Price <= ? THEN ? ELSE ? END = ?",
            params => [10,'under 10$',10,30,'10~30$',30,100,'30~100$','Over 100$','test1']
        },
    },
];

my $utils = Test::Utils->new();
$utils->sql_param_ok( $in_hash,$tests );


