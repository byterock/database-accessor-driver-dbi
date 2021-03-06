#!perl
use Test::More tests => 3;
use Test::Fatal;

use lib ('D:\GitHub\database-accessor\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\lib');
BEGIN {
    require_ok('Database::Accessor') || print "Bail out!";
    require_ok('DBI')                || print "Bail out!";
}
my $in_hash = { da_compose_only=>1,
                view => { name  => 'name' },
                 elements => [ { name => 'last_name', }, { name => 'first_name', }, ]};
my $da      = Database::Accessor->new($in_hash);
my $dbh     = DBI->connect("dbi:ExampleP:", '', '');

eval { $da->retrieve( $dbh); };

if ($@) {
    fail("Can not load Database::Accessor::Driver::DBI error=$@");
}
else {
    pass("Database::Accessor::Driver::DBI Loaded");
}
