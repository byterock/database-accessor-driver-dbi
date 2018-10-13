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
                                                 identity =>{'DBI::db'=>{'Oracle'  => {
                                                 name     => 'NEXTVAL',
                                                 view     => 'people_seq'}
                                                  }} },
                                                {name=>'first_name'},
                                                {name=>'last_name'},
                                                {name=>'user_id'},
                                                {name=>'id',
                                                 view=>'address',
                                                 alias=>'address_id'},
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
                                               {name=>'region_id',
                                                view=>'address',},
                                               {name=>'description',
                                                alias=>'region',
                                                view=>'region',},
                                               {name=>'time_zone_id',
                                                view=>'address',},
                                               {name=>'description',
                                                alias=>'time zone',
                                                view=>'time_zone',}, ],
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
                                                 to         => { name => 'country'},
                                                 conditions => [{ left => { name => 'id',
                                                                            view => 'country' },
                                                                 right => { name => 'country_id',
                                                                            view => 'address'}}]
                                                                            },
                                                {type       => 'LEFT',
                                                 to         => { name => 'region'},
                                                 conditions => [{ left => { name => 'id',
                                                                            view => 'region'},
                                                                 right => { name => 'region_id',
                                                                            view => 'address'}}]
                                                                            },
                                                {type       => 'LEFT',
                                                 to         => { name => 'time_zone'},
                                                 conditions => [{ left => { name => 'id',
                                                                            view => 'time_zone' },
                                                                 right => { name => 'time_zone_id',
                                                                            view => 'address'}}]
                                                                            }],
                                   });
  return $da;
}

1;