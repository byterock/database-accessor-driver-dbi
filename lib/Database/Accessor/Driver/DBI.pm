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
        $sql .= $self->_join_clause();
    }
    elsif ( $action eq Database::Accessor::Constants::UPDATE ) {
        $sql = $self->_update($container);
        $sql .= $self->_join_clause();
        $sql .= $self->_where_clause();
        
    }
    elsif ( $action eq Database::Accessor::Constants::DELETE ) {
        $sql = $self->_delete();
        $sql .= $self->_where_clause();
        
    }
    else {
        $sql = $self->_select();
        $sql .= $self->_join_clause();
        $sql .= $self->_where_clause();
        $sql .= $self->_group_by_clause();
        
    }
    
    $sql .= $self->_order_by_clause();
    
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
    return " "
      . join( " ",
        Database::Accessor::Driver::DBI::SQL::ORDER_BY,
        $self->_elements_sql( $self->sorts() ) );
}

sub _group_by_clause {
    my $self = shift;
    return ""
      unless ( $self->gather );
    my $having = $self->gather;
    return " ".join(" "
                ,Database::Accessor::Driver::DBI::SQL::GROUP_BY
                ,$self->_elements_sql($having->elements())
                ,$having->condition_count >=1 
                  ? join(" "
                        ,Database::Accessor::Driver::DBI::SQL::HAVING
                        ,$self->_predicate_clause( Database::Accessor::Driver::DBI::SQL::GROUP_BY,
                                                  $having->conditions ) )
                  : "");
}

sub _where_clause {
    my $self = shift;
    return ""
      unless ( $self->condition_count );
    return " ".join(" ",
                Database::Accessor::Driver::DBI::SQL::WHERE,
                $self->_predicate_clause( Database::Accessor::Driver::DBI::SQL::WHERE,
                $self->conditions ));
}


sub _join_clause {
    my $self = shift;
    return ""
      unless ( $self->link_count );
  
  
    my @join_clauses = ();


    foreach my $join (@{$self->links()}){
       my $clause = join(" "
                         ,$join->type,
                         ,Database::Accessor::Driver::DBI::SQL::JOIN
                         ,$self->_table_sql($join->to)
                         ,Database::Accessor::Driver::DBI::SQL::ON
                         , $self->_predicate_clause( 
                             Database::Accessor::Driver::DBI::SQL::JOIN,
                             $join->conditions() )
                          );
                         
       push(@join_clauses,$clause );
    }


    return " "
           .join(" "
                ,@join_clauses);               
}

sub _predicate_clause {
    my $self = shift;
    my ( $clause_type, $conditions ) = @_;
    my $predicate_clause = "";
    
    # warn("constion-".Dumper($conditions));
    foreach my $condition ( @{$conditions} ) {
       if (ref($condition) eq 'Database::Accessor::Condition'){
        # foreach my $predicate (  $condition->predicates } ) {
          $predicate_clause .= $self->_predicate_sql($condition->predicates);
        # }
      }
      else {
        $predicate_clause .= $self->_predicate_sql($condition);
        
       }
    }
    $self->da_warn( "_predicate_clause",
        $clause_type . " clause='$predicate_clause'" )
      if $self->da_warning() >= 5;
    return $predicate_clause;
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
      
      

       $clause .= join(" ",$self->_field_sql($predicate->left),
                $predicate->operator,
                $self->_field_sql($predicate->right));

     }

   $clause .= " "
           .Database::Accessor::Driver::DBI::SQL::CLOSE_PARENS
      if ( $predicate->close_parentheses() );
   $self->da_warn( "_predicate_sql",
                   " clause='$clause'" )
      if $self->da_warning() >= 6;
    return $clause;
}

