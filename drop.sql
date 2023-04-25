DROP TABLE IF EXISTS groups CASCADE;
DROP TABLE IF EXISTS players CASCADE;
DROP TABLE IF EXISTS types CASCADE;
DROP TABLE IF EXISTS places CASCADE;
DROP TABLE IF EXISTS tournaments CASCADE;
DROP TABLE IF EXISTS move_record CASCADE;
DROP TABLE IF EXISTS openings CASCADE;
DROP TABLE IF EXISTS game_record CASCADE;
DROP TABLE IF EXISTS pairings CASCADE;
DROP TABLE IF EXISTS pairing_tournament CASCADE;
DROP TABLE IF EXISTS player_tournament CASCADE;

CREATE TABLE groups(
    id integer PRIMARY KEY,
    group_name varchar UNIQUE NOT NULL
);
CREATE TABLE players(
    id integer PRIMARY KEY,
    first_name varchar(40) NOT NULL, 
    last_name varchar(40) NOT NULL,
    group_id integer REFERENCES groups,
    elo integer check(elo > 0 and elo < 5000),
    max_elo integer check(max_elo >= elo)
);

CREATE TABLE types(
    id integer PRIMARY KEY,
    name varchar(40) NOT NULL,
    number_of_players integer NOT NULL
);
CREATE TABLE places(
    id integer PRIMARY KEY,
    city varchar(50) NOT NULL,
    street varchar(100),
    street_number integer
);

CREATE TABLE tournaments(
    id integer PRIMARY KEY,
    "name" varchar NOT NULL,
    "type" integer NOT NULL REFERENCES types,
    place integer REFERENCES places,
    "start_date" date NOT NULL,
    "end_date" date NOT NULL,
    check(start_date < end_date)
);
CREATE TABLE move_record(
    id integer PRIMARY KEY,
    record varchar NOT NULL
);

CREATE TABLE openings(
    id integer PRIMARY KEY,
    first_move varchar(3),
    name varchar(100) UNIQUE NOT NULL
);


CREATE TABLE game_record(
    id integer PRIMARY KEY,
    id_record integer REFERENCES move_record,
    id_opening integer REFERENCES openings,
    ending integer NOT NULL CHECK(ending in(1, 0, -1)),
    UNIQUE(id_record)
);


CREATE TABLE pairings(
    id integer PRIMARY KEY,
    white integer NOT NULL REFERENCES players,
    black integer NOT NULL REFERENCES players,
    tournament_id integer REFERENCES tournaments,
    "result" integer NOT NULL CHECK(result in(1, 0, -1)),
    "date"   date,
    id_record integer REFERENCES game_record
);

CREATE TABLE pairing_tournament(
    pairing_id integer UNIQUE NOT NULL REFERENCES pairings,
    tournament_id integer NOT NULL REFERENCES tournaments,
    rank integer
);

CREATE TABLE player_tournament(
    player_id integer NOT NULL REFERENCES players,
    tournament_id integer NOT NULL REFERENCES tournaments
);
