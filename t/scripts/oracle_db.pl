#!perl
use DBI;
use Data::Dumper;
use lib ('D:\GitHub\database-accessor\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\t\lib');
use Database::Accessor;

my $dbh = DBI->connect("DBI:Oracle:",
        "HR" ,
        "hr");

my $new_da = Database::Accessor->new({view=>{name=>'locations'},
                                          elements=>[{name=>'location_id'},
                                                     {name=>'street_address'},
                                                     {name=>'postal_code'},
                                                     {name=>'city'},
                                                     {name=>'state_province'},
                                                     {name=>'country_id'}],});
my $other_user = Database::Accessor->new({view=>{name=>'locations'},
                                          elements=>[{name=>'city'}],
                                          conditions=>{left  =>{ name  => 'city',
                                view  => 'locations'},
                      right =>{ value => 'Toronto'}}});

$new_da->add_condition({left  =>{ name  => 'city',
#view=>'locations'
                               },
                      right =>{ value => $other_user}
                    });
                    
$new_da->retrieve($dbh);
warn('result='.Dumper($new_da))

# foreach my $sql (@sql ){
  # $dbh->do($sql);
# }
# print $dbh->{sql_handler}, "\n";
# #my $sth = $dbh->prepare("SELECT username as name,address, addresses.street FROM users join addresses on users.address = addresses.id");
# #my $sth = $dbh->prepare("SELECT username as name,address, addresses.street FROM users join addresses on users.address = addresses.id");

# my $sth = $dbh->prepare("SELECT * FROM users");
# $sth->execute;
# $sth->dump_results if $sth->{NUM_OF_FIELDS};

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
