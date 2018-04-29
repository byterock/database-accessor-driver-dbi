package Database::Accessor::Driver::DBI;

BEGIN {
    $Database::Accessor::Driver::DBI::VERSION = "0.01";
}
use Moose;
with(qw( Database::Accessor::Roles::Driver));

sub execute {
    my $self = shift;
    my ( $type, $conn, $container, $opt ) = @_;

    return 1

}

sub DB_Class {
    my $self = shift;
    return 'DBI::db';
}

1;