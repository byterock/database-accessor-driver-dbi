package Xtest::DB::Users::Plugin::Oracle;
use Moose::Role;

sub _create_sql {
    my $self = shift;
    return ['CREATE TABLE  PEOPLE
   ( ID NUMBER, 
     LAST_NAME VARCHAR2(200),
     FIRST_NAME VARCHAR2(200), 
     USER_ID CHAR(8), 
     CONSTRAINT PEOPLE_PK PRIMARY KEY ("ID") ENABLE
   )',
   'create sequence people_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 1 cache 20 noorder nocycle',
   'CREATE TABLE  ADDRESS 
   (ID NUMBER, 
    TIME_ZONE_ID NUMBER, 
    COUNTRY_ID NUMBER, 
    STREET VARCHAR2(250), 
    POSTAL_CODE VARCHAR2(15), 
    CITY VARCHAR2(100), 
    REGION_ID NUMBER, 
    CONSTRAINT ADDRESS_PK PRIMARY KEY ("ID") ENABLE
   )',
   'create sequence address_seq minvalue 1 maxvalue 999999999999999999999999999 increment by 1 start with 1 cache 20 noorder nocycle',
   'CREATE TABLE  people_address 
   (people_id NUMBER NOT NULL ENABLE, 
    address_id NUMBER NOT NULL ENABLE, 
    primary_IND NUMBER DEFAULT 0
    )'    
    ,
   'CREATE TABLE time_zone 
   (id NUMBER NOT NULL ENABLE, 
    description VARCHAR2(250)
    )',
   'CREATE TABLE country 
   (id NUMBER NOT NULL ENABLE, 
    description VARCHAR2(250)
    )',
    'CREATE TABLE region 
   (id NUMBER NOT NULL ENABLE, 
    description VARCHAR2(250)
    )'  ];
}

sub _drop_sql {
    my $self = shift;
    return [
        "BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE PEOPLE';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;",
    "BEGIN
  EXECUTE IMMEDIATE 'DROP SEQUENCE people_seq';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -2289 THEN
      RAISE;
    END IF;
END;",
  "BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE address';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;",
    "BEGIN
  EXECUTE IMMEDIATE 'DROP SEQUENCE address_seq';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -2289 THEN
      RAISE;
    END IF;
END;",
,
  "BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE people_address';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;",
  "BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE time_zone';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;",
  "BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE country';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;",
  "BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE region';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;"
      ];
}

sub _fill_sql {
    my $self = shift;
    return ["INSERT INTO people (id,last_name,first_name,user_id) 
                  VALUES (people_seq.nextval,'Master','Bill','masterb')",
            "INSERT INTO people (id,last_name,first_name,user_id) 
                  VALUES (people_seq.nextval,'Milk','Bob','milkb')",
            "INSERT INTO people (id,last_name,first_name,user_id) 
                  VALUES (people_seq.nextval,'Nobert','Jill','norbertj')",
            "INSERT INTO people (id,last_name,first_name,user_id) 
                  VALUES (people_seq.nextval,'Newman','Alfred E.','newmanae')",
            "INSERT INTO address (id,time_zone_id,country_id,street,postal_code,city,region_id)
                  VALUES (address_seq.nextval,1,2,'1414 New lane','M5H-1E6','Toronto',21)",
            "INSERT INTO address (id,time_zone_id,country_id,street,postal_code,city,region_id)
                  VALUES (address_seq.nextval,1,2,'22 Sicamore','M5H-2F6','Toronto',21)",
            "INSERT INTO address (id,time_zone_id,country_id,street,postal_code,city,region_id)
                  VALUES (address_seq.nextval,3,1,'PO Box 122','90210','Hollywood',10)",
            "INSERT INTO address (id,time_zone_id,country_id,street,postal_code,city,region_id)
                  VALUES (address_seq.nextval,3,1,'PO Box 233','90210','Hollywood',10)",
            "INSERT INTO address (id,time_zone_id,country_id,street,postal_code,city,region_id)
                  VALUES (address_seq.nextval,1,1,'485 MADison Avenue Suite 1313','10022','New York',2)",
            "INSERT INTO people_address (people_id,address_id,primary_IND)
                  VALUES (1,1,1)",
            "INSERT INTO people_address (people_id,address_id,primary_IND)
                  VALUES (2,2,1)",
            "INSERT INTO people_address (people_id,address_id,primary_IND)
                  VALUES (3,3,1)",
            "INSERT INTO people_address (people_id,address_id,primary_IND)
                  VALUES (4,4,1)",
            "INSERT INTO people_address (people_id,address_id,primary_IND)
                  VALUES (4,5,0)",
            "INSERT INTO time_zone (id,description)
                  VALUES (1,'EST')",
            "INSERT INTO time_zone (id,description)
                  VALUES (2,'CST')",
            "INSERT INTO time_zone (id,description)
                  VALUES (3,'PST')",
            "INSERT INTO country (id,description)
                  VALUES (1,'USA')",
            "INSERT INTO country (id,description)
                  VALUES (2,'Canada')",
            "INSERT INTO country (id,description)
                  VALUES (3,'Mexico')",
            "INSERT INTO region (id,description)
                  VALUES (21,'NA')",
            "INSERT INTO region (id,description)
                  VALUES (10,'West')",
            "INSERT INTO region (id,description)
                  VALUES (2,'North East')",
            ];
}
1;


