package Xtest::DB::Users;
use lib ('D:\GitHub\database-accessor-driver-dbi\xt\lib');
#!perl
use DBI;
use Data::Dumper;
use Cwd;
use Moose;
with 'MooseX::Object::Pluggable';

has create_sql => (
    is      => 'ro',
    isa     => 'ArrayRef',
    builder => "_create_sql",
    lazy    => 1,
);

has drop_sql => (
    is      => 'ro',
    isa     => 'ArrayRef',
    builder => "_drop_sql",
    lazy    => 1,
);

has fill_sql => (
    is      => 'ro',
    isa     => 'ArrayRef',
    builder => "_fill_sql",
    lazy    => 1,
);
has person_data => (
    is      => 'ro',
    isa     => 'ArrayRef',
    builder => "_person_data",
    lazy    => 1,
);


has new_person_data => (
    is      => 'ro',
    isa     => 'ArrayRef',
    builder => "_new_person_data",
    lazy    => 1,
);


has people_data => (
    is      => 'ro',
    isa     => 'ArrayRef',
    builder => "_people_data",
    lazy    => 1,
);

has dbh => (
    is  => 'rw',
    isa => 'Object'
);

has driver_name => (
    is  => 'rw',
    isa => 'Str'
);

sub connect {

    my $self    = shift;
    my $connect = $ENV{DAD_TEST_CONNECT_STR} || "DBI:Oracle:";
    my $uid     = $ENV{DAD_TEST_UID} || "HR";
    my $pw      = $ENV{DAD_TEST_PW} || "hr";
    my $opts    = $ENV{DAD_TEST_OPTS} || { RaiseError => 0 };
    my $dbh     = DBI->connect( $connect, $uid, $pw, $opts );
    $self->driver_name($dbh->{Driver}->{Name} );
    $self->load_plugin( $self->driver_name() ); 
 
    return $dbh;

}

sub create_db {
    my $self = shift;
    my $dbh = $self->dbh()||$self->connect;
    $self->remove_db();
    foreach my $sql (@{$self->create_sql()}){
        $dbh->do($sql);
    }
    $self->fill_db();
}

sub remove_db {
    my $self = shift;
    my $dbh = $self->dbh()||$self->connect;
        foreach my $sql (@{$self->drop_sql()}){
        $dbh->do($sql);
    } 
}

sub fill_db {
    my $self = shift;
    my $dbh = $self->dbh()||$self->connect;
        foreach my $sql (@{$self->fill_sql()}){
        $dbh->do($sql);
    } 
}

sub _person_data {
      my $self = shift;
    return [[1,'Bill','Master','masterb'],
            [2,'Bob','Milk','milkb'],
            [3,'Jill','Nobert','norbertj'],
            [4,'Alfred E.','Newman','newmanae']
           ];
}

sub _people_data {
      my $self = shift;
      return [[1,'Bill'     ,'Master','masterb' ,1,'1414 New lane','Toronto'  ,'M5H-1E6',2,'Canada',21,'NA',1,'EST'],
         [2,'Bob'      ,'Milk'   ,'milkb'   ,2,'22 Sicamore'  ,'Toronto'  ,'M5H-2F6',2,'Canada',21,'NA',1,'EST'],
         [3,'Jill'     ,'Nobert' ,'norbertj',3,'PO Box 122'   ,'Hollywood','90210'  ,1,'USA'   ,10,'West',3,'PST'],
         [4,'Alfred E.','Newman' ,'newmanae',4,'PO Box 233'   ,'Hollywood','90210'  ,1,'USA'   ,10,'West',3,'PST'],
         [5,'James'    ,'Marceia','marceiaj',6,'Plaza de la Constitucion 2','Ciudad de Mexico','06000',3,'Mexico',21,'NA',2,'CST'],
        ];

}

sub _new_person_data {
      my $self = shift;
      return [{first_name=>'James',
               last_name=>'Marceia',
               user_id=>'marceiaj',
               street=>'Plaza de la Constitucion 2',
               city=>'Ciudad de Mexico',
               postal_code=>'06000',
               country_id=>3,
               country=>'Mexico',
               region_id=>21,
               region=>'NA',
               time_zone_id=>2,
               time_zone=>'CST',
               address_id=>6,
               id=>5},
        ];

}
1;
