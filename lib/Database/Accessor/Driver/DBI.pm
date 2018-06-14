package Database::Accessor::Driver::DBI;
# ABSTRACT: The DBI (SQL) driver for Database Accessor
# Dist::Zilla: +PkgVersion

# DADNote: the DAD writer should use this set of constants will save time and becuse DA has to me installed this will be as well
use lib "D:/GitHub/database-accessor-driver-dbi/lib";
use lib "D:/GitHub/database-accessor/lib";
use Data::Dumper;
use Database::Accessor::Constants;
use Database::Accessor::Driver::DBI::SQL;
use Moose;
with(qw( Database::Accessor::Roles::Driver));


 has dbh => (
            is  => 'rw',
            isa => 'DBI::db',
     );
 has is_exe_array => (
            is  => 'rw',
            isa => 'Bool',
            default     => 0,
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

    local $dbh->{RaiseError} = 1
      unless($self->da_raise_error_off);
    $self->dbh($dbh);
    
    my $sql;
    if ( $action eq Database::Accessor::Constants::CREATE ) {
        $sql = $self->_insert($container);
    }
    elsif ( $action eq Database::Accessor::Constants::UPDATE ) {
        $sql = $self->_update($container);
    }
    elsif ( $action eq Database::Accessor::Constants::DELETE ) {
        $sql = $self->_delete();
    }
    else {
        $sql = $self->_select();
    }
    
    $sql .= $self->_where_clause()
     if ($action ne Database::Accessor::Constants::CREATE);

    $result->query($sql);
    $self->da_warn('execute',"SQL=$sql")
      if $self->da_warning()>=1;
    
    if ($self->is_exe_array()){
      my $params = $self->params();

      foreach my $tuple (@{$params}){
        if (ref($tuple) eq "ARRAY"){
           my @tuple = map({$_->value} @{$tuple} );
           $result->add_param(\@tuple);
         }
         else {
           $result->add_param($tuple->value);
         }
      }
    }
    else {
      $result->params([map({$_->value} @{$self->params} )]);
    }
    
    return 1
       if $self->da_compose_only();
       
    my $sth;

    eval {
        
        $sth = $dbh->prepare($sql);
        foreach my $index (1..$self->param_count()){
          if ($self->is_exe_array()){
            my $tuple = $result->params()->[$index-1];
            $sth->bind_param_array($index,$tuple);
          }
          else {
           $sth->bind_param( $index,$self->params->[$index-1]->value ); 
          }
        }
        
        if ($action eq Database::Accessor::Constants::RETRIEVE) {
           $sth->execute();
           my $results = $sth->fetchall_arrayref(); 
           $result->set($results);
        }
        else {
           my $rows_effected;
           if ($self->is_exe_array()){
             my @tuple_status;
 
             $sth->execute_array( { ArrayTupleStatus => \@tuple_status });
             $rows_effected = scalar(@tuple_status);
             $result->set(\@tuple_status);
           }
           else {
             $rows_effected = $sth->execute();
           }
           $result->effected($rows_effected);
        }
        
        $dbh->commit()
          if ($dbh->{AutoCommit} == 0 and !$self->da_no_effect);

    };

    if ($@) {
       $result->is_error(1);
       $result->error($@);
       return 0;
    }
    return 1;
    
    

    my @params; 
       # = $self->_params();

    # foreach my $param ( @{ $self->_params() } ) {
        # my $value = $param->value();

        # if ( $value and $value->isa("DBIx::DA::SQL") ) {
            # foreach my $nested ( $value->_params ) {    #this needs to recurse
                # push( @params, $nested );
            # }
        # }
        # else {
            # push( @params, $param );
        # }
    # }
    # my $param_count = scalar(@params);

    # #    #warn( "Params = " . Dumper( \@params ) );

    # for ( my $count = 1 ; $count <= $param_count ; $count++ ) {
        # my $param = shift(@params);
        # my $value = $param->value();

        # my %type = ();

        # if ( $param->type ) {
            # $type{type} = $param->type();
        # }

        # # #warn("bind value=$value \n");

        # #
        # if ( ref($value) eq 'ARRAY' ) {
            # $sth->bind_param_array( $count, $value, %type );
            # # $exe_array = 1;

            # #warn( "bind value=" . ref($value) . "\n" );
        # }
        # else {
            # if ( $self->use_named_params ) {
                # $sth->bind_param( ":p_" . $param->name(), $value, %type );
            # }
            # else {
                # $sth->bind_param( $count, $value, %type );
            # }
        # }
    # }
    # my @returns = undef;

    # if (    ( $self->returning() )
        # and ( $self->_operation() ne Database::Accessor::Constants::RETRIEVE ) )
    # {
        # my @params       = $self->returning()->params();
        # my $return_count = scalar(@params);
        # @returns = ( 1 .. $return_count );
        # for ( my $count = 1 ; $count <= $return_count ; $count++ ) {
            # my $param = shift(@params);
            # my %type  = ();
            # if ( $param->type ) {
                # $type{type} = $param->type();
            # }
            # if ( $self->use_named_params ) {
                # $sth->bind_param_inout(
                    # ":p_" . $param->name(),
                    # \$returns[ $count - 1 ],
                    # '100', %type
                # );
            # }
            # else {
                # $sth->bind_param_inout(
                    # $count + $param_count,
                    # \$returns[ $count - 1 ],
                    # '100', %type
                # );
            # }

        # }
    # }
    # if ( $self->_operation() eq Database::Accessor::Constants::RETRIEVE ) {

        # #warn("JPS exe");
        # $sth->execute();

        # # #warn("JPS exe2 container=".ref($container));

        # $container = []
          # if ( !$container );

        # if ( ref($container) eq 'ARRAY' ) {
            # my $results = $sth->fetchall_arrayref();

            # #  push(@{$container},@{$results});
            # $self->results($results);
        # }
        # elsif ( ref($container) eq "HASH" or $container->isa("UNIVERSAL") ) {
            # my @key_fields = $self->_identity_keys()
              # ;    #(ref $key_field) ? @$key_field : ($key_field);
            # if ( !scalar(@key_fields) ) {
                # die
# "error: DBIx::DA:::SQL->execute attempt to use a HASH Ref as container without a DBIx::DA::Field without an is_identity attribute!";
            # }
            # my $hash_key_name = $sth->{FetchHashKeyName} || 'NAME_lc';
            # if ( $hash_key_name eq 'NAME' or $hash_key_name eq 'NAME_uc' ) {
                # @key_fields = map( uc($_), @key_fields );
            # }
            # else {
                # @key_fields = map( lc($_), @key_fields );
            # }
            # my $names_hash = $sth->FETCH("${hash_key_name}_hash");
            # my @key_indexes;
            # my $num_of_fields = $sth->FETCH('NUM_OF_FIELDS');
            # foreach (@key_fields) {

                # my $index = $names_hash->{$_};    # perl index not column
                # $index = $_ - 1
                  # if !defined $index
                      # && DBI::looks_like_number($_)
                      # && $_ >= 1
                      # && $_ <= $num_of_fields;
                # return $sth->set_err( $DBI::stderr,
# "Field '$_' does not exist (not one of @{[keys %$names_hash]})"
                # ) unless defined $index;
                # push @key_indexes, $index;
            # }
            # my $NAME = $sth->FETCH($hash_key_name);
            # my @row  = (undef) x $num_of_fields;
            # $sth->bind_columns( \(@row) );

            # while ( $sth->fetch ) {

                # if ( ref($container) eq "HASH" ) {
                    # my $ref = $container;    #();#$rows;
                    # $ref = $ref->{ $row[$_] } ||= {} for @key_indexes;
                    # @{$ref}{@$NAME} = @row;
                    # $self->push_results($ref);
                # }
                # else {
                    # my $new_item = $container->new();

                    # ##warn(ref($container));
                    # foreach my $key ( keys( %{$names_hash} ) ) {

                        # $new_item->$key( $row[ $names_hash->{$key} ] )
                          # if ( $new_item->can($key) );

                        # # #$ref = $ref->$row[$_]} ||= {} for @key_indexes;
                    # }

                    # # $new_item = {%$new_item}
                      # # if ( $opts->{CLASS_AS_HASH} );

                    # $self->push_results($new_item);

                # }

            # }

        # }
    # }
    # else {
        # # if ($exe_array) {

            # # ##warn("exe array here\n");
            # # my @tuple_status;

            # # my $tuples =
              # # $sth->execute_array( { ArrayTupleStatus => \@tuple_status } );

            # # $self->rows_effected( scalar($tuples) );

        # # }
        # # else {
            # # my $rows_effected = $sth->execute();
            # # $self->rows_effected($rows_effected);
            # # if (@returns) {
                # # $self->push_results( \@returns );
            # # }

        # # }
        # $dbh->commit();
    # }

    # $dbh->{dbd_verbose} = 0;

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
# DADNote I will allways need a container on an Insert otherwise how do I know what to insert So lets put that in the DA

sub _where_clause {
    my $self = shift;
    return ""
      unless ( $self->condition_count );
    return
      $self->_predicate_clause( Database::Accessor::Driver::DBI::SQL::WHERE,
        $self->conditions );
}
sub _predicate_clause {
    my $self = shift;
    my ( $clause_type, $conditions ) = @_;
    my $clause           = " $clause_type";
    my $predicate_clause = "";

    foreach my $condition ( @{$conditions} ) {
        foreach my $predicate ( @{ $condition->{predicates} } ) {
          $predicate_clause .= $self->_predicate_sql($predicate);
        }
    }
    $self->da_warn( "_predicate_clause",
        $clause_type . " clause='$predicate_clause'" )
      if $self->da_warning() >= 5;
    return join( " ",$clause, $predicate_clause );
}

sub _predicate_sql {
    my $self = shift;
    my ($predicate) = @_;
    
    my $clause =  "";
       $clause .= " "
              .$predicate->condition()
              . " " 
     if ($predicate->condition());

    $clause .= Database::Accessor::Driver::DBI::SQL::OPEN_PARENS
              ." "
      if ( $predicate->open_parentheses() );
      
    if (Database::Accessor::Driver::DBI::SQL::SIMPLE_OPERATORS->{ $predicate->operator }){
       $clause .= join(" ",$self->_element_sql($predicate->left),
                $predicate->operator,
                $self->_element_sql($predicate->right));
      
    }
   $clause .= " "
           .Database::Accessor::Driver::DBI::SQL::CLOSE_PARENS
      if ( $predicate->close_parentheses() );
   $self->da_warn( "_predicate_sql",
                   " clause='$clause'" )
      if $self->da_warning() >= 6;
    return $clause;
}

sub _element_sql {
  my $self = shift;
  my ($element,$use_alias) = @_;
  
    if (ref($element) eq "Database::Accessor::Function"){
      my $left_sql = $self->_element_sql($element->left());
      my @right_sql;
      my @params;
      
      if (ref($element->right()) eq "Array"){
        @params= @{$element->right()};
      }
      else {
        push(@params,$element->right());      }
      foreach my $param (@params){
        push(@right_sql,$self->_element_sql($param));
      }              my $right_sql = join(',',@right_sql);
      return $element->function
             .Database::Accessor::Driver::DBI::SQL::OPEN_PARENS
             .$left_sql
             .','
             .$right_sql
             .Database::Accessor::Driver::DBI::SQL::CLOSE_PARENS;                            }
  elsif (ref($element) eq "Database::Accessor::Param"){
    if (ref($element->value) eq "Database::Accessor"){
      my $da = $element->value;
      $da->da_compose_only();
      $da->retrieve($self->dbh());
      my $sql = join(" ",
                     Database::Accessor::Driver::DBI::SQL::OPEN_PARENS,
                      $da->result->query(),
                     Database::Accessor::Driver::DBI::SQL::CLOSE_PARENS  );
                      
      foreach my $sub_param (@{$da->result->params()}){
        $self->add_param(Database::Accessor::Param->new({value=>$sub_param}));
      }
      return $sql;    }
    elsif (ref($element->value) eq "ARRAY"){
      $self->is_exe_array(1);
    }
    $self->add_param($element);
    return Database::Accessor::Driver::DBI::SQL::PARAM;
  }
  else {
    my $sql = $element->view
           ."."
           .$element->name;
    $sql .= join(" ",
                 "",
                 Database::Accessor::Driver::DBI::SQL::AS, 
                 $element->alias())
       if ($element->alias and $use_alias );
    return $sql;
       
  }
  
}

sub _view_sql {
  my $self = shift;
  my $view = $self->view()->name;
  $view = join(" ",
               $self->view()->name,
               $self->view()->alias)
    if $self->view()->alias();
  return $view;
              
}

sub _delete {
    
    my $self             = shift;
    my ($container)      = @_;
    my @fields           = ();

    my $delete_clause    = join(" ",Database::Accessor::Driver::DBI::SQL::DELETE
                                   ,Database::Accessor::Driver::DBI::SQL::FROM
                                   ,$self->_view_sql());
    
    $self->da_warn("_delete","Delete clause='$delete_clause'")
      if $self->da_warning()>=5;
    return $delete_clause;

}

sub _select {
    
    my $self             = shift;
    my ($container)      = @_;
    my @fields           = ();

    foreach my $field ( @{$self->elements()} ) {
        push(@fields,join(" ",
                        $self->_element_sql($field,1)));
       
    }
    my $select_clause    = join(" ",
                               Database::Accessor::Driver::DBI::SQL::SELECT,
                               join(", ",@fields));
    
    $self->da_warn("_select","Select clause='$select_clause'")
      if $self->da_warning()>=5;

    my $from_clause = join(" ",
                       Database::Accessor::Driver::DBI::SQL::FROM,
                       $self->_view_sql()
                       );
                        
    $self->da_warn("_select"," From clause='$from_clause'")
      if $self->da_warning()>=5;
    
    return join(" ",$select_clause,$from_clause);

}

sub _insert_update_container {
  my $self = shift;
  my ($action,$container) = @_;
  
  my @field_sql        = ();
  if (ref($container) eq "ARRAY"){
      my @fields           = ();
      $self->is_exe_array(1);
      my $fields = $container->[0];
      foreach my $key (sort(keys( %{$fields} )) ) {
        my $field = $self->get_element_by_name( $key);
        next
         if(!$field);
        push(@fields,$field);
        if ($action eq Database::Accessor::Constants::UPDATE){
           push(@field_sql,join(" ",
                          $self->_element_sql($field),
                          '=',
                          Database::Accessor::Driver::DBI::SQL::PARAM));
        }
        else {
          push(@field_sql, $self->_element_sql($field));
        }
        $self->add_param([]);
      }
      foreach my $tuple (@{$container}){
         my $index = 0;
         foreach my $field (@fields){
           my $param =  Database::Accessor::Param->new({value=> $tuple->{$field->name()}});
           push(@{$self->params->[$index]},$param);
           $index++;
         }
         
       }
    }
    else {
      foreach my $key ( sort(keys( %{$container} )) ) {
        my $field = $self->get_element_by_name( $key);
        next
         if(!$field);
         if ($action eq Database::Accessor::Constants::UPDATE){
           push(@field_sql,join(" ",
                          $self->_element_sql($field),
                          '=',
                          $self->_element_sql(Database::Accessor::Param->new({value=> $container->{$key}}))));
        }
        else {
           push(@field_sql, $self->_element_sql($field));
           my $param =  Database::Accessor::Param->new({value=> $container->{$key}});
           $self->add_param($param);
        }
      }
    }
    return (@field_sql);
}

sub _update {
    
    my $self             = shift;
    my ($container)      = @_;
    #my @fields           = ();
   # my @values           = ();
    
      
    my $update_clause    = join(" ",Database::Accessor::Driver::DBI::SQL::UPDATE, $self->_view_sql());
    
    $self->da_warn("_update","Update clause='$update_clause'")
      if $self->da_warning()>=5;

    my (@field_sql) = $self->_insert_update_container(Database::Accessor::Constants::UPDATE,$container);
    
    # foreach my $key ( sort(keys( %{$container} )) ) {
        # my $field = $self->get_element_by_name($key);
        # next
         # if(!$field);
        # push(@fields,join(" ",
                          # $self->_element_sql($field),
                          # '=',
                          # $self->_element_sql(Database::Accessor::Param->new({value=> $container->{$key}}))));
    # }
   
    my $set_clause = join(" ",Database::Accessor::Driver::DBI::SQL::SET,
                        join(", ",@field_sql)
                        );
                        
    $self->da_warn("_update"," Set clause='$set_clause'")
      if $self->da_warning()>=5;
    
    return join(" ",$update_clause,$set_clause);

}
sub _insert {
    
    my $self             = shift;
    my ($container)      = @_;
    #my @fields           = ();
    #my @ field_sql        = ();
      
    my $insert_clause    = join(" ",Database::Accessor::Driver::DBI::SQL::INSERT,Database::Accessor::Driver::DBI::SQL::INTO,$self->_view_sql());
    
    $self->da_warn("_insert","Insert clause='$insert_clause'")
      if $self->da_warning()>=5;
    
    my (@field_sql) = $self->_insert_update_container(Database::Accessor::Constants::CREATE,$container);
          
    # if (ref($container) eq "ARRAY"){
      # $self->is_exe_array(1);
      # my $fields = $container->[0];
      # foreach my $key (sort(keys( %{$fields} )) ) {
        # my $field = $self->get_element_by_name( $key);
        # next
         # if(!$field);
        # push(@fields,$field);
        # push(@field_sql, $self->_element_sql($field));
        # $self->add_param([]);
      # }
      # foreach my $tuple (@{$container}){
         # my $index = 0;
         # foreach my $field (@fields){
           # my $param =  Database::Accessor::Param->new({value=> $tuple->{$field->name()}});
           # push(@{$self->params->[$index]},$param);
           # $index++;
         # }
         
       # }
       
      
    # }
    # else {
      # foreach my $key ( sort(keys( %{$container} )) ) {
        # my $field = $self->get_element_by_name( $key);
        # next
         # if(!$field);
        # push(@field_sql, $self->_element_sql($field));
        # my $param =  Database::Accessor::Param->new({value=> $container->{$key}});
        # $self->add_param($param);
      # #  push(@values,$param->value());
       
      # }
    # }
    my $fields_clause = join(" ",Database::Accessor::Driver::DBI::SQL::OPEN_PARENS,
                        join(", ",@field_sql),
                        Database::Accessor::Driver::DBI::SQL::CLOSE_PARENS);
   
    $self->da_warn("_insert"," Fields clause='$fields_clause'")
      if $self->da_warning()>=5;
    
                        
    my $values_clause =  Database::Accessor::Driver::DBI::SQL::VALUES
                        .join(" ",
                        Database::Accessor::Driver::DBI::SQL::OPEN_PARENS,
                        join(", ",
                              map(Database::Accessor::Driver::DBI::SQL::PARAM,@field_sql)
                             ),
                        Database::Accessor::Driver::DBI::SQL::CLOSE_PARENS);
                          
   
    $self->da_warn("_insert"," Values clause='$values_clause'")
      if $self->da_warning()>=5;
 
    return join(" ",$insert_clause,$fields_clause,$values_clause);
      
    # $self->da_warn("_insert"," Values clause '$value_clause'")
      # if $self->da_warning()>=5;

    
    #$container->isa();

    # if ( ref($container) eq "DBIx::DA::SQL" ) {    #insert with select
        # foreach my $field  ( $self->fields ) {
           
           # next
             # if (($field->table() and $field->table() ne $self->table()->name())
                  # or ($field->no_insert() or $field->expression()));
                  
            # $field_clause  .= $delimiter . $field->name();
            # $delimiter = ", ";
        # }
        # $sql .= " (" . $field_clause . " ) " . $container->_select_clause();

        # foreach my $sub_param ( @{$container->_params()} ) {
            # $self->add_params($sub_param);
        # }
    # }
    # else {

        # @fields_to_insert = ();

        # foreach my $key ( keys( %{$container} ) ) {

            # my $field = $self->find_field(sub {$_->name eq $key});
            # next
              # unless $field;
            # next 
              # if $field->no_insert();
            # use Data::Dumper;
            # $field_clause .= $delimiter . $field->name();
            # if ( $field->is_identity() and $field->sequence() ) {
                    # $value_clause .= $field->sequence() . ".nextval";
                    # $self->returning(
                        # DBIx::DA::Returning->new(
                            # {
                                # params => [
                                    # DBIx::DA::Param->new(
                                        # {
                                            # name  => $field->name(),
                                            # value => \$field
                                        # }
                                    # )
                                # ]
                            # }
                        # )
                    # );
             # }
             # elsif ($container->{$key} eq 'sysdate' ) { #others as well
                    # $value_clause .= "sysdate";
             # }
             # else {
              
               
               # $self->_add_param($param);
                  
               # $value_clause.= $delimiter
                               # .$param->sql($self);
                # $delimiter = ", ";
             # }    
        # }

        # $sql .= " (" . $field_clause . " ) VALUES (" . $value_clause . ")";

        # # if ( $self->returning() ) {
            # # $sql .= $self->_returning_clause();
        # # }
    # }
   
}

1;