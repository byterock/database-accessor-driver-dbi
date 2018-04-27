
#!perl
use DBI;
use Data::Dumper;
use Cwd;
my $dir = getcwd;
warn("dir=".$dir);

my $dbh = DBI->connect('dbi:DBM:',undef,undef,{f_dir=>"db"});
my @sql = qw {DROP TABLE IF EXISTS users;
              CREATE TABLE users ( username TEXT, address TEXT);
              INSERT INTO users VALUES ( 'user1',  1);
              INSERT INTO users VALUES ( 'user2',  2);
};
foreach my $sql (@sql ){
  $dbh->do($sql);
}

my $sth = $dbh->prepare("SELECT * FROM users");
$sth->execute;
$dbh->disconnect;
