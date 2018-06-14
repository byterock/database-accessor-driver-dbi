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
# my $in_hash = {
    # da_compose_only           => 1,
    # update_requires_condition => 0,
    # delete_requires_condition => 0,
    # view                      => { name => 'people', },
    # elements                  => [
        # {
            # name  => 'last_name',
            # alias => 'last'
        # },
        # {
            # name  => 'first_name',
            # alias => 'first'
        # },
    # ],
# };
# my $container = {
    # last_name  => 'Bloggings',
    # first_name => 'Bill',
# };

# $da = Database::Accessor->new($in_hash);
# $da->create( $utils->connect(), $container );
# ok(
    # $da->result()->query() eq
# "INSERT INTO people ( people.first_name, people.last_name ) VALUES( ?, ? )",
    # "create SQL correct"
# );
# $da->retrieve( $utils->connect() );
# ok(
    # $da->result()->query() eq
      # "SELECT people.last_name AS last, people.first_name AS first FROM people",
    # "retrieve SQL correct"
# );
# $da->update( $utils->connect(), $container );
# ok(
    # $da->result()->query() eq
      # "UPDATE people SET people.first_name = ?, people.last_name = ?",
    # "update SQL correct"
# );

# $da = Database::Accessor->new(
    # {
        # da_compose_only => 1,
        # view            => { name => 'user', },
        # elements        => [
            # { value => 'User Name:' },
            # { name  => 'username', },
            # { value => 'Address:' },
            # { name  => 'address', },
        # ],
        # conditions => {
            # left => {
                # name => 'username',
                # view => 'user'
            # },
            # right => { value => 'Bill' }
        # }
    # }
# );

# $da->retrieve( $utils->connect() );
# ok(
    # $da->result()->query() eq
      # "SELECT ?, user.username, ?, user.address FROM user WHERE user.username = ?",
    # "Scalar field bind SQL correct"
# );
# cmp_deeply(
           # $da->result()->params,
           # ['User Name:','Address:','Bill'],
           # "Scalar field in params correct"
          # );
          
$da = Database::Accessor->new(
    {
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
    }
);
$da->retrieve( $utils->connect() );
ok(
    $da->result()->query() eq
      "SELECT user.username, left(user.username,?), user.address FROM user WHERE user.username = ?",
      "Function with 1 param bind SQL correct"
);
cmp_deeply(
           $da->result()->params,
           [11,'Bill'],
           "Function params correct"
          );
          
warn( Dumper( $da->result() ) );

