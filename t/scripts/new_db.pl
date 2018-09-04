#!perl
use DBI;
use Data::Dumper;
use Cwd;
my $dir = getcwd;
warn("dir=".$dir);
# use  SQL::then;

my $dbh = DBI->connect('dbi:DBM:',undef,undef,{f_dir=>"db"});


my @sql = ("DROP TABLE IF EXISTS users",
           "DROP TABLE IF EXISTS addresses",
           "CREATE TABLE users ( users.username TEXT, users.address TEXT)",
           "CREATE TABLE addresses ( id TEXT, street TEXT)",
            "INSERT INTO addresses VALUES ( '1',  '131 mo')",
            "INSERT INTO addresses VALUES ( '2',  'just onw')",
);


foreach my $sql (@sql ){
  $dbh->do($sql);
}
print $dbh->{sql_handler}, "\n";

my $sth = $dbh->prepare("SELECT 1+1,street FROM addresses");
$sth->execute;
$sth->dump_results if $sth->{NUM_OF_FIELDS};

# my $sth = $dbh->prepare("UPDATE user_cs SET user_cs.address = ? where user_cs.username=?");
# $sth->bind_param_array(1, [ '456', '789', '101112' ]);
# $sth->bind_param_array(2, [ '1', '2', '3' ]);

# $sth->execute_array( { ArrayTupleStatus => \my @tuple_status } );

# my $sth = $dbh->prepare("SELECT * FROM user_cs where userC_s.username in ('3','2','1')");
# $sth->execute;
# $sth->dump_results if $sth->{NUM_OF_FIELDS};


# warn("JSP".$dbh->get_info());
#$dbh->do("UPDATE users SET address = '111',username = 'xxx' where username='user1'"); 

# $sth = $dbh->prepare("SELECT users+1 FROM users");
# $sth->execute;
# $sth->dump_results if $sth->{NUM_OF_FIELDS};

# $dbh->disconnect;
