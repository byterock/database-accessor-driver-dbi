
#!perl
use DBI;
use Data::Dumper;
use Cwd;
my $dir = getcwd;
warn("dir=".$dir);

my $dbh = DBI->connect('dbi:DBM:',undef,undef,{f_dir=>$dir."/test/db"});
my @sql = (qw {DROP TABLE IF EXISTS users},
           qw {CREATE TABLE users ( username TEXT, address TEXT)},
           qw {INSERT INTO users VALUES ( 'user1',  1)},
           qw {INSERT INTO users VALUES ( 'user2',  2)},
);
foreach my $sql (@sql ){
  $dbh->do($sql);
}

my $sth = $dbh->prepare("SELECT * FROM users");
$sth->execute;
$sth->dump_results if $sth->{NUM_OF_FIELDS};
$dbh->disconnect;
