#!perl
use Test::More tests => 17;
use Test::Fatal;
use lib ('D:\GitHub\database-accessor\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\xt\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\xt\lib');

use Data::Dumper;

use Xtest::DB::Users;
use Xtest::DA::Person;
use Test::Deep qw(cmp_deeply);
use JSON qw(decode_json);
my $user_db    = Xtest::DB::Users->new();
my $dbh        = $user_db->connect();
my $new_person = $user_db->new_person_data->[0];
$new_person->{first_name} = 'Diego';
my $person = Xtest::DA::Person->new();
my $da     = $person->da();
$da->add_condition(
    {
        left     => { name  => 'user_id', },
        right    => { value => $new_person->{user_id} },
        operator => '=',
    }
);

my $expected = {
    Lower  => $new_person,
    Upper  => $user_db->new_person_data->[1],
    Native => $user_db->new_person_data->[2]
};


foreach my $case (qw(Lower Upper Native)) {
    $da->da_key_case($case);
    foreach my $set_type (qw(HashRef JSON)) {
        $da->da_result_set($set_type);
        my $type = "is_$set_type";
        ok( $da->$type == 1, "return set is a $set_type" );
        if ( $da->is_Class ) {
            
        }
  
        $da->retrieve($dbh);
        my $results;
        
        if ( $da->is_JSON ) {
            eval { $results = decode_json( $da->result()->set->[0] ); };
            if ($@) {
                fail( "Result set for $case is not Json! Error=" . $@ );
            }
            else {
                pass("Result set for $case is Json");
            }
        }
        else {
            $results = $da->result()->set->[0];
        }
        cmp_deeply( $results, $expected->{$case},
            "$set_type for $case returned with correct data" );

    }
}

    $da->da_result_class("Xtest::DA::Person");
    $da->da_result_set("Class");
     $da->da_key_case("Lower");
    $da->retrieve($dbh);
    my  $class = $da->result()->set->[0];
    ok(ref($class) eq "Xtest::DA::Person","Result set is correct class");
    ok(!$class->time_zone,"time_zone not set");
    delete( $expected->{"Lower"}->{'time zone'});
    cmp_deeply({%$class}, $expected->{"Lower"},"Class properties all set");
    

