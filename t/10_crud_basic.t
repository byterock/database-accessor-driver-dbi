#!perl
use lib ('D:\GitHub\database-accessor\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\t\lib');


#use Test::More tests => 3;
#use Test::Fatal;
use DBI;
use Database::Accessor;
use Test::DB::User;
use Data::Dumper;
do 'scripts\new_db.pl';

exit;
my $user = Test::DB::User->new();

warn("Dumper ".Dumper($user));
exit;
#my $dbh = DBI->connect('dbi:DBM:',undef,undef,{f_dir=>"db"});
#my $container = {};

my $user->create($dbh,{username=>'user_new',
                       address =>'address_new'});
                  
