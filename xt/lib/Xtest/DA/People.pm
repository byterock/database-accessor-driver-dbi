package Xtest::DA::People;
use lib ('D:\GitHub\database-accessor\lib');
use Data::Dumper;
use Database::Accessor;
use Moose;



has [ qw( id
    )
    ] => (
          is          => 'rw',
          isa         => 'Int',
   );
   
has [ qw(  last_name
           first_name
           user_id
           city
           region
           
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
   my $da = Database::Accessor->new({view    =>{name=>'people'},
                                     elements=>[{name=>'id',},
                                                {name=>'first_name'},
                                                {name=>'last_name'},
                                                {name=>'user_id'},
                                                {name=>'city',
                                                 view=>'address',},
                                               {name=>'description',
                                                alias=>'region',
                                                view=>'region',},
                                                ],
                                      links => [{type       => 'LEFT',
                                                 to         => {  name => 'address'},
                                                 conditions => [{ left => { name => 'id', },
                                                                 right => { name => 'address_id',
                                                                            view => 'person'}},
                                                                {condition =>'and',
                                                                      left => { name => 'primary_ind' },
                                                                     right => { value => 1}}
                                                              ]},
                                                {type       => 'LEFT',
                                                 to         => { name => 'country'},
                                                 conditions => [{ left => { name => 'id' },
                                                                 right => { name => 'country_id',
                                                                            view => 'person'}}]
                                                                            },
                                                ],
                                    retrieve_only=>1,});
                
}

1;