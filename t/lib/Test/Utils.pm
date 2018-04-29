package Test::Utils;

#!perl
use DBI;
use Data::Dumper;
use Cwd;

use Moose;
sub db {
  my $self = shift;
  my $dir = getcwd;
  return $dir."/test/db";
}

sub connect {
  my $self = shift;
  my $dir = getcwd;
  my $dbh = DBI->connect('dbi:DBM:',undef,undef,{f_dir=>$self->db});
  return $dbh;
}
sub create_users_table {
  my $self = shift;
  my @sql = ("DROP TABLE IF EXISTS users",
             "CREATE TABLE users ( username TEXT, address TEXT)");
             
  $self->do_sql(@sql); }
sub do_sql {
  my $self = shift;
  my @sql  = @_;
  my $dbh = $self->connect();  foreach my $sql (@sql ){
    $dbh->do($sql);
  }
}

1;