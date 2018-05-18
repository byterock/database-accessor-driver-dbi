package Test::Utils;

#!perl
use DBI;
use Data::Dumper;
use Cwd;

use Moose;
sub db {
  my $self = shift;
  my $dir = getcwd;
  return $dir."/db/test";
}

sub connect {
  my $self = shift;
  # my $dir = getcwd;
  warn("connect db".$self->db);
  
  
  my $dbh = DBI->connect('dbi:DBM:',undef,undef,{f_dir=>$self->db});
  return $dbh;
}
sub create_users_table {
  my $self = shift;
  my @sql = ("DROP TABLE IF EXISTS user",
             "CREATE TABLE user ( username TEXT, address TEXT)",
             "INSERT INTO user VALUES ( 'user1',  1)");
             
  $self->do_sql(@sql); 
  
  }
sub do_sql {
  my $self = shift;
  my @sql  = @_;
  my $dbh = $self->connect();  foreach my $sql (@sql ){
    $dbh->do($sql);
  }
  
     # my $sth = $dbh->prepare("SELECT * FROM user");
# $sth->execute;
# $sth->dump_results if $sth->{NUM_OF_FIELDS};
 # $dbh->disconnect;
}

1;

# my $dbh = DBI->connect('dbi:DBM:',undef,undef,{f_dir=>$dir."/test/db"});
# my @sql = ("DROP TABLE IF EXISTS users",
           # "CREATE TABLE users ( username TEXT, address TEXT)",
           # "INSERT INTO users VALUES ( 'user1',  1)",
           # "INSERT INTO users VALUES ( 'user2',  2)",
# );
# foreach my $sql (@sql ){
  # $dbh->do($sql);
# }

# my $sth = $dbh->prepare("SELECT * FROM users");
# $sth->execute;
# $sth->dump_results if $sth->{NUM_OF_FIELDS};
# $dbh->disconnect;
