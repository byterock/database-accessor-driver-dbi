package Xtest::DA::Address;
use lib ('D:\GitHub\database-accessor\lib');
use Data::Dumper;
use Database::Accessor;
use Moose;



has [ qw( id
          time_zone_id
          country_id
          region_id
    )
    ] => (
          is          => 'rw',
          isa         => 'Int',
   );
   
has [ qw( street
          postal_code
          city
       )
        ] => (
          is          => 'rw',
          isa         => 'Str',
        );


has da => (
    is      => 'ro',
    isa     => 'Database::Accessor',
    builder => "_build_da",
    lazy    => 1,
);

sub _build_da {
   my $self = shift;
   my $da = Database::Accessor->new({view    =>{name=>'address'},
                                     elements=>[{name=>'id',
                                                 identity =>{'DBI::db'=>{'Oracle'  => {
                                                 name     => 'NEXTVAL',
                                                 view     => 'address_seq'}
                                                  }}  
                                                 },
                                                {name=>'city'},
                                                {name=>'time_zone_id'},
                                                {name=>'country_id'},
                                                {name=>'region_id'},
                                                {name=>'street'},
                                                {name=>'postal_code'},],
                                    no_retrieve=>1,});
                
}

1;