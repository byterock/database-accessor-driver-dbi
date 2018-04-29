#!perl
use Test::More;
use Test::Fatal;
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
