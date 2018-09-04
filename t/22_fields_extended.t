#!perl
use Test::More tests => 10;
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
    view                      => { name => 'Products' },
    elements                  => [
        {
            ifs => [
                {
                    left      => { name  => 'Price', },
                    right     => { value => '10' },
                    operator  => '<',
                    then => { value => 'under 10$' }
                },
                [
                    {
                        left     => { name  => 'Price' },
                        right    => { value => '10' },
                        operator => '>=',
                    },
                    {
                        condition => 'and',
                        left      => { name => 'Price' },
                        right     => { value => '30' },
                        operator  => '<=',
                        then => { value => '10~30$' }
                    }
                ],
                [
                    {
                        left     => { name  => 'Price' },
                        right    => { value => '30' },
                        operator => '>',
                    },
                    {
                        condition => 'and',
                        left      => { name => 'Price' },
                        right     => { value => '100' },
                        operator  => '<=',
                        then => { value => '30~100$' }
                    }
                ],
                { then => { value => 'Over 100$' } },
            ],
            alias => 'price_group'
        }
    ]
};

my $container = {
    last_name  => 'Bloggings',
    first_name => 'Bill',
};

my $tests = [
    {
        caption  => 'Retrieve with case then in elements',
        retrieve => {
            sql =>
"SELECT CASE WHEN Products.Price < ? THEN ? WHEN Products.Price >= ? AND Products.Price <= ? THEN ? WHEN Products.Price > ? AND Products.Price <= ? THEN ? ELSE ? END price_group FROM Products",
            params => [
                10, 'under 10$', 10, 30, '10~30$', 30, 100, '30~100$',
                'Over 100$'
            ]
        },

    },
    {
        caption  => 'Retrieve with case using In clause',
        key      => 'elements',
        elements => [
            {
                ifs => [
                    {
                        left      => { name  => 'Price', },
                        right     => { value => '100' },
                        operator  => '<',
                        then => { value => 'under 100$' }
                    },
                    {
                        left  => { name => 'Price' },
                        right => [
                            { value => '105' },
                            { value => '110' },
                            { value => '120' },
                        ],
                        operator => 'IN',
                        then => { value => 'Price 105,110 or 120$' } 
                    },
                    { then => { value => 'Over 120$' } },
                ]
            }
        ],
        retrieve => {
            sql =>
"SELECT CASE WHEN Products.Price < ? THEN ? WHEN Products.Price IN (?,?,?) THEN ? ELSE ? END FROM Products",
            params => [
                100, 'under 100$', 105, 110,120, 'Price 105,110 or 120$','Over 120$'
            ]
        },

    },
    {
        caption  => 'Retrieve with case parentheses',
        key      => 'elements',
        elements => [
            {
                ifs => [
                    {
                        left      => { name  => 'Price', },
                        right     => { value => '10' },
                        operator  => '<',
                        then => { value => 'under 10$' }
                    },
                    [
                    {
                        left     => { name  => 'Price' },
                        right    => { value => '10' },
                        operator => '>=',
                        open_parentheses =>1
                    },
                    {
                        condition => 'and',
                        left      => { name => 'Price' },
                        right     => { value => '30' },
                        operator  => '<=',
                        close_parentheses=>1
                    },
                    {
                        left     => { name  => 'Price' },
                        right    => { value => '40' },
                        operator => '>=',
                        condition => 'OR',
                        open_parentheses =>1
                    },
                    {
                        condition => 'and',
                        left      => { name => 'Price' },
                        right     => { value => '50' },
                        operator  => '<=',
                        then => { value => '10~30$ or 40~50$' },
                        close_parentheses=>1
                    }
                    ],
                    { then => { value => 'Over 50$' } },
                ]
            }
        ],
        retrieve => {
            sql =>
"SELECT CASE WHEN Products.Price < ? THEN ? WHEN ( Products.Price >= ? AND Products.Price <= ? ) OR ( Products.Price >= ? AND Products.Price <= ? ) THEN ? ELSE ? END FROM Products",
            params => [
                10, 'under 10$', 10,30,40,50,'10~30$ or 40~50$','Over 50$'
            ]
        },
    },
        {
        caption  => 'Retrieve with case using only elements',
        key      => 'elements',
        elements => [
            {
                ifs => [
                    {
                        left      => { name  => 'Sale_Price', },
                        right     => { name  => 'Price',},
                        operator  => '<',
                        then => { value => 'On Sale' }
                    },
                    {
                        left  => { name => 'Sale_Price' },
                        right => { name => 'Price',},
                        operator => '>',
                        then => { value => 'Premium Price' } 
                    },
                    { then => { value => 'Normal Price' } },
                ]
            }
        ],
        retrieve => {
            sql =>
"SELECT CASE WHEN Products.Sale_Price < Products.Price THEN ? WHEN Products.Sale_Price > Products.Price THEN ? ELSE ? END FROM Products",
            params => [
                'On Sale','Premium Price','Normal Price'
            ]
        },

    },
    {
        caption  => 'Retrieve with case in a case',
        key      => 'elements',
        elements => [
            {
                ifs => [
                    {
                        left      => { name  => 'On_Sale', },
                        right     => { value => 1,},
                        operator  => '=',
                        then => { ifs=>[{left     => {name =>'Stock'},
                                                right    => {value=>10},
                                                operator => '<=',
                                                then=> {value=>.2}},
                                               [{left     => {name =>'Stock'},
                                                right    => {value=>10},
                                                operator => '>'},
                                                {left     => {name =>'Stock'},
                                                right    => {value=>100},
                                                operator => '<=',
                                                condition=> 'AND',                                                
                                                then=> {value=>.1}}],
                                               {then=> {value=>.05}}] },
                    },
                    {
                        left  => { name => 'On_Sale' },
                        right => { value=> 2,},
                        operator => '=',
                        then => { value => .5 } 
                    },
                    { then => { value => 1 } },
                ],
                alias=>'Discount'
            }
        ],
        retrieve => {
            sql =>
"SELECT CASE WHEN Products.On_Sale = ? THEN CASE WHEN Products.Stock <= ? THEN ? WHEN Products.Stock > ? AND Products.Stock <= ? THEN ? ELSE ? END WHEN Products.On_Sale = ? THEN ? ELSE ? END Discount FROM Products",
            params => [
                1,10,.2,10,100,.1,.05,2,.5,1
            ]
        },

    },
];

# my $test = shift(@{$tests});

$utils->sql_param_ok( $in_hash,$tests );
