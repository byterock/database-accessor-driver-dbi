#!perl
use Test::Fatal;
use lib ('D:\GitHub\database-accessor\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\t\lib');
use Data::Dumper;
use Database::Accessor;
use Test::Deep;
use Test::Utils;
use Test::More tests => 80;
use Test::Fatal;

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

# use constant IN          => 'IN';
# use constant NOT_IN      => 'NOT IN';
# use constant BETWEEN     => 'BETWEEN';
# use constant LIKE        => 'LIKE';
# use constant IS_NULL     => 'ada_and_andrew_2004a';
# use constant IS_NOT_NULL => 'IS NOT NULL';

my $tests = [
    {
        caption    => 'Between Operator Params',
        key        => 'conditions',
        conditions => [
            {
                left => {
                    name => 'salary',
                    view => 'people'
                },
                right    => [ { value => 35000 }, { value => 50000 } ],
                operator => 'BETWeeN',
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
"SELECT people.first_name, people.last_name, people.user_id FROM people WHERE people.salary BETWEEN ? AND ?",
            params => [ '35000', '50000' ]
        },

        update => {
            container => $container,
            sql =>
"UPDATE people SET first_name = ?, last_name = ? WHERE people.salary BETWEEN ? AND ?",
            params => [ 'Bill', 'Bloggings', '35000', '50000' ]
        },
        delete => {
            sql    => "DELETE FROM people WHERE people.salary BETWEEN ? AND ?",
            params => [ '35000', '50000' ]
        },
    },
    {
        caption    => 'Between Operator Elements',
        key        => 'conditions',
        conditions => [
            {
                left => {
                    name => 'salary',
                    view => 'people'
                },
                right    => [ { name => 'wage' }, { name => 'cost' } ],
                operator => 'BETWEEN',
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
"SELECT people.first_name, people.last_name, people.user_id FROM people WHERE people.salary BETWEEN people.wage AND people.cost",
        },

        update => {
            container => $container,
            sql =>
"UPDATE people SET first_name = ?, last_name = ? WHERE people.salary BETWEEN people.wage AND people.cost",
            params => [ 'Bill', 'Bloggings', ]
        },
        delete => {
            sql =>
"DELETE FROM people WHERE people.salary BETWEEN people.wage AND people.cost",
        },
    },
    {
        caption    => 'Between Operator Param and Element',
        key        => 'conditions',
        conditions => [
            {
                left => {
                    name => 'salary',
                    view => 'people'
                },
                right => [ { value => '10000' }, { name => 'cost' } ],
                operator => 'BETWEEN',
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
"SELECT people.first_name, people.last_name, people.user_id FROM people WHERE people.salary BETWEEN ? AND people.cost",
            params => [10000]
        },

        update => {
            container => $container,
            sql =>
"UPDATE people SET first_name = ?, last_name = ? WHERE people.salary BETWEEN ? AND people.cost",
            params => [ 'Bill', 'Bloggings', 10000 ]
        },
        delete => {
            sql =>
"DELETE FROM people WHERE people.salary BETWEEN ? AND people.cost",
            params => [10000]
        },
    },
    {
        caption    => 'Between Operator Element and Param',
        key        => 'conditions',
        conditions => [
            {
                left => {
                    name => 'salary',
                    view => 'people'
                },
                right => [ { name => 'cost' }, { value => '10000' }, ],
                operator => 'BETWEEN',
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
"SELECT people.first_name, people.last_name, people.user_id FROM people WHERE people.salary BETWEEN people.cost AND ?",
            params => [10000]
        },

        update => {
            container => $container,
            sql =>
"UPDATE people SET first_name = ?, last_name = ? WHERE people.salary BETWEEN people.cost AND ?",
            params => [ 'Bill', 'Bloggings', 10000 ]
        },
        delete => {
            sql =>
"DELETE FROM people WHERE people.salary BETWEEN people.cost AND ?",
            params => [10000]
        },
    },
    {
        caption    => 'Between Operator Element and Epression',
        key        => 'conditions',
        conditions => [
            {
                left => {
                    name => 'salary',
                    view => 'people'
                },
                right => [
                    { name => 'cost' },
                    {
                        expression => '*',
                        left       => { name => 'salary' },
                        right      => { param => 1.1 }
                    },
                ],
                operator => 'BETWEEN',
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
"SELECT people.first_name, people.last_name, people.user_id FROM people WHERE people.salary BETWEEN people.cost AND people.salary * ?",
            params => [1.1]
        },

        update => {
            container => $container,
            sql =>
"UPDATE people SET first_name = ?, last_name = ? WHERE people.salary BETWEEN people.cost AND people.salary * ?",
            params => [ 'Bill', 'Bloggings', 1.1 ]
        },
        delete => {
            sql =>
"DELETE FROM people WHERE people.salary BETWEEN people.cost AND people.salary * ?",
            params => [1.1]
        },
    },
    {
        caption    => 'Between Operator Element and Function',
        key        => 'conditions',
        conditions => [
            {
                left => {
                    name => 'salary',
                    view => 'people'
                },
                right => [
                    { name => 'cost' },
                    {
                        function => 'abs',
                        left     => {
                            expression => '*',
                            left       => { name => 'bonus' },
                            right      => { param => -0.05 }
                        }
                    },
                ],
                operator => 'BETWEEN',
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
"SELECT people.first_name, people.last_name, people.user_id FROM people WHERE people.salary BETWEEN people.cost AND ABS(people.bonus * ?)",
            params => [-0.05]
        },

        update => {
            container => $container,
            sql =>
"UPDATE people SET first_name = ?, last_name = ? WHERE people.salary BETWEEN people.cost AND ABS(people.bonus * ?)",
            params => [ 'Bill', 'Bloggings', -0.05 ]
        },
        delete => {
            sql =>
"DELETE FROM people WHERE people.salary BETWEEN people.cost AND ABS(people.bonus * ?)",
            params => [-0.05]
        },
    },
    {
        caption    => 'between operator right must be an array-ref',
        type       => 'exception',
        key        => 'conditions',
        conditions => [
            {
                left => {
                    name => 'salary',
                    view => 'people'
                },
                right    => { value => 35000 },
                operator => 'BETWEEN',
            },
        ],
        retrieve =>
          { message => 'right must be an Array Ref of two parameters' },
    },
    {
        caption    => 'between right must be an array-ref of two parameters',
        type       => 'exception',
        key        => 'conditions',
        conditions => [
           {
        left => {
            name => 'salary',
            view => 'people'
        },
        right => [
            { value => 35000 },

        ],
        operator => 'BETWEEN',
    },
        ],
        retrieve =>
          { message => 'right must be an Array Ref of two parameters' },
    },
  {
        caption    => 'between left must not be an array-ref',
        type       => 'exception',
        key        => 'conditions',
        conditions => [
          {
        left     => [ { name => 'cost' }, { value => '10000' }, ],
        right    => [ { name => 'cost' }, { value => '10000' }, ],
        operator => 'BETWEEN',
    },
        ],
        retrieve =>
          { message => 'left can not be an Array Ref' },
    },
      {
        caption    => 'Is Null Operator Params',
        key        => 'conditions',
        conditions => [
            {
                left => {
                    name => 'salary',
                    view => 'people'
                },
                operator => 'Is Null',
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
"SELECT people.first_name, people.last_name, people.user_id FROM people WHERE people.salary IS NULL",
        },

        update => {
            container => $container,
            sql =>
"UPDATE people SET first_name = ?, last_name = ? WHERE people.salary IS NULL",
        },
        delete => {
            sql    => "DELETE FROM people WHERE people.salary IS NULL",           
        },
    },
        {
        caption    => 'Is Not Null Operator Params',
        key        => 'conditions',
        conditions => [
            {
                left => {
                    name => 'salary',
                    view => 'people'
                },
                operator => 'Is NOT Null',
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
"SELECT people.first_name, people.last_name, people.user_id FROM people WHERE people.salary IS NOT NULL",
        },

        update => {
            container => $container,
            sql =>
"UPDATE people SET first_name = ?, last_name = ? WHERE people.salary IS NOT NULL",
        },
        delete => {
            sql    => "DELETE FROM people WHERE people.salary IS NOT NULL",           
        },
    },
     {
        caption    => 'In Operator Params',
        key        => 'conditions',
        conditions => [
            {
                left => {
                    name => 'salary',
                    view => 'people'
                },
                operator => 'In',
                right => [{value=>'10000'},
                         {value=>'10010'},
                         {value=>'10020'},]
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
"SELECT people.first_name, people.last_name, people.user_id FROM people WHERE people.salary IN (?,?,?)",
            params => ['10000','10010','10020']
        },

        update => {
            container => $container,
            sql =>
"UPDATE people SET first_name = ?, last_name = ? WHERE people.salary IN (?,?,?)",
 params => [ 'Bill', 'Bloggings', '10000','10010','10020' ]
        },
        delete => {
            sql    => "DELETE FROM people WHERE people.salary IN (?,?,?)",
            params => ['10000','10010','10020']
        },
    },
       {
        caption    => 'In Operator with Data::Accessor',
        key        => 'conditions',
        conditions => [
            {
                left => {
                    name => 'id',
                    view => 'people'
                },
                operator => 'IN',
                right =>{value=>Test::Utils::in_da_sql()}
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
"SELECT people.first_name, people.last_name, people.user_id FROM people WHERE people.id IN (SELECT address.user_id FROM address WHERE address.country = ?)",
            params => ['CA']
        },

        update => {
            container => $container,
            sql =>
"UPDATE people SET first_name = ?, last_name = ? WHERE people.id IN (SELECT address.user_id FROM address WHERE address.country = ?)",
 params => [ 'Bill', 'Bloggings','CA' ]
        },
        delete => {
            sql    => "DELETE FROM people WHERE people.id IN (SELECT address.user_id FROM address WHERE address.country = ?)",
            params => ['CA']
        },
    },
      {
        caption    => 'in left must not be an array-ref',
        type       => 'exception',
        key        => 'conditions',
        conditions => [
          {
        left     => [ { name => 'cost' }, { value => '10000' }, ],
        right    => [ { name => 'cost' }, { value => '10000' }, ],
        operator => 'IN',
    },
        ],
        retrieve =>
          { message => 'left can not be an Array Ref' },
    },
          {
        caption    => 'in right must not be and array ref with a DA and params',
        type       => 'exception',
        key        => 'conditions',
        conditions => [
          {
        left     => { name => 'cost' },
        right    => [{ name => 'cost' } ,{ name => 'price' } ,{value=>Test::Utils::in_da_sql()}],
        operator => 'IN',},
        ],
        retrieve =>
          { message => 'Array Ref can not contain a Database::Accessor' },
    },
     {
        caption    => 'Like operator with regex',
        key        => 'conditions',
        conditions => [
            {
                left => {
                    name => 'last_name',
                    view => 'people'
                },
                operator => 'Like',
                right =>{value=>'Blog%'}
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
"SELECT people.first_name, people.last_name, people.user_id FROM people WHERE people.last_name LIKE ?",
            params => ['Blog%']
        },

        update => {
            container => $container,
            sql =>
"UPDATE people SET first_name = ?, last_name = ? WHERE people.last_name LIKE ?",
 params => [ 'Bill', 'Bloggings','Blog%' ]
        },
        delete => {
            sql    => "DELETE FROM people WHERE people.last_name LIKE ?",
            params => ['Blog%']
        },
    },
     {
        caption    => 'Like operator with regex',
        key        => 'conditions',
        conditions => [
            {
                left => {
                    name => 'last_name',
                    view => 'people'
                },
                operator => 'NOT Like',
                right =>{value=>'Blog%'}
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
"SELECT people.first_name, people.last_name, people.user_id FROM people WHERE people.last_name NOT LIKE ?",
            params => ['Blog%']
        },

        update => {
            container => $container,
            sql =>
"UPDATE people SET first_name = ?, last_name = ? WHERE people.last_name NOT LIKE ?",
 params => [ 'Bill', 'Bloggings','Blog%' ]
        },
        delete => {
            sql    => "DELETE FROM people WHERE people.last_name NOT LIKE ?",
            params => ['Blog%']
        },
    },
     {
        caption    => 'Like left must not be an array-ref',
        type       => 'exception',
        key        => 'conditions',
        conditions => [
          {
        left     => [ { name => 'cost' }, { value => '10000' }, ],
        right    => {value=>'%ogs'},
        operator => 'Like',
        }],
        retrieve =>
          { message => 'left can not be an Array Ref' },
    },
     {
        caption    => 'Like right must not be an array-ref',
        type       => 'exception',
        key        => 'conditions',
        conditions => [
          {
        left     => { name => 'cost' },
        right    => [ { name => 'cost' }, { value => '10000' }, ],
        operator => 'Like',
        }],
        retrieve =>
          { message => 'right can not be an Array Ref' },
    },
    {
        caption    => 'Exists Operator with Data::Accessor',
        key        => 'conditions',
        conditions => [
            {
                left => {value=>Test::Utils::in_da_sql()},
                operator => 'Exists',
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
"SELECT people.first_name, people.last_name, people.user_id FROM people WHERE EXISTS (SELECT address.user_id FROM address WHERE address.country = ?)",
            params => ['CA']
        },

        update => {
            container => $container,
            sql =>
"UPDATE people SET first_name = ?, last_name = ? WHERE EXISTS (SELECT address.user_id FROM address WHERE address.country = ?)",
 params => [ 'Bill', 'Bloggings','CA' ]
        },
        delete => {
            sql    => "DELETE FROM people WHERE EXISTS (SELECT address.user_id FROM address WHERE address.country = ?)",
            params => ['CA']
        },
    },
     {
        caption    => 'Not Exists Operator with Data::Accessor',
        key        => 'conditions',
        conditions => [
            {
                left => {value=>Test::Utils::in_da_sql()},
                operator => 'NOT Exists',
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
"SELECT people.first_name, people.last_name, people.user_id FROM people WHERE NOT EXISTS (SELECT address.user_id FROM address WHERE address.country = ?)",
            params => ['CA']
        },

        update => {
            container => $container,
            sql =>
"UPDATE people SET first_name = ?, last_name = ? WHERE NOT EXISTS (SELECT address.user_id FROM address WHERE address.country = ?)",
 params => [ 'Bill', 'Bloggings','CA' ]
        },
        delete => {
            sql    => "DELETE FROM people WHERE NOT EXISTS (SELECT address.user_id FROM address WHERE address.country = ?)",
            params => ['CA']
        },
    },
     {
        caption    => 'Exists left must be a Param with a value of DA-ref 1',
        type       => 'exception',
        key        => 'conditions',
        conditions => [
          {
        left     => { name => 'cost' },
        operator => 'EXISTS',
        }],
        retrieve =>
          { message => 'left must be a Database::Accessor::Param with' },
    },
    {
        caption    => 'Exists left must be a Param with a value of DA-ref 2',
        type       => 'exception',
        key        => 'conditions',
        conditions => [
          {
        left     => { value=> 'cost' },
        operator => 'EXISTS',
        }],
        retrieve =>
          { message => 'left must be a Database::Accessor::Param with' },
    },
    {
        caption    => 'Any Operator with Data::Accessor',
        key        => 'conditions',
        conditions => [
            {
                left => {value=>Test::Utils::in_da_sql()},
                operator => 'aLl',
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
"SELECT people.first_name, people.last_name, people.user_id FROM people WHERE ALL (SELECT address.user_id FROM address WHERE address.country = ?)",
            params => ['CA']
        },

        update => {
            container => $container,
            sql =>
"UPDATE people SET first_name = ?, last_name = ? WHERE ALL (SELECT address.user_id FROM address WHERE address.country = ?)",
 params => [ 'Bill', 'Bloggings','CA' ]
        },
        delete => {
            sql    => "DELETE FROM people WHERE ALL (SELECT address.user_id FROM address WHERE address.country = ?)",
            params => ['CA']
        },
    },
     {
        caption    => 'All left must be a Param with a value of DA-ref 2',
        type       => 'exception',
        key        => 'conditions',
        conditions => [
          {
        left     => { value=> 'cost' },
        operator => 'ALL',
        }],
        retrieve =>
          { message => "'ALL' left must be a" },
    },
    {
        caption    => 'ANY Operator with Data::Accessor',
        key        => 'conditions',
        conditions => [
            {
                left => {value=>Test::Utils::in_da_sql()},
                operator => 'ANY',
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
"SELECT people.first_name, people.last_name, people.user_id FROM people WHERE ANY (SELECT address.user_id FROM address WHERE address.country = ?)",
            params => ['CA']
        },

        update => {
            container => $container,
            sql =>
"UPDATE people SET first_name = ?, last_name = ? WHERE ANY (SELECT address.user_id FROM address WHERE address.country = ?)",
 params => [ 'Bill', 'Bloggings','CA' ]
        },
        delete => {
            sql    => "DELETE FROM people WHERE ANY (SELECT address.user_id FROM address WHERE address.country = ?)",
            params => ['CA']
        },
    },
];

my $utils = Test::Utils->new();
#my $test = pop(@{$tests});
$utils->sql_param_ok( $in_hash, $tests );
