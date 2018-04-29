package Database::Accessor::Driver::DBI;
# ABSTRACT: The DBI (SQL) driver for Database Accessor
# Dist::Zilla: +PkgVersion

# DADNote: the DAD writer should use this set of constants will save time and becuse DA has to me installed this will be as well
use lib "D:/GitHub/database-accessor-driver-dbi/lib";
use lib "D:/GitHub/database-accessor/lib";
use Database::Accessor::Constants;
use Database::Accessor::Driver::DBI::SQL;
use Moose;
with(qw( Database::Accessor::Roles::Driver));


sub execute {
    my $self = shift;
    my ( $type, $dbh, $container, $opts ) = @_;
    my $exe_array = 0;

    my $sql;

    if ( $type eq Database::Accessor::Constants::CREATE ) {
        $sql = $self->_insert($container);
    }
    elsif ( $type eq Database::Accessor::Constants::UPDATE ) {
        $sql = $self->_update($container);
    }
    elsif ( $type eq Database::Accessor::Constants::DELETE ) {
        $sql = $self->_delete();
    }
    else {
        $sql = $self->_select_clause();
    }

    ##warn("my SQL qa =".$sql."\n");

    my $sth;

    ##warn("my $dbh =".$dbh."\n");

    eval {
        $sth = $dbh->prepare($sql);
        $sth->execute();

    };
    if ($@) {

        #warn( "error=" . $@ );
    }
    
    
    my @params;    # = $self->_params();

    foreach my $param ( @{ $self->_params() } ) {
        my $value = $param->value();

        if ( $value and $value->isa("DBIx::DA::SQL") ) {
            foreach my $nested ( $value->_params ) {    #this needs to recurse
                push( @params, $nested );
            }
        }
        else {
            push( @params, $param );
        }
    }
    my $param_count = scalar(@params);

    #    #warn( "Params = " . Dumper( \@params ) );

    for ( my $count = 1 ; $count <= $param_count ; $count++ ) {
        my $param = shift(@params);
        my $value = $param->value();

        my %type = ();

        if ( $param->type ) {
            $type{type} = $param->type();
        }

        # #warn("bind value=$value \n");

        #
        if ( ref($value) eq 'ARRAY' ) {
            $sth->bind_param_array( $count, $value, %type );
            $exe_array = 1;

            #warn( "bind value=" . ref($value) . "\n" );
        }
        else {
            if ( $self->use_named_params ) {
                $sth->bind_param( ":p_" . $param->name(), $value, %type );
            }
            else {
                $sth->bind_param( $count, $value, %type );
            }
        }
    }
    my @returns = undef;

    if (    ( $self->returning() )
        and ( $self->_operation() ne Database::Accessor::Constants::RETRIEVE ) )
    {
        my @params       = $self->returning()->params();
        my $return_count = scalar(@params);
        @returns = ( 1 .. $return_count );
        for ( my $count = 1 ; $count <= $return_count ; $count++ ) {
            my $param = shift(@params);
            my %type  = ();
            if ( $param->type ) {
                $type{type} = $param->type();
            }
            if ( $self->use_named_params ) {
                $sth->bind_param_inout(
                    ":p_" . $param->name(),
                    \$returns[ $count - 1 ],
                    '100', %type
                );
            }
            else {
                $sth->bind_param_inout(
                    $count + $param_count,
                    \$returns[ $count - 1 ],
                    '100', %type
                );
            }

        }
    }
    if ( $self->_operation() eq Database::Accessor::Constants::RETRIEVE ) {

        #warn("JPS exe");
        $sth->execute();

        # #warn("JPS exe2 container=".ref($container));

        $container = []
          if ( !$container );

        if ( ref($container) eq 'ARRAY' ) {
            my $results = $sth->fetchall_arrayref();

            #  push(@{$container},@{$results});
            $self->results($results);
        }
        elsif ( ref($container) eq "HASH" or $container->isa("UNIVERSAL") ) {
            my @key_fields = $self->_identity_keys()
              ;    #(ref $key_field) ? @$key_field : ($key_field);
            if ( !scalar(@key_fields) ) {
                die
"error: DBIx::DA:::SQL->execute attempt to use a HASH Ref as container without a DBIx::DA::Field without an is_identity attribute!";
            }
            my $hash_key_name = $sth->{FetchHashKeyName} || 'NAME_lc';
            if ( $hash_key_name eq 'NAME' or $hash_key_name eq 'NAME_uc' ) {
                @key_fields = map( uc($_), @key_fields );
            }
            else {
                @key_fields = map( lc($_), @key_fields );
            }
            my $names_hash = $sth->FETCH("${hash_key_name}_hash");
            my @key_indexes;
            my $num_of_fields = $sth->FETCH('NUM_OF_FIELDS');
            foreach (@key_fields) {

                my $index = $names_hash->{$_};    # perl index not column
                $index = $_ - 1
                  if !defined $index
                      && DBI::looks_like_number($_)
                      && $_ >= 1
                      && $_ <= $num_of_fields;
                return $sth->set_err( $DBI::stderr,
"Field '$_' does not exist (not one of @{[keys %$names_hash]})"
                ) unless defined $index;
                push @key_indexes, $index;
            }
            my $NAME = $sth->FETCH($hash_key_name);
            my @row  = (undef) x $num_of_fields;
            $sth->bind_columns( \(@row) );

            while ( $sth->fetch ) {

                if ( ref($container) eq "HASH" ) {
                    my $ref = $container;    #();#$rows;
                    $ref = $ref->{ $row[$_] } ||= {} for @key_indexes;
                    @{$ref}{@$NAME} = @row;
                    $self->push_results($ref);
                }
                else {
                    my $new_item = $container->new();

                    ##warn(ref($container));
                    foreach my $key ( keys( %{$names_hash} ) ) {

                        $new_item->$key( $row[ $names_hash->{$key} ] )
                          if ( $new_item->can($key) );

                        # #$ref = $ref->$row[$_]} ||= {} for @key_indexes;
                    }

                    $new_item = {%$new_item}
                      if ( $opts->{CLASS_AS_HASH} );

                    $self->push_results($new_item);

                }

            }

        }
    }
    else {
        if ($exe_array) {

            ##warn("exe array here\n");
            my @tuple_status;

            my $tuples =
              $sth->execute_array( { ArrayTupleStatus => \@tuple_status } );

            $self->rows_effected( scalar($tuples) );

        }
        else {
            my $rows_effected = $sth->execute();
            $self->rows_effected($rows_effected);
            if (@returns) {
                $self->push_results( \@returns );
            }

        }
        $dbh->commit();
    }

    $dbh->{dbd_verbose} = 0;

##warn("end SQL iam a ".ref($self));
# #warn("In I  have ".ref($self)." predicate = ".scalar($self->dynamic_predicates));
# $self->dynamic_joins([]);
# $self->dynamic_predicates([]);
# #warn("Out I  have predicate = ".$self->dynamic_predicates);
#
}



