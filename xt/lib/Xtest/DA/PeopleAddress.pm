package Xtest::DA::PeopleAddress;
use lib ('D:\GitHub\database-accessor\lib');
use Data::Dumper;
use Database::Accessor;
use Moose;



has [ qw( people_id
          address_id
    )
    ] => (
          is          => 'rw',
          isa         => 'Int',
   );
   
has [ qw( primary_ind
       )
        ] => (
          is          => 'rw',
          isa         => 'Bool',
        );


has da => (
    is      => 'ro',
    isa     => 'Database::Accessor',
    builder => "_build_da",
    lazy    => 1,
);



sub _build_da {
   my $self = shift;
   my $da = Database::Accessor->new({view    =>{name=>'people_address'},
                                     elements=>[{name=>'people_id'},
                                                {name=>'address_id'},
                                                {name=>'primary_ind'},
                                                ],
                                    no_retrieve=>1,});
                
}

1;