package Xtest::DA::Person;
use lib ('D:\GitHub\database-accessor\lib');
use Data::Dumper;
use Database::Accessor;
use Moose;



has [ qw( id
    address_id
    time_zone_id
    country_id
    region_id
    )
    ] => (
          is          => 'rw',
          isa         => 'Int',
   );
   
has [ qw( last_name
           first_name
           user_id
           street
           postal_code
           city
           country
           region
           time_zone
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
   my $da = Database::Accessor->new({view    =>{name=>"people"},
                                     elements=>[{name     =>'id',
                                                 identity =>{'DBI::db'=>{'ORACLE'  => {
                                                 name     => 'NEXTVAL',
                                                 view     => 'people_seq'}
                                                  }} },
                                                {name=>'first_name'},
                                                {name=>'last_name'},
                                                {name=>'user_id'},
                                                {name=>'address_id',
                                                 view=>'address',},
                                                {name=>'street',
                                                 view=>'address',},
                                                {name=>'city',
                                                 view=>'address',},
                                                {name=>'postal_code',
                                                 view=>'address',},
                                               {name=>'country_id',
                                                 view=>'address',},
                                               {name=>'description',
                                                alias=>'country',
                                                view=>'country',},
                                               {name=>'description',
                                                alias=>'region',
                                                view=>'region',},
                                               {name=>'description',
                                                alias=>'time zone',
                                                view=>'time_zone',}, ],
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
                                                {type       => 'LEFT',
                                                 to         => { name => 'region'},
                                                 conditions => [{ left => { name => 'id' },
                                                                 right => { name => 'region_id',
                                                                            view => 'person'}}]
                                                                            },
                                                {type       => 'LEFT',
                                                 to         => { name => 'time_zone'},
                                                 conditions => [{ left => { name => 'id' },
                                                                 right => { name => 'time_zone_id',
                                                                            view => 'person'}}]
                                                                            }],
                                   });
  return $da;
}

1;