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

has person_data => (
    is      => 'ro',
    isa     => 'ArrayRef',
    builder => "_person_data",
    lazy    => 1,
);

has persons_data => (
    is      => 'ro',
    isa     => 'ArrayRef',
    builder => "_persons_data",
    lazy    => 1,
);

has update_person_data => (
    is      => 'ro',
    isa     => 'HashRef',
    builder => "_update_person_data",
    lazy    => 1,
);

has updated_person_data => (
    is      => 'ro',
    isa     => 'ArrayRef',
    builder => "_updated_person_data",
    lazy    => 1,
);

has update_people_data => (
    is      => 'ro',
    isa     => 'ArrayRef',
    builder => "_update_people_data",
    lazy    => 1,
);


has update_people_id_data => (
    is      => 'ro',
    isa     => 'ArrayRef',
    builder => "_update_people_id_data",
    lazy    => 1,
);
has updated_people_data => (
    is      => 'ro',
    isa     => 'ArrayRef',
    builder => "_updated_people_data",
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

sub _persons_data {
      my $self = shift;
      return [[5,'James'    ,'Marceia','marceiaj','Ciudad de Mexico','NA'],
              [1,'Bill'     ,'Master' ,'masterb ','Toronto'  ,'NA'],
              [2,'Bob'      ,'Milk'   ,'milkb   ','Toronto'  ,'NA'],
              [4,'Alfred E.','Newman' ,'newmanae','Hollywood','West'],
              [3,'Jill'     ,'Nobert' ,'norbertj','Hollywood','West'],
               ];

}


sub _people_data {
      my $self = shift;
      return [[1,'Bill'     ,'Master' ,'masterb ',1,'1414 New lane','Toronto'  ,'M5H-1E6',2,'Canada',21,'NA',1,'EST'],
              [2,'Bob'      ,'Milk'   ,'milkb   ',2,'22 Sicamore'  ,'Toronto'  ,'M5H-2F6',2,'Canada',21,'NA',1,'EST'],
              [3,'Jill'     ,'Nobert' ,'norbertj',3,'PO Box 122'   ,'Hollywood','90210'  ,1,'USA'   ,10,'West',3,'PST'],
              [4,'Alfred E.','Newman' ,'newmanae',4,'PO Box 233'   ,'Hollywood','90210'  ,1,'USA'   ,10,'West',3,'PST'],
              [5,'James'    ,'Marceia','marceiaj',6   ,'Plaza de la Constitucion 2','Ciudad de Mexico','06000',3     ,'Mexico',21   ,'NA' ,2    ,'CST'],
              [6,'Tom'      ,'Atkins'  ,'atkinst ',undef                             ,undef             ,undef  ,undef ,undef   ,undef,undef,undef,undef,undef],
              [7,'Tom'      ,'Atkins2' ,'atkinst2',undef                             ,undef             ,undef  ,undef ,undef   ,undef,undef,undef,undef,undef],
              [8,'Tom'      ,'Atkins3' ,'atkinst3',undef                             ,undef             ,undef  ,undef ,undef   ,undef,undef,undef,undef,undef],
              [9,'Tom'      ,'Atkins4' ,'atkinst4',undef                             ,undef             ,undef  ,undef ,undef   ,undef,undef,undef,undef,undef],
       
 ];

}sub _new_person_data {
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
               'time zone'=>'CST',
               address_id=>6,
               id=>5},
               {FIRST_NAME=>'Diego',
               LAST_NAME=>'Marceia',
               USER_ID=>'marceiaj',
               STREET=>'Plaza de la Constitucion 2',
               CITY=>'Ciudad de Mexico',
               POSTAL_CODE=>'06000',
               COUNTRY_ID=>3,
               COUNTRY=>'Mexico',
               REGION_ID=>21,
               REGION=>'NA',
               TIME_ZONE_ID=>2,
               'TIME ZONE'=>'CST',
               ADDRESS_ID=>6,
               ID=>5},
               {FIRST_NAME=>'Diego',
               LAST_NAME=>'Marceia',
               USER_ID=>'marceiaj',
               STREET=>'Plaza de la Constitucion 2',
               CITY=>'Ciudad de Mexico',
               POSTAL_CODE=>'06000',
               COUNTRY_ID=>3,
               country=>'Mexico',
               REGION_ID=>21,
               region=>'NA',
               TIME_ZONE_ID=>2,
               'time zone'=>'CST',
               address_id=>6,
               ID=>5},
              {first_name =>'Tom',
                last_name =>'Atkins',
                user_id   =>'atkinst'},
              {first_name =>'Tom',
                last_name =>'Atkins2',
                user_id   =>'atkinst2'},
              {first_name =>'Tom',
                last_name =>'Atkins3',
                user_id   =>'atkinst3'},
              {first_name =>'Tom',
                last_name =>'Atkins4',
                user_id   =>'atkinst4'},
        ];

}
sub _update_person_data {
    my $self = shift;
    return {first_name=>'Diego'};
}

sub _updated_person_data {
    my $self = shift;
    return [5,'Diego' ,'Marceia','marceiaj',6,'Plaza de la Constitucion 2','Ciudad de Mexico','06000',3,'Mexico',21,'NA',2,'CST'],
       
}

sub _updated_people_data {
    my $self = shift;
     return [6,'Tommy'      ,'Atkins'  ,'atkinst ',undef                             ,undef             ,undef  ,undef ,undef   ,undef,undef,undef,undef,undef],
            [7,'Tommy2'      ,'Atkins2' ,'atkinst2',undef                             ,undef             ,undef  ,undef ,undef   ,undef,undef,undef,undef,undef],
            [8,'Tommy3'      ,'Atkins3' ,'atkinst3',undef                             ,undef             ,undef  ,undef ,undef   ,undef,undef,undef,undef,undef],
            [9,'Tommy4'      ,'Atkins4' ,'atkinst4',undef                             ,undef             ,undef  ,undef ,undef   ,undef,undef,undef,undef,undef],
       
     
}

sub _update_people_data {
    my $self = shift;
    
    return [{first_name=>'Tommy'},  
            {first_name=>'Tommy2'},  
            {first_name=>'Tommy3'},  
            {first_name=>'Tommy4'},
           ];
}

sub _update_people_id_data {
    my $self = shift;
    
    return [6,  
            7,  
            8,  
            9,
           ];
}

1;
