#!perl
use Test::More;
use Test::Fatal;
use lib ('D:\GitHub\database-accessor\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\t\lib');
use DBI;
use Database::Accessor;
use Test::Utils;
use Test::DB::User;
 $ENV{da_warning}=5;
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