sub DB_Class {
    my $self = shift;
    return 'DBI::db';
}

# DADNote I use one sub for each of the 4 crud functions

sub _insert_clause {
    
    my $self             = shift;
    my ($container)      = @_;
    my $delimiter        = "";
    my $field_clause     = "";
    my $value_clause     = "";
    my @fields_to_insert = $self->fields();
    my $sql =
      Database::Accessor::Driver::DBI::SQL::INSERT . " INTO " . $self->table()->name();

    #$container->isa();

    if ( ref($container) eq "DBIx::DA::SQL" ) {    #insert with select
        foreach my $field  ( $self->fields ) {
           
           next
             if (($field->table() and $field->table() ne $self->table()->name())
                  or ($field->no_insert() or $field->expression()));
                  
            $field_clause  .= $delimiter . $field->name();
            $delimiter = ", ";
        }
        $sql .= " (" . $field_clause . " ) " . $container->_select_clause();

        foreach my $sub_param ( @{$container->_params()} ) {
            $self->add_params($sub_param);
        }
    }
    else {

        @fields_to_insert = ();

        foreach my $key ( keys( %{$container} ) ) {

            my $field = $self->find_field(sub {$_->name eq $key});
            next
              unless $field;
            next 
              if $field->no_insert();
            use Data::Dumper;
            $field_clause .= $delimiter . $field->name();
            if ( $field->is_identity() and $field->sequence() ) {
                    $value_clause .= $field->sequence() . ".nextval";
                    $self->returning(
                        DBIx::DA::Returning->new(
                            {
                                params => [
                                    DBIx::DA::Param->new(
                                        {
                                            name  => $field->name(),
                                            value => \$field
                                        }
                                    )
                                ]
                            }
                        )
                    );
             }
             elsif ($container->{$key} eq 'sysdate' ) { #others as well
                    $value_clause .= "sysdate";
             }
             else {
               my $param =  DBIx::DA::Param->new({value=> $container->{$key}});
               
               $self->_add_param($param);
                  
               $value_clause.= $delimiter
                               .$param->sql($self);
                $delimiter = ", ";
             }    
        }

        $sql .= " (" . $field_clause . " ) VALUES (" . $value_clause . ")";

        # if ( $self->returning() ) {
            # $sql .= $self->_returning_clause();
        # }
    }
    return $sql;
}

1;