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
                    function => 'substr',
                    left     => { name => 'first_name' },
                    right    => [ { param => 1 }, { param => 5 } ]
                },
                right     => { value => 'Tommy' },
                operator  => '=',
            },);

$da->retrieve($dbh);
cmp_deeply( $da->result()->set, $updated_people,
            "All 4 users retrieved correctly with function");


$da->reset_conditions();

$da->add_condition( 
{
                left => {
                    expression => '*',
                    left       => { name => 'id' },
                    right      => { param => '3' }
                },
                right     => { value => '12' },
                operator  => '<=',
            }
);

$da->retrieve($dbh);
my $people = $user_db->people_data();
shift(@{$people});
splice(@{$people},3,9);


cmp_deeply( $da->result()->set, $people,
            "correct 3 users selected with expression");

shift(@{$people});

$da->add_condition( 
{               condition => 'AND',
                left => {
                    expression => '*',
                    left       => { name => 'id' },
                    right      => { param => '3' }
                },
                right     => { value => '6' },
                operator  => '!=',
            }
);
$da->retrieve($dbh);
cmp_deeply( $da->result()->set, $people,
            "correct 2 users selected with two expressions");


$da->reset_conditions();

 
$da->add_condition({
                left => {ifs=>[{ left      => { name => 'id', },
                          right     => { value => '5' },
                          operator  => '<=',
                          then=>{value=>'4 and under'}},
                        [{left      => { name =>'id'},
                          right     => { value => '5' },
                          operator   => '>',
                         },
                         { condition => 'and',
                           left      => {name=>'id'},
                           right     => { value => '8' },
                           operator  => '<=',
                           then=>{value=>'5 to 8'}}
                        ],
                        { then=>{value=>'9 and Over'}},
                        ],},
                right     => { value => '5 to 8' },
                operator  => '=',
                condition => 'AND'
            });
pop(@{$updated_people});
$da->retrieve($dbh);
cmp_deeply( $da->result()->set, $updated_people,
            "correct 3 users selected with case statement");
            
     