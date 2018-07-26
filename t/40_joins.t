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
    da_compose_only => 1,
    view            => { name => 'people' },
    elements        => [
        {
            name => 'first_name',

            # view => 'people'
        },
        {
            name => 'last_name',
            view => 'people'
        },
        {
            name => 'id',
            view => 'people'
        },
        {
            name => 'street',
            view => 'address'
        },
    ],
    conditions => [
        {
            left => {
                name => 'first_name',

                #view => 'people'
            },
            right => { value => 'test1' },
        },
    ],
    links => []
};


my $container = {
    last_name  => 'Bloggings',
    first_name => 'Bill',
};

my $tests = [
    {
        caption  => "Left Link with 1 condition",
         index => 0,
            key   => 'links',
            links => {
                type       => 'LEFT',
                to         => { name => 'address' },
                conditions => [
                    {
                        left  => { name => 'id' },
                        right => {
                            name => 'user_id',
                            view => 'address'
                        }
                    }
                ]
            },
        retrieve => {
            sql =>
"SELECT people.first_name, people.last_name, people.id, address.street FROM people LEFT JOIN address ON people.id = address.user_id WHERE people.first_name = ?",
            params => ['test1']
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
"UPDATE people SET first_name = ?, last_name = ? LEFT JOIN address ON people.id = address.user_id WHERE people.first_name = ?",
            params => [ 'Bill', 'Bloggings', 'test1' ]
        },
        delete => {
            sql    => "DELETE FROM people LEFT JOIN address ON people.id = address.user_id WHERE people.first_name = ?",
            params => ['test1']
        },
    },
     {
        caption  => "Left Link with 1 condition and alias",
         index => 0,
            key   => 'links',
            links => {
                type       => 'LEFT',
                to         => { name => 'address',
                                alias=>  'test' },
                conditions => [
                    {
                        left  => { name => 'id' },
                        right => {
                            name => 'user_id',
                        }
                    }
                ]
            },
        retrieve => {
            sql =>
"SELECT people.first_name, people.last_name, people.id, address.street FROM people LEFT JOIN address test ON people.id = test.user_id WHERE people.first_name = ?",
            params => ['test1']
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
"UPDATE people SET first_name = ?, last_name = ? LEFT JOIN address test ON people.id = test.user_id WHERE people.first_name = ?",
            params => [ 'Bill', 'Bloggings', 'test1' ]
        },
        delete => {
            sql    => "DELETE FROM people LEFT JOIN address test ON people.id = test.user_id WHERE people.first_name = ?",
            params => ['test1']
        },
    }, 
    {
        caption  => "Left Link with 2 conditions",
         index => 0,
            key   => 'links',
            links => {
                type       => 'LEFT',
                to         => { name => 'address' },
                conditions => [
                    {
                        left  => { name => 'id' },
                        right => {
                            name => 'user_id',
                            view => 'address'
                        }
                    },
                     {
                        left  => { name => 'id' },
                        right => {
                            value => '1234',
                        },
                        condition=>'AND'
                    }
                ]
            },
        retrieve => {
            sql =>
"SELECT people.first_name, people.last_name, people.id, address.street FROM people LEFT JOIN address ON people.id = address.user_id AND people.id = ? WHERE people.first_name = ?",
            params => ['1234','test1']
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
"UPDATE people SET first_name = ?, last_name = ? LEFT JOIN address ON people.id = address.user_id AND people.id = ? WHERE people.first_name = ?",
            params => [ 'Bill', 'Bloggings', '1234','test1' ]
        },
        delete => {
            sql    => "DELETE FROM people LEFT JOIN address ON people.id = address.user_id AND people.id = ? WHERE people.first_name = ?",
            params => ['1234','test1']
        },
    },
      {
        caption  => "Left and Right Link with 1 condition",
         index => 0,
            key   => 'links',
            links => [{
                type       => 'LEFT',
                to         => { name => 'address' },
                conditions => [
                    {
                        left  => { name => 'id' },
                        right => {
                            name => 'user_id',
                            view => 'address'
                        }
                    }
                ]
            },
            {
                type       => 'RIGHT',
                to         => { name => 'phone' },
                conditions => [
                    {
                        left  => { name => 'phone_id' },
                        right => {
                            value=>'1234567890'
                        }
                    }
                ]
            }],
        retrieve => {
            sql =>
"SELECT people.first_name, people.last_name, people.id, address.street FROM people LEFT JOIN address ON people.id = address.user_id RIGHT JOIN phone ON people.phone_id = ? WHERE people.first_name = ?",
            params => ['1234567890','test1']
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
"UPDATE people SET first_name = ?, last_name = ? LEFT JOIN address ON people.id = address.user_id RIGHT JOIN phone ON people.phone_id = ? WHERE people.first_name = ?",
            params => [ 'Bill', 'Bloggings', '1234567890', 'test1' ]
        },
        delete => {
            sql    => "DELETE FROM people LEFT JOIN address ON people.id = address.user_id RIGHT JOIN phone ON people.phone_id = ? WHERE people.first_name = ?",
            params => ['1234567890','test1']
        },
    },
     {
        caption  => "Left Link with 1 function != condition",
         index => 0,
            key   => 'links',
            links => {
                type       => 'LEFT',
                to         => { name => 'address' },
                conditions => [
                    { operator=>"!=",
                        left  => { name => 'id' },
                        right =>  {
                              function => 'left',
                              left     => { name => 'city_id',
                                            view => 'address' },
                              right    => { param => 11 }
            }
                    }
                ]
            },
        retrieve => {
            sql =>
"SELECT people.first_name, people.last_name, people.id, address.street FROM people LEFT JOIN address ON people.id != left(address.city_id,?) WHERE people.first_name = ?",
            params => ['11','test1']
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
"UPDATE people SET first_name = ?, last_name = ? LEFT JOIN address ON people.id != left(address.city_id,?) WHERE people.first_name = ?",
            params => [ 'Bill', 'Bloggings','11','test1' ]
        },
        delete => {
            sql    => "DELETE FROM people LEFT JOIN address ON people.id != left(address.city_id,?) WHERE people.first_name = ?",
            params => ['11','test1']
        },
    },
];

use Test::More tests => 40;

my $utils = Test::Utils->new();
$utils->sql_param_ok( $in_hash, $tests );

# my $da     = Database::Accessor->new($in_hash);
# my $dbh = $utils->connect();

# foreach my $test (@{$tests}){

# $utils->sql_param_ok($dbh,$in_hash,$test);

# }

