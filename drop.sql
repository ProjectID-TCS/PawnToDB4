CREATE  TABLE pairings ( 
	id                   integer  NOT NULL  ,
	white                integer  NOT NULL  ,
	black                integer  NOT NULL  ,
	tournament_id        integer    ,
	"result"             boolean  NOT NULL  ,
	"date"               date    ,
	id_record            integer    ,
	CONSTRAINT unq_games_white UNIQUE ( white ) ,
	CONSTRAINT unq_games_black UNIQUE ( black ) ,
	CONSTRAINT pk_games PRIMARY KEY ( id ),
	CONSTRAINT unq_games_tournament_id UNIQUE ( tournament_id ) ,
	CONSTRAINT unq_games_id_record UNIQUE ( id_record ) 
 );

CREATE  TABLE players ( 
	id                   integer  NOT NULL  ,
	first_name           varchar    ,
	last_name            varchar    ,
	group_id             integer    ,
	elo                  integer    ,
	max_elo              integer    ,
	CONSTRAINT pk_players PRIMARY KEY ( id ),
	CONSTRAINT unq_players_group UNIQUE ( group_id ) 
 );

CREATE  TABLE tournaments ( 
	id                   integer  NOT NULL  ,
	name                 varchar  NOT NULL  ,
	"type"               integer  NOT NULL  ,
	place                integer    ,
	start_date           date  NOT NULL  ,
	end_date             date  NOT NULL  ,
	CONSTRAINT pk_tournaments PRIMARY KEY ( id ),
	CONSTRAINT unq_tournaments_type UNIQUE ( "type" ) ,
	CONSTRAINT unq_tournaments_place UNIQUE ( place ) 
 );

CREATE  TABLE "type" ( 
	id                   integer  NOT NULL  ,
	name                 varchar    ,
	number_of_players    integer    ,
	CONSTRAINT pk_type PRIMARY KEY ( id )
 );

CREATE  TABLE game_record ( 
	id                   integer  NOT NULL  ,
	id_record            integer    ,
	id_opening           integer  NOT NULL  ,
	ending               varchar    ,
	CONSTRAINT pk_game_record PRIMARY KEY ( id ),
	CONSTRAINT unq_game_record_id_opening UNIQUE ( id_opening ) ,
	CONSTRAINT unq_game_record_id_record UNIQUE ( id_record ) ,
	CONSTRAINT unq_game_record_id_ending UNIQUE ( ending ) 
 );

CREATE  TABLE groups ( 
	id                   integer  NOT NULL  ,
	group_name           varchar    ,
	CONSTRAINT pk_groups PRIMARY KEY ( id )
 );

CREATE  TABLE move_record ( 
	id                   integer  NOT NULL  ,
	record               varchar    ,
	CONSTRAINT pk_tbl PRIMARY KEY ( id )
 );

CREATE  TABLE openings ( 
	id                   integer  NOT NULL  ,
	first_move           varchar(2)    ,
	name                 varchar(100)    ,
	CONSTRAINT pk_openings PRIMARY KEY ( id )
 );

CREATE  TABLE pairing_tournament ( 
	pairing_id           integer  NOT NULL  ,
	tournament_id        integer  NOT NULL  ,
	"level"              integer  NOT NULL  ,
	CONSTRAINT unq_pairing_tournament_pairing_id UNIQUE ( pairing_id ) 
 );

CREATE  TABLE places ( 
	id                   integer  NOT NULL  ,
	city                 integer  NOT NULL  ,
	street               varchar(100)    ,
	street_number        integer    ,
	CONSTRAINT pk_places PRIMARY KEY ( id )
 );

CREATE  TABLE player_tournament ( 
	player_id            integer  NOT NULL  ,
	tournament_id        integer  NOT NULL  
 );

ALTER TABLE game_record ADD CONSTRAINT fk_game_record_pairings FOREIGN KEY ( id ) REFERENCES pairings( id_record );

ALTER TABLE groups ADD CONSTRAINT fk_groups_players FOREIGN KEY ( id ) REFERENCES players( group_id );

ALTER TABLE move_record ADD CONSTRAINT fk_recordss_game_record FOREIGN KEY ( id ) REFERENCES game_record( id_record );

ALTER TABLE openings ADD CONSTRAINT fk_openings_game_record FOREIGN KEY ( id ) REFERENCES game_record( id_opening );

ALTER TABLE pairing_tournament ADD CONSTRAINT fk_pairing_tournament_tournaments FOREIGN KEY ( tournament_id ) REFERENCES tournaments( id );

ALTER TABLE pairing_tournament ADD CONSTRAINT fk_pairing_tournament_games FOREIGN KEY ( pairing_id ) REFERENCES pairings( id );

ALTER TABLE places ADD CONSTRAINT fk_places_tournaments FOREIGN KEY ( id ) REFERENCES tournaments( place );

ALTER TABLE player_tournament ADD CONSTRAINT fk_player_tournament_players FOREIGN KEY ( player_id ) REFERENCES players( id );

ALTER TABLE player_tournament ADD CONSTRAINT fk_player_tournament_tournaments FOREIGN KEY ( tournament_id ) REFERENCES tournaments( id );

ALTER TABLE players ADD CONSTRAINT fk_players_games_white FOREIGN KEY ( id ) REFERENCES pairings( white );

ALTER TABLE players ADD CONSTRAINT fk_players_games_black FOREIGN KEY ( id ) REFERENCES pairings( black );

ALTER TABLE "type" ADD CONSTRAINT fk_type_tournaments FOREIGN KEY ( id ) REFERENCES tournaments( "type" );
