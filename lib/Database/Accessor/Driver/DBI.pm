package Database::Accessor::Driver::DBI;

# ABSTRACT: The DBI (SQL) driver for Database Accessor
# Dist::Zilla: +PkgVersion

# DADNote: the DAD writer should use this set of constants will save time and becuse DA has to me installed this will be as well
use lib "D:/GitHub/database-accessor-driver-dbi/lib";
use lib "D:/GitHub/database-accessor/lib";
use Data::Dumper;
use Database::Accessor::Constants;
use Database::Accessor::Driver::DBI::SQL;
use JSON qw(encode_json);
use Moose;
with(qw( Database::Accessor::Roles::Driver));

has dbh => (
    is  => 'rw',
    isa => 'DBI::db',
);

has is_exe_array => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has _aggregate_count => (
    traits  => ['Counter'],
    is      => 'rw',
    default => 0,
    isa     => 'Int',
    handles => {
        _inc_aggregate   => 'inc',
        _dec_aggregate   => 'dec',
        _reset_aggregate => 'reset'
    }
);

# DADNote you will get an empty result class that you will have to fill .
# DADNote trap all errors and return via that class

# sub da_warn {
# my $self       = shift;
# my ($message) =  @_;
# warn("Database::Accessor::Driver::DBI: $message ")
# if ($self->da_warn );
# }

sub execute {
    
    
    my $self = shift;
    
    my ( $result, $action, $dbh, $container, $opt ) = @_;
    local $dbh->{PrintError} = 0;
    local $dbh->{RaiseError} = 1
      unless ( $self->da_raise_error_off );
    $self->dbh($dbh);

    my $sql;
    if ( $action eq Database::Accessor::Constants::CREATE ) {

        $sql = $self->_insert($container);
    }
    elsif ( $action eq Database::Accessor::Constants::UPDATE ) {
        $sql = $self->_update($container);
       # $sql .= $self->_join_clause();
        $sql .= $self->_where_clause();

    }
    elsif ( $action eq Database::Accessor::Constants::DELETE ) {
        $sql = $self->_delete();
        #$sql .= $self->_join_clause();
        $sql .= $self->_where_clause();

    }
    else {
        $sql = $self->_select();
        $sql .= $self->_join_clause();
        $sql .= $self->_where_clause();
        $sql .= $self->_group_by_clause();
        $sql .= $self->_order_by_clause();
    }

    $result->query($sql);
    $self->da_warn( 'execute', "SQL=$sql" )
      if $self->da_warning() >= 1;

    if ( $self->is_exe_array() ) {
        my $params = $self->params();
        foreach my $tuple ( @{$params} ) {
            if ( ref($tuple) eq "ARRAY" ) {
                my @tuple = map( { $_->value } @{$tuple} );
                $result->add_param( \@tuple );
            }
            else {
                $result->add_param( $tuple->value );
            }
        }
    }
    else {
        $result->params( [ map( { $_->value } @{ $self->params } ) ] );
    }

    return 1
      if $self->da_compose_only();

    my $sth;

    eval {

        $sth = $dbh->prepare($sql);
        foreach my $index ( 1 .. $self->param_count() ) {
            if ( $self->is_exe_array() ) {
                my $tuple = $result->params()->[ $index - 1 ];
                $sth->bind_param_array( $index, $tuple );
            }
            else {
                $sth->bind_param( $index,
                    $self->params->[ $index - 1 ]->value );
            }

        }

        if ( $action eq Database::Accessor::Constants::RETRIEVE ) {
            $sth->execute();
            my $results;
            
            if (!$self->is_ArrayRef()) {
                while (my $hash_ref = $sth->fetchrow_hashref(Database::Accessor::Driver::DBI::SQL::DA_KEY_CASE->{$self->da_key_case})) {
                    if ($self->is_Class() and $self->da_result_class()){
                        my $class=$self->da_result_class();
                        my $new =  $class->new($hash_ref);
                        push(@{$results},$new);
                    }
                    elsif ($self->is_JSON()){
                        push(@{$results},JSON::encode_json($hash_ref));                    }
                    else {
                        push(@{$results},$hash_ref);
                    }
                };
            }
            else {
                $results = $sth->fetchall_arrayref();
            }
            $result->set($results);
        }
        else {
            my $rows_effected;
            if ( $self->is_exe_array() ) {
                my @tuple_status;

                $sth->execute_array( { ArrayTupleStatus => \@tuple_status } );
                $rows_effected = scalar(@tuple_status);
                $result->set( \@tuple_status );
            }
            else {
                $rows_effected = $sth->execute();
            }
            $result->effected($rows_effected);
        }

        $dbh->commit()
          if ( $dbh->{AutoCommit} == 0 and !$self->da_no_effect );

    };

    if ($@) {
        $result->is_error(1);
        $result->error($@);
        return 0;
    }
    
    
    return 1;

}

