package Test::DB::User;

use Data::Dumper;
use Database::Accessor;
use Moose;

has table => ( is  => 'ro',
               isa => 'Str',
               default=>'user');
has fields => ( isa => 'ArrayRef',
            is  => 'ro',
            default => sub { [{view=>'user',
                         name=>'username'},
                         {name=>'address',
                          view=>'user'}] },
        );
        
sub da {
   my $self = shift;
   my $da = Database::Accessor->new({da_suppress_view_name=>1,
                                     view=>{name=>$self->table},
                                    elements=>$self->fields,
                                    update_requires_condition=>0,
                                    delete_requires_condition=>0});
                
}
1;