package Test::DB::User;

use Moose;
use parent qw(Database::Accessor);


  around BUILDARGS => sub {
      my $orig = shift;
      my $class = shift;
return $class->$orig({
                 view=>{name=>'user'},
             elements=>[{name=> 'username'},
                        {name=> 'address'}],
   update_requires_condition=>0,
   delete_requires_condition=>0
                  });
  };
  
                        
1;