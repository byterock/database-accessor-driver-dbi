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


$container = [{username=>'Bill',address =>'ABC'},
              {username=>'Jane',address =>'DEF'},
              {username=>'John',address =>'HIJ'},
              {username=>'Joe',address =>'KLM'},
              ];


$user->create( $utils->connect(),$container);
#ok($user->retrieve($utils->connect()),"retrieve function");
