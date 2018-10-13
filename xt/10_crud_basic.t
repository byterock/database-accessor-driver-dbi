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
use Xtest::DA::Address;
use Xtest::DA::PeopleAddress;
use Xtest::DA::People;
use Test::Deep qw(cmp_deeply);

my $user_db = Xtest::DB::Users->new();
$user_db->create_db();
my $dbh = $user_db->connect();
my $new_person = $user_db->new_person_data->[0];

my $person= Xtest::DA::Person->new({first_name=>$new_person->{first_name},
                                    last_name=>$new_person->{last_name},
                                      user_id=>$new_person->{user_id}});
my $address= Xtest::DA::Address->new({ street=>$new_person->{street},
                                       city=>$new_person->{city},
                                       postal_code=>$new_person->{postal_code},
                                       country_id=>$new_person->{country_id},
                                       region_id=>$new_person->{region_id},
                                       time_zone_id=>$new_person->{time_zone_id},
                                       });

my $person_address= Xtest::DA::PeopleAddress->new({people_id =>$new_person->{id},
                                                   address_id=>$new_person->{address_id},
                                                   primary_ind=>1,});

my $da = $person->da();
ok($da->create($dbh,$person),"Create New User");
ok($da->result()->effected == 1,"One row effected");
# warn("person=".Dumper($da->result()));

$da = $address->da();

ok($da->create($dbh,$address),"Create New Address");
ok($da->result()->effected == 1,"One row effected");

# warn("person=".Dumper($da->result()));

$da = $person_address->da();

ok($da->create($dbh,$person_address),"Create New Person Address");
ok($da->result()->effected == 1,"One row effected");



# warn("person=".Dumper($da->result()));
 
$da = $person->da();

  
$da->add_condition({
                left => {
                    name => 'user_id',
                },
                right     => { value => $new_person->{user_id }},
                operator  => '=',
            });


$da->retrieve($dbh);

my $test_data = $user_db->people_data->[4];
cmp_deeply( $da->result()->set->[0], $test_data,
            "Single Person result correct");

$test_data = $user_db->people_data;
splice($test_data,5,8);

$da->reset_conditions();
$da->add_sort({name=>'id'});

$da->retrieve($dbh);

 # warn("person=".Dumper($da->result()->set));
 # warn("person=".Dumper($test_data));
cmp_deeply( $da->result()->set, $test_data,
            "All Persons result correct");

my $persons = Xtest::DA::People->new();
my $persons_da = $persons->da();
$persons_da->add_sort({name=>'user_id'});
$test_data = $user_db->persons_data;
$persons_da->retrieve($dbh);
cmp_deeply( $persons_da->result()->set, $test_data,
            "People results correct");


$da->add_condition({
                left => {
                    name => 'user_id',
                },
                right     => { value => $new_person->{user_id }},
                operator  => '=',
            });

$da->update($dbh,$user_db->update_person_data);
$da->retrieve($dbh);
cmp_deeply( $da->result()->set->[0], $user_db->updated_person_data,
            "Update person results correct");

$da->reset_conditions();
$da->add_condition({
                left => {
                    name => 'user_id',
                },
                right     => { value => $test_data->[1]->[3]},
                operator  => '=',
            });


$da->delete($dbh);
$da->retrieve($dbh);

cmp_deeply( $da->result()->set, [],
            "Delete person results correct");
