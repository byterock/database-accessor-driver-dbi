#!perl
use Test::More  tests => 17;
use Test::Fatal;
use lib ('D:\GitHub\database-accessor\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\xt\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\xt\lib');
         
use Data::Dumper;
use DBI;

use Xtest::DB::Users;
use Xtest::DA::Person;

my $user_db = Xtest::DB::Users->new();
$user_db->create_db();
my $dbh = $user_db->connect();
my $person= Xtest::DA::Person->new($user_db->new_person_data->[0]);
my $da = $person->da();
ok($da->create($dbh,$person),"Create New User");
ok($da->result()->effected == 1,"One row effected");
  
warn("person=".Dumper($da->result()));




