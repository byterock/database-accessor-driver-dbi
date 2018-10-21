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
my $updated_people = $user_db->updated_people_data();
my $person= Xtest::DA::Person->new();
my $da = $person->da();
$da->add_sort({name=>'id'});

$da->add_condition( {
               
                left => {
                    name => 'id',
                    view => 'people'
                },
                right    => [ { value => 6 }, { value => 9 } ],
                operator => 'BETWeeN',
            
            },);

$da->retrieve($dbh);

cmp_deeply( $da->result()->set, $updated_people,
            "All 4 users retrieved correctly with between");

$da->reset_conditions();

$da->add_condition( 
 {
                left => {
                    name => 'id',
                    view => 'address'
                },
                operator => 'Is Null',
            },
);

$da->retrieve($dbh);

cmp_deeply( $da->result()->set, $updated_people,
            "All 4 users retrieved correctly with is null");

$da->reset_conditions();
$da->add_condition( 
    {
                left => {
                    name => 'id',
                    view => 'people'
                },
                operator => 'In',
                right => [{value=>'6'},
                         {value=>'7'},
                         {value=>'8'},
                         {value=>'9'},]
            },
);

$da->retrieve($dbh);

cmp_deeply( $da->result()->set, $updated_people,
            "All 4 users retrieved with in ");


$da->reset_conditions();
use Xtest::DA::Address;
my $address =  Xtest::DA::Address->new();
my $address_da = $address->da();
$address_da->only_elements({id=>1});
my $people = $user_db->people_data();
shift($people);
splice($people,4,9);
$people->[3]->[1]= 'Diego';
$da->add_condition( 
    {
                left => {
                    name => 'id',
                    view => 'address'
                },
                operator => 'In',
                right =>{value=>$address_da}
            },
);

$da->retrieve($dbh);
cmp_deeply( $da->result()->set, $people,
            "All 4 users retrieved with in using a DA ");

$da->reset_conditions();
$da->add_condition( 
           {
                left => {
                    name => 'user_id',
                    view => 'people'
                },
                operator => 'Like',
                right =>{value=>'atkinst%'}
            },
);
$da->retrieve($dbh);
cmp_deeply( $da->result()->set, $updated_people,

            "All 4 users retrieved with Like ");
$da->reset_conditions();
$da->add_condition( 
           {
                left => {
                    name => 'user_id',
                    view => 'people'
                },
                operator => 'Not Like',
                right =>{value=>'atkinst%'}
            },
);
$da->retrieve($dbh);
cmp_deeply( $da->result()->set, $people,

            "All 4 users retrieved with not Like ");