sub DB_Class {
    my $self = shift;
    return 'DBI::db';
}

# DADNote I use one sub for each of the 4 crud functions
# DADNote I will allways need a container on an Insert otherwise how do I know what to insert So lets put that in the DA

sub _order_by_clause {
    my $self = shift;
    return ""
      unless ( $self->sort_count );
    my @sorts;

    foreach my $sort ( @{ $self->sorts() } ) {
        my $sql = $self->_field_sql( $sort, 1 );
        $sql .= " " . Database::Accessor::Driver::DBI::SQL::DESC
          if $sort->descending;
        push( @sorts, $sql );
    }

    return " "
      . join( " ",
        Database::Accessor::Driver::DBI::SQL::ORDER_BY,
        join( ", ", @sorts ) );
}

sub _group_by_clause {
    my $self = shift;
    return ""
      unless ( $self->gather );
    my $having = $self->gather;

    my $group_by = " "
      . join( " ",
        Database::Accessor::Driver::DBI::SQL::GROUP_BY,
        $self->_fields_sql( $having->elements() ) );
    $group_by .= join(
        " ", "",
        Database::Accessor::Driver::DBI::SQL::HAVING,
        $self
          ->_predicate_clause( Database::Accessor::Driver::DBI::SQL::GROUP_BY,
            $having->conditions
          )
    ) if ( $self->gather->condition_count >= 1 );
    return $group_by;

    return " "
      . join(
        " ",
        Database::Accessor::Driver::DBI::SQL::GROUP_BY,
        $self->_fields_sql( $having->elements() ),
        $having->condition_count >= 1
        ? join(
            " ",
            Database::Accessor::Driver::DBI::SQL::HAVING,
            $self->_predicate_clause
              ( Database::Accessor::Driver::DBI::SQL::GROUP_BY,
                $having->conditions
              )
          )
        : ""
      );
}

sub _where_clause {
    my $self = shift;
    return ""
      unless ( $self->condition_count );
    return " "
      . join(
        " ",
        Database::Accessor::Driver::DBI::SQL::WHERE,
        $self->_predicate_clause( Database::Accessor::Driver::DBI::SQL::WHERE,
            $self->conditions
        )
      );
}

sub _join_clause {
    my $self = shift;
    return ""
      unless ( $self->link_count );

    my @join_clauses = ();

    foreach my $join ( @{ $self->links() } ) {
        my $clause = join(
            " ",
            $join->type,
            ,
            Database::Accessor::Driver::DBI::SQL::JOIN,
            $self->_table_sql( $join->to, 1 ),
            Database::Accessor::Driver::DBI::SQL::ON,
            $self->_predicate_clause(
                Database::Accessor::Driver::DBI::SQL::JOIN,
                $join->conditions(),
                $join->to
            )
        );

        push( @join_clauses, $clause );
    }

    return " " . join( " ", @join_clauses );
}

sub _predicate_clause {
    my $self = shift;
    my ( $clause_type, $conditions,$view ) = @_;
    my $predicate_clause = "";

    # warn("constion-".Dumper($conditions));
    foreach my $condition ( @{$conditions} ) {
        if ( ref($condition) eq 'Database::Accessor::Condition' ) {

            # foreach my $predicate (  $condition->predicates } ) {
            $predicate_clause .=
              $self->_predicate_sql( $condition->predicates,$view );

            # }
        }
        else {
            $predicate_clause .= $self->_predicate_sql($condition,$view);

        }
    }
    $self->da_warn( "_predicate_clause",
        $clause_type . " clause='$predicate_clause'" )
      if $self->da_warning() >= 5;
    return $predicate_clause;
}

