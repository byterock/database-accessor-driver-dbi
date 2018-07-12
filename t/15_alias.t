#!perl
use Test::More  tests => 7;
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
    update_requires_condition=>0,
    delete_requires_condition=>0,
    view     => { name => 'people',
                  alias=> 'sys_users' },
    elements => [
        {
            name => 'last_name',
        },
        {
            name => 'first_name',
        },
    ],  
};
my $container =  {first_name=>'Bill',
                  last_name =>'Bloggings'};
my $da  = Database::Accessor->new($in_hash);

my $tests = [{
    caption =>'Basic Table Alias',
    create  =>{container=>{first_name=>'Bill',
                           last_name =>'Bloggings'},
               sql      =>"INSERT INTO people ( first_name, last_name ) VALUES( ?, ? )",
               params   =>['Bill','Bloggings']},
               
    retrieve=>{sql      =>"SELECT sys_users.last_name, sys_users.first_name FROM people sys_users"},
    update  =>{container=>{first_name=>'Robert'},
               sql      =>"UPDATE people SET first_name = ?"},
               params   =>['robert'],
    delete  =>{sql      =>"DELETE FROM people"},
               
}];


$utils->sql_param_ok($in_hash,$tests);

# $da->create( $utils->connect(),$container);
# ok($da->result()->query() eq "INSERT INTO people sys_users ( sys_users.first_name, sys_users.last_name ) VALUES( ?, ? )","create SQL correct");
# $da->retrieve( $utils->connect());
# ok($da->result()->query() eq "SELECT sys_users.last_name, sys_users.first_name FROM people sys_users","retrieve SQL correct");
  # #                            SELECT sys_users.last_name, sys_users.first_name FROM AS sys_users
# $da->update( $utils->connect(),$container);
# ok($da->result()->query() eq "UPDATE people sys_users SET sys_users.first_name = ?, sys_users.last_name = ?","update SQL correct");
# $da->delete( $utils->connect());
# ok($da->result()->query() eq "DELETE FROM people sys_users","Delete SQL correct");
                  

# $in_hash->{elements}->[0]->{view} = 'users';
# $da  = Database::Accessor->new($in_hash);
# $da->create( $utils->connect(),$container);
# ok($da->result()->query() eq "INSERT INTO people sys_users ( sys_users.first_name ) VALUES( ? )","create SQL correct");
# $da->retrieve( $utils->connect());
# ok($da->result()->query() eq "SELECT users.last_name, sys_users.first_name FROM people sys_users","retrieve SQL correct");
# $da->update( $utils->connect(),$container);
# ok($da->result()->query() eq "UPDATE people sys_users SET sys_users.first_name = ?","update SQL correct");

