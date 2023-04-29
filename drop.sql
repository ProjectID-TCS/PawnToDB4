DROP SCHEMA IF EXISTS PTDB4 CASCADE;

CREATE SCHEMA PTDB4;

CREATE TYPE PTDB4.match_result AS ENUM('white', 'black', 'draw');

CREATE TABLE PTDB4.groups(
    id integer PRIMARY KEY,
    group_name varchar UNIQUE NOT NULL
);
CREATE TABLE PTDB4.players(
    id integer PRIMARY KEY,
    first_name varchar(40) NOT NULL, 
    last_name varchar(40) NOT NULL,
    group_id integer REFERENCES ptdb4.groups,
    elo integer check(elo > 0 and elo < 5000),
    max_elo integer check(max_elo >= elo)
);

CREATE TABLE PTDB4.types(
    id integer PRIMARY KEY,
    name varchar(40) NOT NULL,
    number_of_players integer NOT NULL
);
CREATE TABLE PTDB4.places(
    id integer PRIMARY KEY,
    city varchar(50) NOT NULL,
    street varchar(100),
    street_number integer
);

CREATE TABLE PTDB4.tournaments(
    id integer PRIMARY KEY,
    "name" varchar NOT NULL,
    "type" integer NOT NULL REFERENCES ptdb4.types,
    place integer REFERENCES ptdb4.places,
    "start_date" date NOT NULL,
    "end_date" date NOT NULL,
    check(start_date < end_date)
);
CREATE TABLE PTDB4.move_record(
    id integer PRIMARY KEY,
    record varchar NOT NULL
);

CREATE TABLE PTDB4.openings(
    id integer PRIMARY KEY,
    first_move varchar(3),
    name varchar(100) UNIQUE NOT NULL
);


CREATE TABLE PTDB4.game_record(
    id integer PRIMARY KEY,
    id_record integer REFERENCES ptdb4.move_record,
    id_opening integer REFERENCES ptdb4.openings,
    game_result match_result NOT NULL,
    ending varchar,
    UNIQUE(id_record)
);


CREATE TABLE PTDB4.pairings(
    id integer PRIMARY KEY,
    white integer NOT NULL REFERENCES ptdb4.players,
    black integer NOT NULL REFERENCES ptdb4.players,
    tournament_id integer REFERENCES ptdb4.tournaments,
    "result" match_result NOT NULL,
    "date"   date,
    id_record integer REFERENCES ptdb4.game_record
);

CREATE TABLE PTDB4.pairing_tournament(
    pairing_id integer UNIQUE NOT NULL REFERENCES ptdb4.pairings,
    tournament_id integer NOT NULL REFERENCES ptdb4.tournaments,
    rank integer
);

CREATE TABLE PTDB4.player_tournament(
    player_id integer NOT NULL REFERENCES ptdb4.players,
    tournament_id integer NOT NULL REFERENCES ptdb4.tournaments
);
