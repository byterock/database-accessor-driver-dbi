#!perl
use Test::More  tests => 12;
use Test::Fatal;
use lib ('D:\GitHub\database-accessor\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\t\lib');
use Data::Dumper;
use DBI;
use Database::Accessor;
use Test::Utils;
use Test::DB::User;
my $utils = Test::Utils->new();
$utils->create_users_table();
my $user = Test::DB::User->new();
my $container =  {username=>'user_new',
                  address =>'address_new'};

eval{
   $user->create($utils->connect(),
                 $container);
};

if ($@) {
    fail("Create function error=$@");
}
else {
    pass("Create function");
}

ok($user->result()->effected == 1,"One row effected");

$container->{username} ='Uchanged';
$container->{address} ='Achanged';

eval{
   $user->update($utils->connect(),
                 $container);
};

if ($@) {
    fail("Update function error=$@");
}
else {
    pass("Update function");
}

ok($user->result()->effected == 2,"Two rows effected");

eval{
   $user->retrieve($utils->connect());
};

if ($@) {
    fail("retrieve function error=$@");
}
else {
    pass("retrieve function");
}

ok(scalar(@{$user->result()->set}) == 1,"One row returned");
ok($user->result()->set->[0]->[0] eq 'Uchanged','username changed');
ok($user->result()->set->[0]->[1] eq 'Achanged','address changed');

eval{
   $user->delete($utils->connect());
};

if ($@) {
    fail("delete function error=$@");
}
else {
    pass("delete function");
}

ok($user->result()->effected == 1,"One row Deleted");

eval{
   $user->retrieve($utils->connect());
};

if ($@) {
    fail("retrieve function error=$@");
}
else {
    pass("retrieve function");
}

ok(scalar(@{$user->result()->set}) == 0,"Nothing in DB");
