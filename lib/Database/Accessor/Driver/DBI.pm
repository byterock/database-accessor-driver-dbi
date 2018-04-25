
BEGIN {
}
with(qw( Database::Accessor::Roles::Driver));

sub execute {
    my $self = shift;
    my ( $type, $conn, $container, $opt ) = @_;

    $container->{dad}  = $self;
    $container->{type} = $type;

}

    my $self = shift;
}

1;