sub _predicate_sql {
    my $self = shift;
    my ($predicate,$view) = @_;

     # warn("_predicate_sql".Dumper($predicate));
    my $clause = "";
    $clause .= " " . $predicate->condition() . " "
      if ( $predicate->condition() );

    $clause .= Database::Accessor::Driver::DBI::SQL::OPEN_PARENS . " "
      if ( $predicate->open_parentheses() );

    my $message = "Database::Accessor::Driver::DBI::Error->Operator ";
    if ( Database::Accessor::Driver::DBI::SQL::SIMPLE_OPERATORS
        ->{ $predicate->operator } )
    {
        $clause .= join( " ",
            $self->_field_sql( $predicate->left, 1 ),
            $predicate->operator, $self->_field_sql( $predicate->right, 1,$view ) );
    }
    elsif (
           $predicate->operator eq Database::Accessor::Driver::DBI::SQL::IS_NULL
        or $predicate->operator eq
        Database::Accessor::Driver::DBI::SQL::IS_NOT_NULL )
    {

        $clause .= join( " ",
            $self->_field_sql( $predicate->left, 1 ),
            $predicate->operator );

    }
    elsif ($predicate->operator eq Database::Accessor::Driver::DBI::SQL::EXISTS
        or $predicate->operator eq
        Database::Accessor::Driver::DBI::SQL::NOT_EXISTS
        or $predicate->operator eq Database::Accessor::Driver::DBI::SQL::ALL
        or $predicate->operator eq Database::Accessor::Driver::DBI::SQL::ANY )
    {

        die "$message '"
          . $predicate->operator
          . "' left must be a Database::Accessor::Param with the value pointing to a Database::Accessor. Not a "
          . ref( $predicate->left ) . "!"
          unless ( ( ref( $predicate->left ) eq 'Database::Accessor::Param' )
            and ( ref( $predicate->left->value ) eq "Database::Accessor" ) );

        $clause .= join( " ",
            $predicate->operator,
            Database::Accessor::Driver::DBI::SQL::OPEN_PARENS
              . $self->_field_sql( $predicate->left, 1 )
              . Database::Accessor::Driver::DBI::SQL::CLOSE_PARENS );
    }
    elsif ($predicate->operator eq Database::Accessor::Driver::DBI::SQL::LIKE
        or $predicate->operator eq
        Database::Accessor::Driver::DBI::SQL::NOT_LIKE )
    {

        die(    "$message '"
              . $predicate->operator
              . "' left can not be an Array Ref!" )
          if ( ref( $predicate->left() ) eq 'ARRAY' );

        die(    "$message '"
              . $predicate->operator
              . "' right can not be an Array Ref!" )
          if ( ref( $predicate->right() ) eq 'ARRAY' );

        $clause .= join( " ",
            $self->_field_sql( $predicate->left, 1 ),
            $predicate->operator, $self->_field_sql( $predicate->right, 1,$view ) );
    }
    elsif (
        $predicate->operator eq Database::Accessor::Driver::DBI::SQL::BETWEEN )
    {
        die("$message 'BETWEEN' right must be an Array Ref of two parameters!")
          if ( ( ref( $predicate->right() ) ne 'ARRAY' )
            or scalar( @{ $predicate->right() } ) != 2 );
        die("$message 'BETWEEN' left can not be an Array Ref!")
          if ( ref( $predicate->left() ) eq 'ARRAY' );

        $clause .= join(
            " ",
            $self->_field_sql( $predicate->left, 1 ),
            join( " ",
                Database::Accessor::Driver::DBI::SQL::BETWEEN,
                $self->_field_sql( $predicate->right->[0], 1,$view ),
                Database::Accessor::Driver::DBI::SQL::AND,
                $self->_field_sql( $predicate->right->[1], 1,$view ) )
        );
    }
    elsif ($predicate->operator eq Database::Accessor::Driver::DBI::SQL::IN
        || $predicate->operator eq
        Database::Accessor::Driver::DBI::SQL::NOT_IN )
    {

        die(    "$message '"
              . $predicate->operator
              . "' left can not be an Array Ref!" )
          if ( ref( $predicate->left() ) eq 'ARRAY' );

        if ( ref( $predicate->right() ) eq "ARRAY" ) {
            my $not_count = 0;
            foreach my $param ( @{ $predicate->right() } ) {
                $not_count++
                  if (  ref($param) eq "Database::Accessor::Param"
                    and ref( $param->value ) eq "Database::Accessor" );
            }
            die(    "$message '"
                  . $predicate->operator
                  . "' Array Ref can not contain a Database::Accessor" )
              if ( $not_count
                and scalar( @{ $predicate->right() } ) != $not_count );
        }

        $clause .= join( " ",
            $self->_field_sql( $predicate->left, 1 ),
            $predicate->operator(),
            Database::Accessor::Driver::DBI::SQL::OPEN_PARENS
              . $self->_field_sql( $predicate->right, 1,$view )
              . Database::Accessor::Driver::DBI::SQL::CLOSE_PARENS );

    }

    $clause .= " " . Database::Accessor::Driver::DBI::SQL::CLOSE_PARENS
      if ( $predicate->close_parentheses() );
    $self->da_warn( "_predicate_sql", " clause='$clause'" )
      if $self->da_warning() >= 6;
    return $clause;
}

