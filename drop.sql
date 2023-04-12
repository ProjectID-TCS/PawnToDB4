CREATE  TABLE pawntodb4.zawodnicy ( 
	id                   integer  NOT NULL  ,
	imie                 varchar[]    ,
	nazwisko             varchar[]    ,
	grupa                integer    ,
	elo                  integer    ,
	maxelo               integer    ,
	CONSTRAINT pk_zawodnicy PRIMARY KEY ( id ),
	CONSTRAINT unq_zawodnicy_grupa UNIQUE ( grupa ) 
 );

ALTER TABLE pawntodb4.zawodnicy ADD CONSTRAINT fk_zawodnicy_partie FOREIGN KEY ( id ) REFERENCES pawntodb4.partie( białe );

ALTER TABLE pawntodb4.zawodnicy ADD CONSTRAINT fk_zawodnicy_partie_0 FOREIGN KEY ( id ) REFERENCES pawntodb4.partie( czarne );
CREATE  TABLE pawntodb4.partie ( 
	id                   integer  NOT NULL  ,
	białe                integer  NOT NULL  ,
	czarne               integer  NOT NULL  ,
	id_tur               integer    ,
	wynik                boolean  NOT NULL  ,
	"data"               date    ,
	CONSTRAINT unq_partie_białe UNIQUE ( białe ) ,
	CONSTRAINT unq_partie_czarne UNIQUE ( czarne ) ,
	CONSTRAINT pk_partie PRIMARY KEY ( id ),
	CONSTRAINT unq_partie_id_tur UNIQUE ( id_tur ) 
 );
CREATE  TABLE pawntodb4.turnieje ( 
	id_tur               integer  NOT NULL  ,
	nazwa                varchar[]  NOT NULL  ,
	typ                  integer  NOT NULL  ,
	miejsce              integer    ,
	początek             date  NOT NULL  ,
	koniec               date  NOT NULL  ,
	CONSTRAINT pk_turnieje PRIMARY KEY ( id_tur ),
	CONSTRAINT unq_turnieje_typ UNIQUE ( typ ) ,
	CONSTRAINT unq_turnieje_miejsce UNIQUE ( miejsce ) 
 );
CREATE  TABLE pawntodb4.miejsca ( 
	id                   integer  NOT NULL  ,
	miasto               integer    ,
	CONSTRAINT pk_miejsca PRIMARY KEY ( id )
 );

ALTER TABLE pawntodb4.miejsca ADD CONSTRAINT fk_miejsca_turnieje FOREIGN KEY ( id ) REFERENCES pawntodb4.turnieje( miejsce );
CREATE  TABLE pawntodb4.zaw_tur ( 
	id_zaw               integer  NOT NULL  ,
	id_tur               integer  NOT NULL  
 );

ALTER TABLE pawntodb4.zaw_tur ADD CONSTRAINT fk_zaw_tur_zawodnicy FOREIGN KEY ( id_zaw ) REFERENCES pawntodb4.zawodnicy( id );

ALTER TABLE pawntodb4.zaw_tur ADD CONSTRAINT fk_zaw_tur_turnieje FOREIGN KEY ( id_tur ) REFERENCES pawntodb4.turnieje( id_tur );
CREATE  TABLE pawntodb4.grupy ( 
	id                   integer  NOT NULL  ,
	grupa                varchar[]    ,
	CONSTRAINT pk_grupy PRIMARY KEY ( id )
 );

ALTER TABLE pawntodb4.grupy ADD CONSTRAINT fk_grupy_zawodnicy FOREIGN KEY ( id ) REFERENCES pawntodb4.zawodnicy( grupa );
CREATE  TABLE pawntodb4.typ ( 
	id                   integer  NOT NULL  ,
	nazwa                varchar[]    ,
	liczba_zaw           integer    ,
	CONSTRAINT pk_typ PRIMARY KEY ( id )
 );

ALTER TABLE pawntodb4.typ ADD CONSTRAINT fk_typ_turnieje FOREIGN KEY ( id ) REFERENCES pawntodb4.turnieje( typ );
CREATE  TABLE pawntodb4.par_tur ( 
	id_par               integer  NOT NULL  ,
	id_tur               integer  NOT NULL  ,
	szczebel             integer  NOT NULL  ,
	CONSTRAINT unq_par_tur_id_par UNIQUE ( id_par ) 
 );

ALTER TABLE pawntodb4.par_tur ADD CONSTRAINT fk_par_tur_turnieje FOREIGN KEY ( id_tur ) REFERENCES pawntodb4.turnieje( id_tur );

ALTER TABLE pawntodb4.par_tur ADD CONSTRAINT fk_par_tur_partie FOREIGN KEY ( id_par ) REFERENCES pawntodb4.partie( id );