sub _field_sql {
  my $self = shift;
  my ($element,$use_alias) = @_;
  if (ref($element) eq "Database::Accessor::Expression"){
      my $left_sql = $self->_field_sql($element->left());
      my @right_sql;

      if (ref($element->right()) ne "Array"){
         my $param = $element->right();
         $element->right([$param])
         if ($param);
      }
      foreach my $param (@{$element->right()}){
        push(@right_sql,$self->_field_sql($param));
      }        
      my $right_sql = join(',',@right_sql);
      return  Database::Accessor::Driver::DBI::SQL::OPEN_PARENS
             .join(" "
             ,$left_sql
             ,$element->expression
             ,$right_sql)
             .Database::Accessor::Driver::DBI::SQL::CLOSE_PARENS;
  
  }
  elsif (ref($element) eq "Database::Accessor::Function"){
      my $left_sql = $self->_field_sql($element->left());
      my @right_sql;
      
      my $comma = "";
      if ($element->right()){
        $comma = ",";
        if (ref($element->right()) ne "Array"){
           my $param = $element->right();
           $element->right([$param]);
        }
        foreach my $param (@{$element->right()}){
          push(@right_sql,$self->_field_sql($param));
        }        
      }
      my $right_sql = join(',',@right_sql);
      return $element->function
             .Database::Accessor::Driver::DBI::SQL::OPEN_PARENS
             .$left_sql
             .$comma
             .$right_sql
             .Database::Accessor::Driver::DBI::SQL::CLOSE_PARENS;
                          
  }
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
      return $sql;
    }
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


sub _table_sql {
  my $self = shift;
  my ($view) = @_;
  
  my $sql = $view->name;
  
  $sql = join(" ",
               $view->name,
               $view->alias)
    if $view->alias();
  return $sql;
              
}

sub _delete {
    
    my $self             = shift;
    my ($container)      = @_;
    my @fields           = ();

    my $delete_clause    = join(" ",Database::Accessor::Driver::DBI::SQL::DELETE
                                   ,Database::Accessor::Driver::DBI::SQL::FROM
                                   ,$self->_table_sql($self->view));
    
    $self->da_warn("_delete","Delete clause='$delete_clause'")
      if $self->da_warning()>=5;
    return $delete_clause;

}

sub _elements_sql {
  
  my $self = shift;
  my ($elements) = @_;
  my @fields = ();   
  foreach my $field ( @{$elements} ) {
     push(@fields,$self->_field_sql($field,1));
  }
  my $sql = join(", ",@fields);
  return $sql;
}


sub _select {
    
    my $self             = shift;
    my ($container)      = @_;
    my $select_clause    = join(" "
                               ,Database::Accessor::Driver::DBI::SQL::SELECT
                               ,$self->_elements_sql($self->elements()));
    $self->da_warn("_select","Select clause='$select_clause'")
      if $self->da_warning()>=5;

    my $from_clause = join(" ",
                       Database::Accessor::Driver::DBI::SQL::FROM,
                       $self->_table_sql($self->view)
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
                          $self->_field_sql($field),
                          '=',
                          Database::Accessor::Driver::DBI::SQL::PARAM));
        }
        else {
          push(@field_sql, $self->_field_sql($field));
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
                          $self->_field_sql($field),
                          '=',
                          $self->_field_sql(Database::Accessor::Param->new({value=> $container->{$key}}))));
        }
        else {
           push(@field_sql, $self->_field_sql($field));
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
    
      
    my $update_clause    = join(" ",Database::Accessor::Driver::DBI::SQL::UPDATE, $self->_table_sql($self->view));
    
    $self->da_warn("_update","Update clause='$update_clause'")
      if $self->da_warning()>=5;

    my (@field_sql) = $self->_insert_update_container(Database::Accessor::Constants::UPDATE,$container);
    

    # foreach my $key ( sort(keys( %{$container} )) ) {
        # my $field = $self->get_element_by_name($key);
        # next
         # if(!$field);
        # push(@fields,join(" ",
                          # $self->_field_sql($field),
                          # '=',
                          # $self->_field_sql(Database::Accessor::Param->new({value=> $container->{$key}}))));
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
      
    my $insert_clause    = join(" ",Database::Accessor::Driver::DBI::SQL::INSERT,Database::Accessor::Driver::DBI::SQL::INTO,$self->_table_sql($self->view));
    
    $self->da_warn("_insert","Insert clause='$insert_clause'")
      if $self->da_warning()>=5;
    
    my (@field_sql) = $self->_insert_update_container(Database::Accessor::Constants::CREATE,$container);
        
  
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
      

   
}

1;