sub _field_sql {
    my $self = shift;
    my ( $element, $use_view,$in_view ) = @_;

 # warn("JPS ".Dumper($in_view).",use_view=$use_view");
    # my ($package, $filename, $line) = caller;
    # warn(" line=$line")
    # if (!$use_view);
    if ( ref($element) eq "Database::Accessor::If" ) {
        my @thens = ();
        my $last  = $element->get_if(-1);

        for ( my $index = 0 ; $index <= $element->if_count() - 2 ; $index++ ) {
            my $then = $element->get_if($index);
            if ( ref($then) eq "Database::Accessor::If::Then" ) {
                push(
                    @thens,
                    join( " ",
                        Database::Accessor::Driver::DBI::SQL::WHEN,
                        $self->_field_sql( $then, 0, ),
                        Database::Accessor::Driver::DBI::SQL::THEN,
                        $self->_field_sql( $then->then(), 0 ) )
                );
            }
            else {
                my $condition_sql;
                my $else;
                foreach my $condition ( @{$then} ) {
                    $condition_sql .= $self->_field_sql( $condition, 0 );
                    $else = $condition->then()
                      if ( $condition->then() );
                }
                push(
                    @thens,
                    join( " ",
                        Database::Accessor::Driver::DBI::SQL::WHEN,
                        $condition_sql,
                        Database::Accessor::Driver::DBI::SQL::THEN,
                        $self->_field_sql( $else, 0 ) )
                );
            }
        }

        return join( " ",
            Database::Accessor::Driver::DBI::SQL::CASE,
            @thens,
            Database::Accessor::Driver::DBI::SQL::ELSE,
            $self->_field_sql( $last->then(), 0 ),
            Database::Accessor::Driver::DBI::SQL::END_CASE );
    }
    elsif ( ref($element) eq "Database::Accessor::If::Then" ) {

        return $self->_predicate_sql($element);

    }
    elsif ( ref($element) eq "Database::Accessor::Expression" ) {
        my $left_sql;
        $left_sql = Database::Accessor::Driver::DBI::SQL::OPEN_PARENS
          if ( $element->open_parentheses() );

        $left_sql .= $self->_field_sql( $element->left(), $use_view );
        my @right_sql;
        if ( ref( $element->right() ) ne "Array" ) {
            my $param = $element->right();
            $element->right( [$param] )
              if ($param);
        }
        foreach my $param ( @{ $element->right() } ) {
            push( @right_sql, $self->_field_sql( $param, $use_view ) );
        }
        my $right_sql = join( ',', @right_sql );
        $right_sql .= Database::Accessor::Driver::DBI::SQL::CLOSE_PARENS
          if ( $element->close_parentheses() );
        return join( " ", $left_sql, $element->expression, $right_sql );

    }
    elsif ( ref($element) eq "Database::Accessor::Function" ) {
        $self->_inc_aggregate()
          if (
            exists(
                Database::Accessor::Driver::DBI::SQL::AGGREGATES
                  ->{ $element->function }
            )
          );
        die(
"Database::Accessor::Driver::DBI::Error->Element! An Element can have only one Aggregate function! "
              . $element->function
              . " is not valid" )
          if ( $self->_aggregate_count() >= 2 );

        my $left_sql = $self->_field_sql( $element->left(), $use_view );
        my @right_sql;

        my $comma = "";
        if ( $element->right() ) {
            $comma = ",";
            if ( ref( $element->right() ) ne "Array" ) {
                my $param = $element->right();
                $element->right( [$param] );
            }
            foreach my $param ( @{ $element->right() } ) {

                # warn("user view=$use_view, function right=".Dumper($param));
                push( @right_sql, $self->_field_sql( $param, $use_view ) );
            }

        }

        # warn("rightSQL=".Dumper(\@right_sql));
        my $right_sql = join( ',', @right_sql );

        # warn("function $left_sql,$right_sql");
        return
            $element->function
          . Database::Accessor::Driver::DBI::SQL::OPEN_PARENS
          . $left_sql
          . $comma
          . $right_sql
          . Database::Accessor::Driver::DBI::SQL::CLOSE_PARENS;

    }
    elsif ( ref($element) eq "Database::Accessor::Param" ) {

        if ( ref( $element->value ) eq "Database::Accessor" ) {
            my $da = $element->value;
            $da->da_compose_only(1);
            $da->retrieve( $self->dbh() );
            my $sql = $da->result->query();

            foreach my $sub_param ( @{ $da->result->params() } ) {
                $self->add_param(
                    Database::Accessor::Param->new( { value => $sub_param } ) );
            }
            return $sql;
        }
        elsif ( ref( $element->value ) eq "ARRAY" ) {
            $self->is_exe_array(1);
        }
        $self->add_param($element);
        return Database::Accessor::Driver::DBI::SQL::PARAM;
    }
    elsif ( ref($element) eq "ARRAY" ) {

        my @clauses = ();
        foreach my $item ( @{$element} ) {
            push( @clauses, $self->_field_sql( $item, $use_view ) );
        }
        return join( ",", @clauses );

    }
    else {
        my $sql = $element->name;
        my $view = $element->view; 
        $view = $self->view->alias()
           if ($view eq $self->view->name() and  $self->view->alias());
        
        if (!$view and $in_view) {
             $view = $in_view->name();
             $view = $in_view->alias()
               if ($in_view->alias());
        }
        $sql = $view . "." . $element->name
          if ( $use_view and !$self->da_suppress_view_name );

        return $sql;

    }

}

