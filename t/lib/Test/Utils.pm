package Test::Utils;

#!perl
use DBI;
use Data::Dumper;
use Cwd;
use strict;
use Test::More;
use Database::Accessor;
use Test::Deep qw(cmp_deeply); use Moose;
sub db {
  my $self = shift;
  my $dir = getcwd;
  return $dir."/db/test";
}

sub connect {
  my $self = shift;
  
  my $dbh = DBI->connect('dbi:DBM:',undef,undef,{f_dir=>$self->db});
# print $dbh->{sql_handler}, "\n";  return $dbh;
}
sub create_users_table {
  my $self = shift;
  my @sql = ("DROP TABLE IF EXISTS user",
             "CREATE TABLE user ( user.username TEXT, user.address TEXT)",
             "INSERT INTO user VALUES ( 'user.user1',  1)");
             
  $self->do_sql(@sql); 
  
  }
sub do_sql {
  my $self = shift;
  my @sql  = @_;
  my $dbh = $self->connect();  foreach my $sql (@sql ){
    $dbh->do($sql);
  }
  




sub sql_param_ok {
    my $self = shift;
    my ($in_hash,$tests ) = @_;
    my $da     = Database::Accessor->new($in_hash);
    foreach my $test (@{$tests}){    if (exists($test->{index})) {
      $in_hash->{ $test->{key} }->[ $test->{index} ] = $test->{ $test->{key} };
    }
    else {
      $in_hash->{ $test->{key} } = $test->{ $test->{key} };
    }
    my $da = Database::Accessor->new($in_hash);
    $da->retrieve($self->connect());
    my $ok =   ok(
        $da->result()->query() eq $test->{sql},
        $test->{caption} . " SQL correct"
    );
    unless($ok){
      diag("Expected SQL--> ".$test->{sql}."\nGenerated SQL-> ".$da->result()->query()); 
                }
    cmp_deeply( $da->result()->params, $test->{params},
        $test->{caption} . " params correct" )
      if (exists($test->{params}));
    }
}     # my $sth = $dbh->prepare("SELECT * FROM user");
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
