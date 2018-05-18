package Database::Accessor::Driver::DBI::SQL;
use warnings;
use strict;

BEGIN {
    $DBIx::DA::Constants::SQL::VERSION = "0.01";
}
use constant SELECT            =>'SELECT';
use constant INSERT            =>'INSERT';
use constant UPDATE            =>'UPDATE';
use constant DELETE            =>'DELETE';
use constant FROM              =>'FROM';
use constant VALUES            =>'VALUES';

use constant AS                =>'AS';
use constant ON                =>'ON';
use constant IN                =>'IN';
use constant NOT_IN            =>'NOT IN';
use constant BETWEEN           =>'BETWEEN';
use constant LIKE              =>'LIKE';
use constant IS_NULL           =>'IS NULL';
use constant NULL              =>'NULL';
use constant IS_NOT_NULL       =>'IS NOT NULL';
use constant AND               =>'AND';
use constant OR                =>'OR';
use constant JOIN              =>'JOIN';
use constant INTO              =>'INTO';
use constant HIERACHICALJOIN   =>'HIERACHICALJOIN';
use constant GROUP_BY          =>'GROUP_BY';
use constant ORDER_BY          =>'ORDER_BY';
use constant GROUPBY           =>'GROUP BY';
use constant ORDERBY           =>'ORDER BY';
use constant WHERE             =>'WHERE';
use constant HAVING            =>'HAVING';
use constant OPEN_PARENS       =>'(';
use constant OPEN_PARENTHESES  =>Database::Accessor::Driver::DBI::SQL::OPEN_PARENS;
use constant CLOSE_PARENS      =>')';
use constant CLOSE_PARENTHESES =>Database::Accessor::Driver::DBI::SQL::CLOSE_PARENS;
use constant PARAM             =>'?';
use constant SET               =>'SET'; 
use constant OPERATION_TYPES   => {
   Database::Accessor::Driver::DBI::SQL::SELECT => 1,
   Database::Accessor::Driver::DBI::SQL::INSERT => 1,
   Database::Accessor::Driver::DBI::SQL::UPDATE => 1,
   Database::Accessor::Driver::DBI::SQL::DELETE => 1
};
use constant CLAUSE_TYPES    =>Database::Accessor::Driver::DBI::SQL::OPERATION_TYPES;
use constant CONDITION_TYPES => {
   Database::Accessor::Driver::DBI::SQL::JOIN   => 1,
   Database::Accessor::Driver::DBI::SQL::WHERE  => 1,
   Database::Accessor::Driver::DBI::SQL::HAVING => 1
};
use constant EXPRESSION => {
   '=' => 1,
   '!='=> 1,
   '<>'=> 1,
   '>' => 1,
   '>='=> 1,
   '<' => 1,
   '<='=> 1,
   '-' => 1,
   '*' => 1,
   '/' => 1,
   '+'=> 1
};
use constant OPERATORS => {
   Database::Accessor::Driver::DBI::SQL::IN          => 1,
   Database::Accessor::Driver::DBI::SQL::NOT_IN      => 1,
   Database::Accessor::Driver::DBI::SQL::BETWEEN     => 1,
   Database::Accessor::Driver::DBI::SQL::LIKE        => 1,
   Database::Accessor::Driver::DBI::SQL::IS_NULL     => 1,
   Database::Accessor::Driver::DBI::SQL::IS_NOT_NULL => 1,
   Database::Accessor::Driver::DBI::SQL::AND         => 1,
   Database::Accessor::Driver::DBI::SQL::OR          => 1,
    '=' => 1,
   '!='=> 1,
   '<>'=> 1,
   '>' => 1,
   '>='=> 1,
   '<' => 1,
   '<='=> 1,
};

use constant WHERE_CONDITIONS => {
    #Database::Accessor::Driver::DBI::SQL::IN          => 1,
    #Database::Accessor::Driver::DBI::SQL::NOT_IN      => 1,
    #Database::Accessor::Driver::DBI::SQL::BETWEEN     => 1,
    #Database::Accessor::Driver::DBI::SQL::LIKE        => 1,
    #Database::Accessor::Driver::DBI::SQL::IS_NULL     => 1,
    #Database::Accessor::Driver::DBI::SQL::IS_NOT_NULL => 1,
   Database::Accessor::Driver::DBI::SQL::AND         => 1,
   Database::Accessor::Driver::DBI::SQL::OR          => 1,
     '=' => 1,
   # '!='=> 1,
   # '<>'=> 1,
   # '>' => 1,
   # '>='=> 1,
   # '<' => 1,
   # '<='=> 1,
};
use constant LOGIC => {
   Database::Accessor::Driver::DBI::SQL::AND => 1,
   Database::Accessor::Driver::DBI::SQL::OR  => 1
};