sub _table_sql {
    my $self = shift;
    my ( $view, $use_alias ) = @_;

    my $sql = $view->name;

    $sql = join( " ", $view->name, $view->alias )
      if ( $use_alias and $view->alias() );
    return $sql;

}

sub _delete {

    my $self        = shift;
    my ($container) = @_;
    my @fields      = ();

    my $delete_clause = join( " ",
        Database::Accessor::Driver::DBI::SQL::DELETE,
        Database::Accessor::Driver::DBI::SQL::FROM,
        $self->_table_sql( $self->view ) );

    $self->da_warn( "_delete", "Delete clause='$delete_clause'" )
      if $self->da_warning() >= 5;
    return $delete_clause;

}

sub _fields_sql {
    my $self       = shift;
    my ($elements) = @_;
    my @fields     = ();
    foreach my $field ( @{$elements} ) {
        $self->_reset_aggregate();
        my $sql = $self->_field_sql( $field, 1 );
        if ( $field->alias() ) {
            my $alias = $field->alias();
            $alias = '"' . $alias . '"'
                if ( index( $alias, " " ) != -1 or $self->is_Native);

            $sql .= join( " ", "", $alias );
        }
        push( @fields, $sql );

    }
    my $sql = join( ", ", @fields );
    return $sql;
}

sub _select {

    my $self          = shift;
    my ($container)   = @_;
    my $select_clause = join( " ",
        Database::Accessor::Driver::DBI::SQL::SELECT,
        $self->_fields_sql( $self->elements() ) );
    $self->da_warn( "_select", "Select clause='$select_clause'" )
      if $self->da_warning() >= 5;

    my $from_clause = join( " ",
        Database::Accessor::Driver::DBI::SQL::FROM,
        $self->_table_sql( $self->view, 1 ) );

    $self->da_warn( "_select", " From clause='$from_clause'" )
      if $self->da_warning() >= 5;

    return join( " ", $select_clause, $from_clause );

}

sub _die_on_identity {
    my $self = shift;
    my ($action, $field)    = @_;
           die "Database::Accessor::Driver::DBI::Error->"
        . "Attempt to use identity element: "
        . $field
        . " in an "
       . lc($action);
}


