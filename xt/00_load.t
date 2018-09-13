#!perl
use Test::More tests => 6;

use lib ('D:\GitHub\database-accessor\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\xt\lib');


my $connect = $ENV{DAD_TEST_CONNECT_STR} || "DBI:Oracle:"; 
my $uid     = $ENV{DAD_TEST_UID} || "HR";
my $pw      = $ENV{DAD_TEST_PW} || "hr";
my $opts    = $ENV{DAD_TEST_OPTS} || {RaiseError=>0};



BEGIN {
    
    require_ok('Database::Accessor') || print "Bail out!";
    require_ok('DBI')                || print "Bail out!";
    
}
my $in_hash = { da_compose_only=>1,
                view => { name  => 'name' },
                elements => [ { name => 'last_name', }, { name => 'first_name', }, ]};
my $da      = Database::Accessor->new($in_hash);
my $dbh      = DBI->connect( $connect, $uid, $pw, $opts );


eval { $da->retrieve( $dbh ); };
# use Data::Dumper;
# warn("retrunt ".Dumper($da));
if ($@) {
    fail("Can not load Database::Accessor::Driver::DBI error=$@");
}
else {
    pass("Database::Accessor::Driver::DBI Loaded for DBD $connect");
}

delete($in_hash->{da_compose_only});
$in_hash->{view}->{name}='12@@###';
$da      = Database::Accessor->new($in_hash);
eval { $da->retrieve( $dbh ); };

use Data::Dumper;
# warn("retrunt ".Dumper($da));
if ($da->result->is_error()) {
    pass("Got an error from the DB $connect");
}
else {
    fail("Did not get an error on DB $connect");
}

ok(!$dbh->{RaiseError},'RaiseError still off');
ok($dbh->{PrintError} = 1,'PrintError still on');