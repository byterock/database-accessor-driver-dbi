#!perl
use Test::More  tests => 11;
use Test::Fatal;
use lib ('D:\GitHub\database-accessor\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\t\lib');
use Data::Dumper;
use DBI;

use Test::Utils;
use Test::DB::User;
my $utils = Test::Utils->new();
$utils->create_users_table();
my $db_user = Test::DB::User->new();
my $user = $db_user->da();

my $container =  {username=>'user_new',
                  address =>'address_new'};

ok($user->create($utils->connect(),
                 $container),"Create function");
ok($user->result()->effected == 1,"One row effected");

delete($container->{username});
$container->{address} ='Achanged';
$user->add_condition({left  =>{ name  => 'username',
                                view  => 'user'},
                      right =>{ value => 'user_new'}
                    });
                    
                  
ok($user->update($utils->connect(),$container),"Update function");
ok($user->result()->effected == 1,"one row effected");
ok($user->retrieve($utils->connect()),"retrieve function");
ok(scalar(@{$user->result()->set}) == 1,"One row returned");
unless($user->result()->is_error) {
   ok($user->result()->set->[0]->[1] eq 'Achanged','address changed');
}
else{
   fail("No Result set->[0]->[1]");
}
ok($user->delete($utils->connect()),"delete function");
ok($user->result()->effected == 1,"One row Deleted");
ok($user->retrieve($utils->connect()),"retrieve function");
unless($user->result()->is_error) {
  ok(scalar(@{$user->result()->set}) == 1,"one row in DB");
}else{
   fail("No Result set");
}

use Test::User;

$container = [Test::User->new({username=>'Bill',address =>'ABC'}),
              {username=>'Jane',address =>'DEF'},
              Test::User->new({username=>'John',address =>'HIJ'}),
              {username=>'Joe',address =>'KLM'},
              ];
ok($user->create( $utils->connect(),$container),"Execute Array add 4");
unless($user->result()->is_error) {
  ok(scalar(@{$user->result()->set}) == 4,"Four records added");
}else{
   fail("Execute Array failed");
}

ok($user->update( $utils->connect(),$container),"update with present container");

$user->reset_conditions();
$container = [{address =>'MNO'},
              {address =>'PQR'},
              {address =>'STU'},
              ];
$user->add_condition({left  =>{ name  => 'username',
                                view  => 'user'},
                      right =>{ value => ['Bill','Jane','Joe']}
                    });

ok($user->update( $utils->connect(),$container),"update array on where param");

$user->reset_conditions();
$container = {address =>'VWX'};
$user->add_condition({left  =>{ name  => 'username',
                                view  => 'user'},
                      right =>{ value => ['Bill','Jane','Joe']}
                    });
ok($user->update( $utils->connect(),$container),"update hash container with an array");

use Database::Accessor;
my $other_user = Database::Accessor->new({view=>{name=>'user'},
                                          elements=>[{name=>'username'}],
                                          conditions=>{left  =>{ name  => 'username',
                                view  => 'user'},
                      right =>{ value => 'Bill'}}});
                    
$user->da_compose_only(1);
$user->reset_conditions();
$user->add_condition({left  =>{ name  => 'username',
                                view  => 'user'},
                      right =>{ value => $other_user}
                    });
                    
ok($user->retrieve($utils->connect()),"retrieve function");

 # warn(Dumper($other_user->result()));
#  warn(Dumper($user));
# my $dbh = $utils->connect();
# my $sth = $dbh->prepare("SELECT * FROM user");
# $sth->execute;
# $sth->dump_results if $sth->{NUM_OF_FIELDS};