sub _insert_update_container {
    my $self = shift;
    my ( $action, $container ) = @_;

    my @field_sql = ();
    if ( ref($container) eq "ARRAY" ) {
        my @fields = ();
        $self->is_exe_array(1);
        my $fields = $container->[0];
        foreach my $key ( sort( keys( %{$fields} ) ) ) {
            my $field = $self->get_element_by_name($key);
            next
              if ( !$field );
            $self->_die_on_identity($action,$key)
              if ($field->identity);

            push( @fields, $field );
            if ( $action eq Database::Accessor::Constants::UPDATE ) {
                push(
                    @field_sql,
                    join( " ",
                        $self->_field_sql($field), '=',
                        Database::Accessor::Driver::DBI::SQL::PARAM )
                );
                 $self->add_param( [] );
            }
            else {
                $self->add_param( [] );
                push( @field_sql, $self->_field_sql($field) );
            }
          
           
        }
       
       foreach my $tuple ( @{$container} ) {
            my $index = 0;
            foreach my $field (@fields) {
                my $param = Database::Accessor::Param->new(
                    { value => $tuple->{ $field->name() } } );
                push( @{ $self->params->[$index] }, $param );
                $index++;
            }
        }
      
    }
    else {
        foreach my $key ( sort( keys( %{$container} ) ) ) {
            my $field = $self->get_element_by_name($key);
            next
              if ( !$field );
            $self->_die_on_identity($action,$key)
              if ($field->identity);

            if ( $action eq Database::Accessor::Constants::UPDATE ) {
                push(
                    @field_sql,
                    join(
                        " ",
                        $self->_field_sql($field),
                        '=',
                        $self->_field_sql(
                            Database::Accessor::Param->new(
                                { value => $container->{$key} }
                            )
                        )
                    )
                );
            }
            else {
                my $param = Database::Accessor::Param->new(
                        { value => $container->{$key} } );
                     $self->add_param($param);
                push( @field_sql, $self->_field_sql($field) );

            }
        }
    }
    return (@field_sql);
}

sub _update {

    my $self = shift;
    my ($container) = @_;

    #my @fields           = ();
    # my @values           = ();

    my $update_clause = join( " ",
        Database::Accessor::Driver::DBI::SQL::UPDATE,
        $self->_table_sql( $self->view ) );

    $self->da_warn( "_update", "Update clause='$update_clause'" )
      if $self->da_warning() >= 5;

    my (@field_sql) =
      $self->_insert_update_container( Database::Accessor::Constants::UPDATE,
        $container );


# foreach my $key ( sort(keys( %{$container} )) ) {
# my $field = $self->get_element_by_name($key);
# next
# if(!$field);
# push(@fields,join(" ",
# $self->_field_sql($field),
# '=',
# $self->_field_sql(Database::Accessor::Param->new({value=> $container->{$key}}))));
# }

    my $set_clause = join( " ",
        Database::Accessor::Driver::DBI::SQL::SET,
        join( ", ", @field_sql ) );

    $self->da_warn( "_update", " Set clause='$set_clause'" )
      if $self->da_warning() >= 5;

    return join( " ", $update_clause, $set_clause );

}

sub _insert {

    my $self = shift;
    my ($container) = @_;

    #my @fields           = ();
    #my @ field_sql        = ();

    my $insert_clause = join( " ",
        Database::Accessor::Driver::DBI::SQL::INSERT,
        Database::Accessor::Driver::DBI::SQL::INTO,
        $self->_table_sql( $self->view ) );

    $self->da_warn( "_insert", "Insert clause='$insert_clause'" )
      if $self->da_warning() >= 5;

    my (@field_sql) =
      $self->_insert_update_container( Database::Accessor::Constants::CREATE,
        $container );
            my @params =  @{ $self->params() };
    if ($self->identity_index() >=0){
       my $field = $self->elements()->[$self->identity_index()];
       my $identity = $field->identity();
       
       if (exists(
            $identity->{ $self->DB_Class }->{ $self->dbh()->{Driver}->{Name} }
        )){
            my $new_field = Database::Accessor::Element->new($identity->{ $self->DB_Class }->{ $self->dbh()->{Driver}->{Name}} );
            unshift(@params,$new_field);
            unshift(@field_sql,$self->_field_sql($field));
            
       }    } 
    my $fields_clause = join( " ",
        Database::Accessor::Driver::DBI::SQL::OPEN_PARENS,
        join( ", ", @field_sql ),
        Database::Accessor::Driver::DBI::SQL::CLOSE_PARENS );

    $self->da_warn( "_insert", " Fields clause='$fields_clause'" )
      if $self->da_warning() >= 5;

    my $values_clause = Database::Accessor::Driver::DBI::SQL::VALUES
      . join(
        " ",
        Database::Accessor::Driver::DBI::SQL::OPEN_PARENS,
        join(
            ", ",
            map( {  
                    (ref($_) eq 'Database::Accessor::Param' 
                    or ref($_) eq 'ARRAY')
                    ? Database::Accessor::Driver::DBI::SQL::PARAM
                    : $self->_field_sql( $_, 1 )
                } @params )
        ),
        Database::Accessor::Driver::DBI::SQL::CLOSE_PARENS
      );

    $self->da_warn( "_insert", " Values clause='$values_clause'" )
      if $self->da_warning() >= 5;

    return join( " ", $insert_clause, $fields_clause, $values_clause );

}

1;
