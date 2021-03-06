package Xtest::DA::PeopleGrouped;
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
   my $da = Database::Accessor->new({view    =>{name=>'people'},
                                     elements=>[{name=>'first_name'},
                                                {name=>'last_name'},
                                                {name=>'description',
                                                  alias=>'region',
                                                  view=>'region',}
                                                ],
                                     links => [{type       => 'LEFT',
                                                 to         => {  name => 'people_address'},
                                                 conditions => [{ left => { name => 'id',
                                                                            view => 'people' },
                                                                 right => { name => 'people_id',
                                                                            }},
                                                                {condition =>'and',
                                                                      left => { name => 'primary_ind',
                                                                                view => 'people_address' },
                                                                     right => { value => 1}}
                                                              ]},
                                                 {type       => 'LEFT',
                                                 to         => { name => 'address'},
                                                 conditions => [{ left => { view=>'people_address',
                                                                            name => 'address_id' },
                                                                 right => { name => 'id',
                                                                            view => 'address'}}]
                                                                            },
                                                {type       => 'LEFT',
                                                 to         => { name => 'region'},
                                                 conditions => [{ left => { name => 'id',
                                                                            view => 'region'},
                                                                 right => { name => 'region_id',
                                                                            view => 'address'}}]
                                                                            },],
                                     });
                
}

1;