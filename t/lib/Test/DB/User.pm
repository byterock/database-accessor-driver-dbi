package Test::DB::User;

use Data::Dumper;
use Moose;
use parent qw(Database::Accessor);



  around BUILDARGS => sub {
      my $orig = shift;
      my $class = shift;
      my $ops   = shift(@_);       
return $class->$orig({
                 view=>{name=>'user'},
             elements=>[{view=>'user',
                         name=> 'username'},
                        {name=> 'address',
                         view=>'user'}],
   update_requires_condition=>0,
   delete_requires_condition=>0
                  });
  };
  
                        
1;