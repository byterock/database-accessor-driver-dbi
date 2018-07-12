#!perl
use Test::More tests => 3;
use Test::Fatal;
use lib ('D:\GitHub\database-accessor\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\lib');
use lib ('D:\GitHub\database-accessor-driver-dbi\t\lib');
use Data::Dumper;
use Database::Accessor;
use Test::Deep;
use Test::Utils;
my $utils   = Test::Utils->new();
my $in_hash = {
    da_compose_only           => 1,
    update_requires_condition => 0,
    delete_requires_condition => 0,
    view                      => { name => 'people', },
    elements                  => [
        {
            name  => 'last_name',
            alias => 'last'
        },
        {
            name  => 'first_name',
            alias => 'first'
        },
    ],
};
my $container = {
    last_name  => 'Bloggings',
    first_name => 'Bill',
};

$da = Database::Accessor->new($in_hash);
$da->create( $utils->connect(), $container );
ok(
    $da->result()->query() eq
"INSERT INTO people ( people.first_name, people.last_name ) VALUES( ?, ? )",
    "create SQL correct"
);
$da->retrieve( $utils->connect() );
ok(
    $da->result()->query() eq
      "SELECT people.last_name AS last, people.first_name AS first FROM people",
    "retrieve SQL correct"
);
$da->update( $utils->connect(), $container );
ok(
    $da->result()->query() eq
      "UPDATE people SET people.first_name = ?, people.last_name = ?",
    "update SQL correct"
);

$da = Database::Accessor->new(
    {
        da_compose_only => 1,
        view            => { name => 'user', },
        elements        => [
            { value => 'User Name:' },
            { name  => 'username', },
            { value => 'Address:' },
            { name  => 'address', },
        ],
        conditions => {
            left => {
                name => 'username',
                view => 'user'
            },
            right => { value => 'Bill' }
        }
    }
);

$da->retrieve( $utils->connect() );
ok(
    $da->result()->query() eq
      "SELECT ?, user.username, ?, user.address FROM user WHERE user.username = ?",
    "Scalar field bind SQL correct"
);
cmp_deeply(
           $da->result()->params,
           ['User Name:','Address:','Bill'],
           "Scalar field in params correct"
          );
my $in_hash =  {
        da_compose_only => 1,
        view            => { name => 'user', },
        elements        => [
            { name  => 'username', },
            { function => 'left',
                left  => { name => 'username' },
                right => { param =>11} },
            { name  => 'address', },
        ],
        conditions => {
            left => {
                name => 'username',
                view => 'user'
            },
            right => { value => 'Bill' }
        }
    };
$da = Database::Accessor->new($in_hash);

my $tests = [{
    index=>1,
    element => { function => 'substr',
                    left  => { name => 'username' },
                              right => [{ param =>3},
                                        { param =>5}] },
    caption => "Function with 2 params ",    sql     => "SELECT user.username, left(user.username,?), user.address FROM user WHERE user.username = ?",
    params  => [3,5,'Bill']
}];
$da->retrieve( $utils->connect() );
ok(
    $da->result()->query() eq
      "SELECT user.username, left(user.username,?), user.address FROM user WHERE user.username = ?",
      "Function with 1 param bind SQL correct"
);
cmp_deeply(
           $da->result()->params,
           [3,5,'Bill'],
           "Function params correct"
          );


$in_hash->{elements}->[1] = { function => 'substr',
                                 left  => { name => 'username' },
                                 right => [{ param =>3},{ param =>5}] };



my $da = Database::Accessor->new($in_hash);$da->retrieve( $utils->connect() );
ok(
    $da->result()->query() eq
      "SELECT user.username, substr(user.username,?,?), user.address FROM user WHERE user.username = ?",
      "Function with 2 param binds SQL correct"
);
cmp_deeply(
           $da->result()->params,
           [3,5,'Bill'],
           "Function params correct"
          );

$in_hash->{elements}->[1] = { function => 'substr',
                                 left  => { name => 'username' },
                                 right => [{ param =>3},
                                           {  function => 'left',
                                                 left  => { name => 'address' },
                                                 right => { param =>4}}] };

my $da = Database::Accessor->new($in_hash);
$da->retrieve( $utils->connect() );
ok(
    $da->result()->query() eq
      "SELECT user.username, substr(user.username,?,left(user.address,?)), user.address FROM user WHERE user.username = ?",
      "Function within a function SQL correct"
);
cmp_deeply(
           $da->result()->params,
           [3,4,'Bill'],
           "Function withing a function params correct"
          );


$in_hash->{elements}->[1] = { expression => '+',
                                 left  => { name => 'salary' },
                                 right => { param =>10} };





my $da = Database::Accessor->new($in_hash);
$da->retrieve( $utils->connect() );
ok(
    $da->result()->query() eq
      "SELECT user.username, (user.salary + ?), user.address FROM user WHERE user.username = ?",
      "Expression with 1 param binds SQL correct"
);
cmp_deeply(
           $da->result()->params,
           [10,'Bill'],
           "Expression params correct"
          );
$in_hash->{elements}->[1] = { expression => '+',
                                 left  => { name => 'salary' },
                                 right => { expression => '*',
                                                 left  => { name => 'bonus' },
                                                 right => { param=>.05 }} };

my $da = Database::Accessor->new($in_hash);
$da->retrieve( $utils->connect() );
ok(
    $da->result()->query() eq
      "SELECT user.username, (user.salary + (user.bonus * ?)), user.address FROM user WHERE user.username = ?",
      "Expression within an expression SQL correct"
);
cmp_deeply(
           $da->result()->params,
           [.05,'Bill'],
           "Expression within an expression params correct"
          );

$in_hash->{elements}->[1] = { function => 'abs',
                                 left  => { expression1 => '*',
                                                 left  => { name => 'bonus' },
                                                 right => { param=>-.05 }} };



my $da = Database::Accessor->new($in_hash);
$da->retrieve( $utils->connect() );
ok(
    $da->result()->query() eq
      "SELECT user.username, abs((user.bonus * ?)), user.address FROM user WHERE user.username = ?",
      "Expression within an expression SQL correct"
);
cmp_deeply(
           $da->result()->params,
           [-.05,'Bill'],
           "Expression within an expression params correct"
          );

warn( Dumper( $da->result() ) );

