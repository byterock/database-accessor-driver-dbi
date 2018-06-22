#!perl
use Test::More  tests => 3;
use Test::Fatal;
use lib ('D:\GitHub\database-accessor\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\t\lib');
use Data::Dumper;
use Database::Accessor;
use Test::Deep;
use Test::Utils;
my $utils = Test::Utils->new();


my $in_hash = {
    da_compose_only=>1,
    view     => { name => 'people' },
    elements => [
        {
            name => 'first_name',
            view => 'people'
        },
        {
            name => 'last_name',
            view => 'people'
        },
        {
            name => 'user_id',
            view => 'people'
        }
    ],
    conditions => [
        {
            left => {
                name => 'first_name',
                view => 'people'
            },
            right           => { value => 'test1' },
            operator        => '=',
            open_parentheses  => 1,
            close_parentheses => 0,
        },
        {
            condition => 'AND',
            left      => {
                name => 'last_name',
                view => 'people'
            },
            right           => { value => 'test2' },
            operator        => '=',
            open_parentheses  => 0,
            close_parentheses => 1
        }
      ]

    ,
};
my $container =  {first_name=>'Bill',
                  last_name =>'Bloggings'};
my $da     = Database::Accessor->new($in_hash);
$da->create( $utils->connect(),$container);



cmp_deeply(
           $da->result()->params,
           [qw(Bill Bloggings)],
           "create params in correct order"
          );
$da->retrieve( $utils->connect() );

cmp_deeply(
           $da->result()->params,
           [qw(test1 test2)],
           "retrieve params in correct order"
          );
$da->update( $utils->connect(),$container);
cmp_deeply(
           $da->result()->params,
           [qw(Bill Bloggings test1 test2)],
           "update params in correct order"
          );
$da->delete( $utils->connect());
cmp_deeply(
           $da->result()->params,
           [qw(test1 test2)],
           "delete params in correct order"
          );

$container = [{first_name=>'Bill',last_name =>'Bloggings'},
              {first_name=>'Jane',last_name =>'Doe'},
              {first_name=>'John',last_name =>'Doe'},
              {first_name=>'Joe',last_name =>'Blow'},
              ];
$expected  = [['Bill','Bloggings'],
              ['Jane','Doe'],
              ['John','Doe'],
              ['Joe','Blow'],
              ];

$da->create( $utils->connect(),$container);
ok($da->result()->query() eq "INSERT INTO people ( people.first_name, people.last_name ) VALUES( ?, ? )","Array create SQL correct");


warn("s=".Dumper($da->result()));
for (my $index = 0; $index < $da->result()->param_count; $index++){
  
    cmp_deeply(
           $da->result()->params->[$index],
           $expected->[$index],
           "Array create tuple $index are correct"
          );
}