use constant PARNES => {
   Database::Accessor::Driver::DBI::SQL::OPEN_PARENS  => 1,
   Database::Accessor::Driver::DBI::SQL::CLOSE_PARENS => 1
};

use constant LEFT_JOIN   =>'LEFT JOIN';
use constant OUTER       =>'OUTER';
use constant LEFT        =>'LEFT';
use constant LEFT_OUTER  =>'LEFT OUTER';
use constant RIGHT_OUTER =>'RIGHT OUTER';
use constant RIGHT       =>'RIGHT';

use constant FULL_OUTER       =>'FULL OUTER';
use constant INNER_JOIN       =>'INNER JOIN';
use constant LEFT_INNER       =>'LEFT INNER';
use constant RIGHT_INNER      =>'RIGHT INNER';
use constant FULL_INNER       =>'FULL INNER';
use constant CONNECT_BY       =>'CONNECT BY';
use constant CONNECT_BY_PRIOR =>'CONNECT BY PRIOR';
use constant START_WITH       =>'START WITH';
use constant JOINS            => {
   Database::Accessor::Driver::DBI::SQL::LEFT_JOIN        => 1,
   Database::Accessor::Driver::DBI::SQL::RIGHT            => 1,
   Database::Accessor::Driver::DBI::SQL::OUTER            => 1,
   Database::Accessor::Driver::DBI::SQL::LEFT_OUTER       => 1,
   Database::Accessor::Driver::DBI::SQL::RIGHT_OUTER      => 1,
   Database::Accessor::Driver::DBI::SQL::FULL_OUTER       => 1,
   Database::Accessor::Driver::DBI::SQL::INNER_JOIN       => 1,
   Database::Accessor::Driver::DBI::SQL::LEFT_INNER       => 1,
   Database::Accessor::Driver::DBI::SQL::RIGHT_INNER      => 1,
   Database::Accessor::Driver::DBI::SQL::CONNECT_BY       => 1,
   Database::Accessor::Driver::DBI::SQL::CONNECT_BY_PRIOR => 1,
   Database::Accessor::Driver::DBI::SQL::START_WITH       => 1,
};
use constant AVG    =>'AVG';
use constant COUNT  =>'COUNT';
use constant FIRST  =>'FIRST';
use constant LAST   =>'LAST';
use constant MAX    =>'MAX';
use constant MIN    =>'MIN';
use constant SUM    =>'SUM';
use constant CONCAT =>'CONCAT';
use constant AS     =>'AS';


use constant REQUIRED =>'R';
use constant OPTIONAL =>'O';
use constant NOW      =>'sysdate';

use constant AGGREGATES => {
   Database::Accessor::Driver::DBI::SQL::AVG   => 1,
   Database::Accessor::Driver::DBI::SQL::COUNT => 1,
   Database::Accessor::Driver::DBI::SQL::FIRST => 1,
   Database::Accessor::Driver::DBI::SQL::LAST  => 1,
   Database::Accessor::Driver::DBI::SQL::MAX   => 1,
   Database::Accessor::Driver::DBI::SQL::MIN   => 1,
   Database::Accessor::Driver::DBI::SQL::SUM   => 1,
};

use constant FUNCTIONS => {
   Database::Accessor::Driver::DBI::SQL::CONCAT => {
       Database::Accessor::Driver::DBI::SQL::REQUIRED => 2,
       Database::Accessor::Driver::DBI::SQL::OPTIONAL => 0
    },
};

use constant ASC      =>'ASC';
use constant DESC     =>'DESC';
use constant ORDER => {
   Database::Accessor::Driver::DBI::SQL::ASC  => 1,
   Database::Accessor::Driver::DBI::SQL::DESC => 1,
};

use constant CLAUSES => {
   Database::Accessor::Driver::DBI::SQL::JOIN => 1,
   Database::Accessor::Driver::DBI::SQL::HIERACHICALJOIN => 1,
   Database::Accessor::Driver::DBI::SQL::GROUP_BY        => 1,
   Database::Accessor::Driver::DBI::SQL::HAVING          => 1,
   Database::Accessor::Driver::DBI::SQL::ORDER_BY        => 1,
   Database::Accessor::Driver::DBI::SQL::WHERE           => 1,#not really an object
};


# use constant CLAUSES => {
    # "DBIx::DA::Join"            => 1,
    # "DBIx::DA::HierachicalJoin" => 1,
    # "DBIx::DA::Group_by"        => 1,
    # "DBIx::DA::Having"          => 1,
    # "DBIx::DA::OrderBy"         => 1,
    # "DBIx::DA::Where"           => 1,#not really an object
# };




1;