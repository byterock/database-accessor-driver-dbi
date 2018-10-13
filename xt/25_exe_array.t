#!perl
use Test::More  tests => 17;
use Test::Fatal;
use lib ('D:\GitHub\database-accessor\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\xt\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\xt\lib');
         
use Data::Dumper;

use Xtest::DB::Users;
use Xtest::DA::Person;
use Test::Deep qw(cmp_deeply);

my $user_db = Xtest::DB::Users->new();
my $dbh = $user_db->connect();
my $people = $user_db->new_person_data;
splice(@{$people},0,3);

my $person= Xtest::DA::Person->new();
my $da = $person->da();
$da->da_no_effect(1);
ok($da->create($dbh,$people),"Create Four New Users ");
ok($da->result()->effected == 4,"Four row effected");





# warn("person=".Dumper($da->result()));
 
$da = $person->da();
$da->add_condition({
                left => {
                    name => 'first_name',
                },
                right     => { value => $people->[0]->{first_name}},
                operator  => '=',
            });

$da->retrieve($dbh);

my $all_people = $user_db->_people_data();
splice($all_people,0,5);

cmp_deeply( $da->result()->set, $all_people,
            "All 4 users added correctly");

$da->reset_conditions();

my $update_ids = $user_db->update_people_id_data();
my $update_people = $user_db->update_people_data();
my $updated_people = $user_db->updated_people_data();

$da->add_condition({
                left => {
                    name => 'id',
                },
                right     => { value => $update_ids},
                operator  => '=',
            });



ok($da->update($dbh,$update_people),"Update Four New Users ");

ok($da->result()->effected == 4,"Four row effected");

