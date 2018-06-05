#!perl
use Test::More  tests => 3;
use Test::Fatal;
use lib ('D:\GitHub\database-accessor\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\t\lib');
use Data::Dumper;
use Database::Accessor;
use Test::Deep;
use Test::Utils;
my $utils = Test::Utils->new();

    da_compose_only=>1,
    update_requires_condition=>0,
    delete_requires_condition=>0,
    view     => { name => 'people',
                  },
    elements => [
        {
            name => 'last_name',
            alias=> 'last'
        },
        {
            name => 'first_name',
            alias=> 'first'
        },
    ],  
};
my $container =  {last_name =>'Bloggings',
                  first_name=>'Bill',
                  };
                  
$da  = Database::Accessor->new($in_hash);
$da->create( $utils->connect(),$container);
ok($da->result()->query() eq "INSERT INTO people ( people.first_name, people.last_name ) VALUES( ?, ? )","create SQL correct");
$da->retrieve( $utils->connect());
ok($da->result()->query() eq "SELECT people.last_name AS last, people.first_name AS first FROM people","retrieve SQL correct");
$da->update( $utils->connect(),$container);
ok($da->result()->query() eq "UPDATE people SET people.first_name = ?, people.last_name = ?","update SQL correct");
