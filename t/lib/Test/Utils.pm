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
  
}



sub sql_param_ok {
    my $self = shift;
    my ( $org_hash, $tests ) = @_;
    my $in_hash = $org_hash;
    foreach my $test ( @{$tests} ) {
          if ( exists( $test->{index} ) ) {
            $in_hash->{ $test->{key} }->[ $test->{index} ] =
              $test->{ $test->{key} };
          }
          elsif ( exists( $test->{key} ) ) {
            $in_hash->{ $test->{key} } = $test->{ $test->{key} };
          }
          elsif ( exists( $test->{keys} ) ) {
            foreach my $key (@{$test->{keys}}) {
              $in_hash->{ $key } = $test->{$key };
            }
          }
              my $da = Database::Accessor->new($in_hash);
                
        foreach my $action ((qw(create retrieve update delete))){
          next 
            unless(exists($test->{$action}));
                      
          my $sub_test = $test->{$action};
          
         
          $da->$action( $self->connect(), $sub_test->{container});        
          my $ok = ok(
            $da->result()->query() eq $sub_test->{sql},
            $test->{caption} . " $action SQL correct"
          );
          unless ($ok) {
            diag(   "Expected SQL--> "
                  . $sub_test->{sql}
                  . "\nGenerated SQL-> "
                  . $da->result()->query() );
          }

          cmp_deeply( $da->result()->params, $sub_test->{params},
            $test->{caption} . " $action params correct" )
            if ( exists( $sub_test->{params} ) );
        }
    }
}
1;

