-- Table: restaurants

-- DROP TABLE restaurants;

CREATE TABLE restaurants
(
 name text,
 rating text,
 inspection_date text,
 address text,
 latitude numeric,
 longitude numeric,
 id numeric NOT NULL,
 CONSTRAINT restaurant_pk PRIMARY KEY (id )
 )
WITH (
    OIDS=FALSE
    );
ALTER TABLE restaurants
OWNER TO matt;

CREATE TABLE users
(
 name text,
 created date,
 id numeric NOT NULL,
 CONSTRAINT user_pk PRIMARY KEY (id)
);

