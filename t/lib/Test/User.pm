package Test::User;

use Data::Dumper;
use Database::Accessor;
use Moose;


has username => ( is  => 'rw',
               isa => 'Str',);

has address => ( is  => 'rw',
               isa => 'Str',);
               
1;