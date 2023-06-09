DROP SCHEMA IF EXISTS PTDB4 CASCADE;

CREATE SCHEMA PTDB4;

CREATE TYPE PTDB4.match_result AS ENUM ('W', 'B', 'D');

CREATE TABLE PTDB4.groups
(
    id         serial PRIMARY KEY,
    group_name varchar UNIQUE NOT NULL
);

CREATE TABLE PTDB4.players
(
    id         serial PRIMARY KEY,
    first_name varchar(20) NOT NULL,
    last_name  varchar(20) NOT NULL,
    group_id   integer REFERENCES ptdb4.groups,
    max_elo integer not null
);


CREATE VIEW PTDB4.player_insert_view AS
SELECT p.first_name, p.last_name, g.group_name, p.max_elo
FROM PTDB4.players p
JOIN PTDB4.groups g ON p.group_id = g.id
WHERE 1 = 0;

CREATE OR REPLACE FUNCTION in_player()
    RETURNS TRIGGER AS
$$
DECLARE group_id_var integer;
BEGIN
   SELECT id INTO group_id_var FROM PTDB4.groups WHERE group_name = NEW.group_name;
   INSERT INTO PTDB4.players (first_name, last_name, group_id, max_elo)
   VALUES (NEW.first_name, NEW.last_name, group_id_var, NEW.max_elo);
   RETURN NEW;
END;
$$
language plpgsql;

CREATE TRIGGER new_player_view
INSTEAD OF INSERT ON PTDB4.player_insert_view
FOR EACH ROW EXECUTE FUNCTION in_player();

CREATE OR REPLACE FUNCTION player_up()
    RETURNS TRIGGER AS
$$BEGIN
    new.id = old.id;
    new.max_elo = old.max_elo;
    return new;
end;
$$
LANGUAGE plpgsql;

CREATE TRIGGER player_up
    BEFORE UPDATE ON PTDB4.players
    FOR EACH ROW EXECUTE PROCEDURE player_up();
CREATE TABLE PTDB4.elo
(
    player_id   integer references PTDB4.players (id),
    acquired_on date,
    elo         integer check (elo > 0 and elo < 3400)
--     unique (player_id, acquired_on)
);
CREATE OR REPLACE FUNCTION new_player()
    RETURNS TRIGGER AS
$$BEGIN
    insert into PTDB4.elo values (new.id,'2021-09-18',new.max_elo);
    return new;
end;
$$
language plpgsql;

CREATE TRIGGER new_player
    AFTER INSERT ON PTDB4.players
    FOR EACH ROW EXECUTE PROCEDURE new_player();

CREATE OR REPLACE FUNCTION max_elo_update()
    RETURNS TRIGGER AS
$$
BEGIN
    IF new.elo > (
        SELECT max_elo FROM PTDB4.players WHERE id = new.player_id
    ) THEN
        UPDATE PTDB4.players SET max_elo = new.elo WHERE id = new.player_id;
    END IF;
    RETURN new;
END

$$LANGUAGE plpgsql;

CREATE TRIGGER max_elo_update
    AFTER INSERT ON PTDB4.elo
    FOR EACH ROW EXECUTE PROCEDURE max_elo_update();

CREATE INDEX player_elo ON PTDB4.elo (player_id);

CREATE TABLE PTDB4.formats
(
    id          serial PRIMARY KEY,
    name        varchar(40) NOT NULL unique, -- some variant names are really long as they should include time of games and number of players to keep name unique or close to unique
    description varchar(200)

);

CREATE TABLE PTDB4.cities
(
    id            serial PRIMARY KEY,
    city          varchar(85) NOT NULL, --Taumatawhakatangi­hangakoauauotamatea­turipukakapikimaunga­horonukupokaiwhen­uakitanatahu (New Zealand)
    street        varchar(38),          --Jean Baptiste Point du Sable Lake Shore Drive (Chicago)
    street_number varchar(10),           --couldn't find longer, tried though
    unique(city,street,street_number)
);

CREATE TABLE PTDB4.places
(
    id      serial PRIMARY KEY,
    country varchar(56) NOT NULL, --The United Kingdom of Great Britain and Northern Ireland
    city_id integer REFERENCES ptdb4.cities
);


CREATE TABLE PTDB4.tournaments
(
    id           serial PRIMARY KEY,
    "name"       varchar(30) NOT NULL,
    format       integer     NOT NULL REFERENCES ptdb4.formats,
    place        integer REFERENCES ptdb4.places,
    "start_date" date        NOT NULL,
    "end_date"   date        NOT NULL,
    check (start_date < end_date)
);

CREATE OR REPLACE FUNCTION insert_tournament()
    RETURNS TRIGGER AS
$$
BEGIN
    if new.tournament_id is null then
    return new;
    end if;
    if (select id from PTDB4.tournaments where id = new.tournament_id) is null then
        return null;
    end if;
    return new;
END;
$$
language plpgsql;

CREATE TABLE PTDB4.openings
(
    id          serial		PRIMARY KEY,
    name	varchar(22)	NOT NULL
);

CREATE TABLE PTDB4.openings_moves
(
    move_number   integer       NOT NULL,
    move_W        varchar(7)    NOT NULL,
    move_B        varchar(7)    NOT NULL,
    opening_id    integer       NOT NULL,
    PRIMARY KEY (move_number, opening_id),
    FOREIGN KEY (opening_id) REFERENCES PTDB4.openings (id)
);


CREATE TABLE PTDB4.game_record
(
    id          serial PRIMARY KEY,
    game_result PTDB4.match_result NOT NULL,
    ending      varchar(15) not null,--possible ending conditions
    opening     int references PTDB4.openings(id)
    constraint check_reason
    check (
  (game_result IN ('W', 'B') AND ending IN ('resignation','mate','time')) OR
  (game_result = 'D' AND ending IN ('agreement', 'time'))) -- if one has no way to mate, time over is a draw
);

CREATE TABLE PTDB4.moves_record
(
    game_id     integer NOT NULL REFERENCES ptdb4.game_record,
    move_number integer NOT NULL,
    move_W      varchar(7), --if there are 3 knights on the board it is possible to need 7 characters to describe one move.
    move_B      varchar(7),  --it would be for example "Nd1xc3#". Black can be null if game ended on white move
    PRIMARY KEY(game_id, move_number)
);


CREATE INDEX each_game ON PTDB4.moves_record (game_id);

CREATE TABLE PTDB4.pairings
(
    id            serial PRIMARY KEY,
    white         integer      NOT NULL REFERENCES ptdb4.players,
    black         integer      NOT NULL REFERENCES ptdb4.players,
    tournament_id integer REFERENCES ptdb4.tournaments,
    "result"      PTDB4.match_result NOT NULL,
    match_date    date not null,
    id_record     integer REFERENCES ptdb4.game_record,
    unique(white,black,match_date)
);

CREATE VIEW PTDB4.match_insert_view AS
SELECT w.first_name as "w_first", w.last_name as "w_last",
b.first_name as "b_first", b.last_name as "b_last",
p.result, p.match_date, p.tournament_id 
FROM PTDB4.players w 
NATURAL JOIN PTDB4.players b 
NATURAL JOIN PTDB4.pairings p
WHERE 0 = 1;

CREATE OR REPLACE FUNCTION in_pairing()
    RETURNS TRIGGER AS
$$
DECLARE 
   white_id integer;
   black_id integer;
BEGIN
   SELECT id INTO white_id FROM PTDB4.players WHERE first_name = NEW.w_first and last_name = NEW.w_last;
   SELECT id INTO black_id FROM PTDB4.players WHERE first_name = NEW.b_first and last_name = NEW.b_last;

   INSERT INTO PTDB4.pairings (white, black, tournament_id, result, match_date)
   VALUES (white_id, black_id, NEW.tournament_id, NEW.result, NEW.match_date);
   RETURN NEW;
END;
$$
language plpgsql;

CREATE TRIGGER new_pairing_view
INSTEAD OF INSERT ON PTDB4.match_insert_view
FOR EACH ROW EXECUTE FUNCTION in_pairing();


CREATE OR REPLACE FUNCTION pairing_chronology()
    RETURNS TRIGGER AS
$$
DECLARE 
   white_max_date DATE;
   black_max_date DATE;
BEGIN
   SELECT max(match_date) INTO white_max_date FROM PTDB4.pairings WHERE white = NEW.white or black = NEW.white;
   SELECT max(match_date) INTO black_max_date FROM PTDB4.pairings WHERE white = NEW.black or black = NEW.black;

   IF NEW.match_date < white_max_date OR NEW.match_date < black_max_date THEN
        RAISE EXCEPTION 'Error while inserting pairing. Match date is not chronological';
   END IF;
   
   RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER pairing_date
BEFORE INSERT ON PTDB4.pairings
FOR EACH ROW EXECUTE FUNCTION pairing_chronology();

CREATE TRIGGER insert_tournament
    BEFORE INSERT OR UPDATE ON PTDB4.pairings
    FOR EACH ROW EXECUTE PROCEDURE insert_tournament();

CREATE OR REPLACE FUNCTION calculateElo(white int,black int,result int)
    RETURNS int[] AS
$$
DECLARE
    newWhite int;
    newBlack int;
    diff int= abs(white-black);
    res int[];
BEGIN
    if result = 1 then
        if white > black then
            newWhite = white+1+diff/8;
            newBlack = black-1-diff/8;
        elsif white < black then
            newWhite = white+3+diff/5;
            newBlack = black-3-diff/5;
        end if;
    elsif result = -1 then
        if white > black then
            newWhite = white-3-diff/5;
            newBlack = black+3+diff/5;
        elsif white < black then
            newWhite = white+1+diff/8;
            newBlack = black-1-diff/8;
        end if;
    else
        if white > black then
            newWhite = white-1-diff/10;
            newBlack = black+1+diff/10;
        elsif white < black then
            newWhite = white+1+diff/10;
            newBlack = black-1-diff/10;
        end if;
    end if;
    res[1] = newWhite;
    res[2] = newBlack;
    return res;
END;
$$
language plpgsql;

CREATE OR REPLACE FUNCTION elo_update()
    RETURNS TRIGGER AS
$$
DECLARE
    eloW int;
    eloB int;
    updatedElo int[];
BEGIN

    eloB = (select elo.elo from PTDB4.elo where player_id = new.black order by acquired_on limit 1);
    eloW = (select elo.elo from PTDB4.elo where player_id = new.white order by acquired_on limit 1);
    if new.result = 'W' then
        updatedElo = calculateElo(eloW,eloB,1);
    elsif new.result = 'B' then
        updatedElo = calculateElo(eloW,eloB,-1);
    else
        updatedElo = calculateElo(eloW,eloB,0);
    end if;
    insert into PTDB4.elo values(new.black,new.match_date,updatedElo[2]);
    insert into PTDB4.elo values(new.white,new.match_date,updatedElo[1]);
    return new;
END;
$$
language plpgsql;

CREATE TRIGGER elo_update
    AFTER INSERT OR UPDATE ON PTDB4.pairings
    FOR EACH ROW EXECUTE PROCEDURE elo_update();
    
    
CREATE OR REPLACE FUNCTION check_date()
RETURNS TRIGGER AS $$
BEGIN
    if old.match_date is not null then
        return OLD;
    end if;

    IF new.match_date IS NULL THEN
        new.match_date = current_date;
    END IF;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER check_date_befor_insert 
BEFORE INSERT OR UPDATE ON PTDB4.pairings
FOR EACH ROW EXECUTE PROCEDURE check_date();

    
CREATE OR REPLACE FUNCTION current_elo(id_elo INTEGER)
    RETURNS INT AS
$$
DECLARE
   result INTEGER;
BEGIN
   SELECT INTO result elo FROM PTDB4.elo WHERE player_id = id_elo ORDER BY acquired_on DESC FETCH FIRST 1 ROWS ONLY;
   RETURN result;
END;
$$
LANGUAGE plpgsql;

CREATE INDEX each_tournament ON PTDB4.pairings (tournament_id);


CREATE TABLE PTDB4.pairing_tournament
(
    pairing_id    integer UNIQUE NOT NULL REFERENCES ptdb4.pairings,
    tournament_id integer        NOT NULL REFERENCES ptdb4.tournaments,
    level         integer
);

CREATE TABLE PTDB4.player_tournament
(
    player_id     integer NOT NULL REFERENCES ptdb4.players,
    tournament_id integer NOT NULL REFERENCES ptdb4.tournaments
);


--FUNKCJA ADAMA

CREATE OR REPLACE FUNCTION insert_match(w_first varchar, W_last varchar, b_first varchar,
b_last varchar , result PTDB4.match_result,
match_date date, tournament_id integer)
RETURNS INTEGER AS $$
DECLARE
    res INTEGER;
    white_id integer;
    black_id integer;
BEGIN
SELECT id INTO white_id FROM PTDB4.players WHERE first_name = w_first and last_name = w_last;
   SELECT id INTO black_id FROM PTDB4.players WHERE first_name = b_first and last_name = b_last;

   INSERT INTO PTDB4.pairings (white, black, tournament_id, result, match_date)
   VALUES (white_id, black_id, tournament_id, result, match_date)
   RETURNING id INTO res;
   RETURN res;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION insert_record(pairing_id integer, g_opening varchar, g_ending varchar)
RETURNS INTEGER AS $$
DECLARE
    g_result PTDB4.match_result;
    g_id INTEGER;
BEGIN
   SELECT result INTO g_result FROM PTDB4.pairings WHERE id = pairing_id;
   SELECT max(id) INTO g_id FROM PTDB4.game_record;
   g_id = g_id + 1;
   
   INSERT INTO PTDB4.game_record (id, game_result, ending, opening)
   VALUES (g_id, g_result, g_ending, (select o.id from PTDB4.openings o where name = g_opening));

   UPDATE PTDB4.pairings
   SET id_record = g_id
   WHERE id = pairing_id;
   
   RETURN g_id;
END;
$$ LANGUAGE plpgsql;



COPY PTDB4.groups (id, group_name) FROM stdin;
1	Red
2	Orange
3	Yellow
4	Green
5	Blue
6	Indigo
7	Violet
8	Pink
9	Purple
10	Turquoise
11	Gold
12	Lime
13	Maroon
14	Navy
15	Coral
16	Teal
17	Brown
18	White
19	Black
20	Sky   
\.

COPY PTDB4.players (last_name, first_name, group_id, max_elo) FROM stdin;
Haldorsen	Benjamin	15	2448
Tomashevsky	Evgeny	6	2705
Kozak	Adam	3	2445
Kovalev	Vladislav	4	2703
Mazur	Stefan	16	2441
Mamedov	Rauf	16	2701
Filip	Lucian-Ioan	20	2438
Ragger	Markus	14	2696
Kourkoulos-Arditis	Stamatis	2	2435
Korobov	Anton	13	2686
Tomazini	Zan	16	2431
Eljanov	Pavel	14	2682
Banzea	Alexandru-Bogdan	15	2427
Nisipeanu	Liviu-Dieter	17	2670
Radovanovic	Nikola	15	2426
Berkes	Ferenc	15	2666
Arsovic	Zoran	7	2422
Safarli	Eltaj	8	2662
Hnydiuk	Aleksander	18	2417
Edouard	Romain	11	2658
Tica	Sven	18	2416
Parligras	Mircea-Emilian	11	2657
Erdogdu	Mert	2	2413
Fressinet	Laurent	3	2652
Nikitenko	Mihail	18	2408
Alekseenko	Kirill	6	2644
Duzhakov	Ilya	14	2405
Anton	Guijarro-David	17	2643
Gadimbayli	Abdulla	13	2404
Alekseev	Evgeny	2	2640
Zarubitski	Viachaslau	7	2404
Lysyj	Igor	1	2635
Drnovsek	Gal	1	2402
Hovhannisyan	Robert	12	2634
Osmak	Iulija	14	2399
Lagarde	Maxime	10	2631
Kamer	Kayra	11	2397
Gledura	Benjamin	8	2630
Di-Benedetto	Edoardo	19	2394
Kobalia	Mikhail	4	2627
Saraci	Nderim	4	2391
Paravyan	David	6	2627
Kaasen	Tor-Fredrik	6	2383
Jobava	Baadur	18	2622
Arsovic	Goran	17	2380
Van-Foreest	Jorden	2	2621
Ayats	Llobera-Gerard	18	2377
Kozul	Zdenko	12	2619
Zlatanovic	Boroljub	17	2376
Smirin	Ilia	17	2618
Drazic	Sinisa	4	2370
Martirosyan	Haik-M.	6	2616
Stoyanov	Tsvetan	18	2370
Vocaturo	Daniele	1	2616
Kalogeris	Ioannis	18	2368
Chigaev	Maksim	16	2613
Serarols	Mabras-Bernat	6	2363
EErdos	Viktor	9	2612
Mihajlov	Sebastian	8	2356
Lupulescu	Constantin	7	2611
Dimic	Pavle	19	2351
Predke	Alexandr	8	2611
Pogosyan	Stefan	19	2347
Goganov	Aleksey	9	2610
Oboladze	Luka	19	2340
Deac	Bogdan-Daniel	11	2609
Mitsis	Georgios	12	2338
Esipenko	Andrey	17	2603
Klabis	Rokas	16	2333
Moussard	Jules	12	2601
Radovanovic	Dusan	11	2331
Bartel	Mateusz	4	2600
Osmanodja	Filiz	11	2326
Antipov	Mikhail-Al.	14	2594
Tsvetkov	Andrey	3	2322
Donchenko	Alexander	4	2593
Rabatin	Jakub	6	2313
Petrov	Nikita	5	2591
Tate	Alan	6	2306
Can	Emre	14	2586
Petkov	Momchil	16	2296
Nikolov	Momchil	6	2584
Antova	Gabriela	2	2286
Santos	Latasa-Jaime	5	2582
Sokolovsky	Yahli	17	2278
Wagner	Dennis	10	2580
Ozenir	Ekin-Baris	6	2265
Maze	Sebastien	18	2578
Martic	Zlatko	12	2261
Aleksandrov	Aleksej	11	2574
Gueci	Tea	19	2252
Djukic	Nikola	12	2572
Doncevic	Dario	13	2249
Meshkovs	Nikita	14	2568
Jarvenpaa	Jari	3	2243
Petrosyan	Manuel	10	2564
Ingebretsen	Jens	10	2243
Alonso	Rosell-Alvar	14	2559
Heinemann	Josefine	8	2238
Martinovic	Sasa	13	2558
Sukovic	Andrej	17	2235
Halkias	Stelios	15	2552
Milikow	Elie	4	2226
Kadric	Denis	2	2547
Tadic	Stefan	15	2223
Kulaots	Kaido	6	2544
Polatel	Ali	12	2220
Zhigalko	Andrey	2	2541
Stoinev	Metodi	5	2215
Stupak	Kirill	15	2537
Van-Dael	Siem	2	2207
Gazik	Viktor	14	2535
Gunduz	Umut-Erdem	10	2205
Kelires	Andreas	7	2529
Milikow	Yoav	12	2200
Lobanov	Sergei	13	2526
Karaoglan	Doruk	5	2197
Basso	Pier-Luigi	3	2521
Martinkus	Rolandas	6	2185
Demidov	Mikhail	14	2520
Isik	Alparslan	14	2180
Potapov	Pavel	7	2517
Veleski	Robert	10	2177
Valsecchi	Alessio	7	2515
Chigaeva	Anastasia	4	2167
Zanan	Evgeny	17	2514
De-Seroux	Camille	3	2160
Dragnev	Valentin	11	2511
Marinskii	Yurii	16	2156
Mirzoev	Emil	7	2511
Uruci	Besim	12	2137
Keymer	Vincent	5	2509
Sekelja	Marko	6	2120
Baron	Tal	4	2506
Aydincelebi	Kagan	15	2115
Quparadze	Giga	17	2501
Ivanova	Karina	18	2114
Neverov	Valeriy	6	2496
Tomashevskaya	Lidia	17	2112
Matviishen	Viktor	18	2490
Asllani	Muhamet	18	2105
Sargsyan	Shant	5	2488
Caglar	Sila	4	2094
Plenca	Jadranko	12	2487
Konstantinov	Aleksandar	14	2079
Fakhrutdinov	Timur	5	2485
Angun	Batu	1	2076
Studer	Noel	6	2479
Pantovic	Dragan-M	13	2063
Livaic	Leon	19	2477
Kubicki	Piotr	6	2400
Hoffmann	Michal	12	2500
Szwaja	Adam	18	2480
\.

COPY PTDB4.pairings (white, black, result, match_date) from stdin;
24	29	W	2021-01-01
93	116	D	2021-01-02
89	36	W	2021-01-03
124	42	B	2021-01-04
26	113	W	2021-01-05
4	104	D	2021-01-06
57	24	D	2021-01-07
108	100	B	2021-01-08
1	12	D	2021-01-09
82	27	B	2021-01-10
81	5	W	2021-01-11
83	96	W	2021-01-12
39	134	D	2021-01-13
61	147	W	2021-01-14
83	89	W	2021-01-15
121	24	B	2021-01-16
103	44	B	2021-01-17
41	81	D	2021-01-18
114	16	D	2021-01-19
39	67	W	2021-01-20
32	91	W	2021-01-21
45	96	D	2021-01-22
30	84	W	2021-01-23
35	25	D	2021-01-24
81	99	B	2021-01-25
6	148	B	2021-01-26
105	76	B	2021-01-27
26	77	D	2021-01-28
63	70	W	2021-02-01
5	83	B	2021-02-02
51	126	D	2021-02-03
121	130	W	2021-02-04
148	137	W	2021-02-05
138	45	W	2021-02-06
149	111	D	2021-02-07
148	56	W	2021-02-08
2	62	B	2021-02-09
35	32	W	2021-02-10
20	67	D	2021-02-11
22	96	B	2021-02-12
88	19	W	2021-02-13
130	61	B	2021-02-14
46	96	W	2021-02-15
39	91	W	2021-02-16
122	51	W	2021-02-17
109	65	D	2021-02-18
88	111	W	2021-02-19
75	129	B	2021-02-20
24	94	B	2021-02-21
65	33	B	2021-02-22
57	80	W	2021-02-23
36	99	B	2021-02-24
74	78	W	2021-02-25
15	45	B	2021-02-26
14	140	D	2021-02-27
19	136	B	2021-02-28
119	100	B	2021-03-01
124	82	B	2021-03-02
147	122	B	2021-03-03
67	46	W	2021-03-04
60	126	B	2021-03-05
118	76	W	2021-03-06
79	115	B	2021-03-07
44	86	D	2021-03-08
102	19	W	2021-03-09
18	71	W	2021-03-10
109	90	W	2021-03-11
148	142	B	2021-03-12
107	104	B	2021-03-13
63	92	W	2021-03-14
112	95	D	2021-03-15
93	105	D	2021-03-16
14	17	W	2021-03-17
127	17	D	2021-03-18
36	13	B	2021-03-19
19	120	W	2021-03-20
137	11	W	2021-03-21
39	37	B	2021-03-22
40	111	B	2021-03-23
104	53	D	2021-03-24
40	4	D	2021-03-25
132	135	B	2021-03-26
127	94	B	2021-03-27
63	62	D	2021-03-28
27	49	W	2021-04-01
27	1	D	2021-04-02
137	49	D	2021-04-03
85	25	W	2021-04-04
90	62	D	2021-04-05
16	5	B	2021-04-06
13	26	B	2021-04-07
11	98	D	2021-04-08
19	142	D	2021-04-09
68	61	D	2021-04-10
143	95	B	2021-04-11
76	112	B	2021-04-12
134	76	D	2021-04-13
96	11	B	2021-04-14
77	27	D	2021-04-15
124	73	W	2021-04-16
150	114	D	2021-04-17
81	31	W	2021-04-18
7	34	W	2021-04-19
20	77	D	2021-04-20
81	73	W	2021-04-21
111	22	B	2021-04-22
87	44	D	2021-04-23
112	144	W	2021-04-24
126	21	D	2021-04-25
30	137	D	2021-04-26
94	79	W	2021-04-27
120	110	D	2021-04-28
83	73	W	2021-05-01
141	4	D	2021-05-02
33	37	W	2021-05-03
103	147	B	2021-05-04
57	32	D	2021-05-05
67	116	D	2021-05-06
48	50	B	2021-05-07
128	95	D	2021-05-08
114	100	B	2021-05-09
140	109	W	2021-05-10
9	7	B	2021-05-11
97	41	D	2021-05-12
95	148	D	2021-05-13
112	9	D	2021-05-14
101	13	W	2021-05-15
67	121	D	2021-05-16
118	3	D	2021-05-17
95	69	W	2021-05-18
141	144	D	2021-05-19
21	2	D	2021-05-20
36	41	W	2021-05-21
129	18	D	2021-05-22
77	84	W	2021-05-23
87	116	W	2021-05-24
137	86	B	2021-05-25
66	2	D	2021-05-26
68	1	B	2021-05-27
34	71	D	2021-05-28
76	53	B	2021-06-01
84	9	D	2021-06-02
89	24	D	2021-06-03
83	15	B	2021-06-04
106	31	B	2021-06-05
131	119	W	2021-06-06
22	2	D	2021-06-07
149	145	W	2021-06-08
53	52	B	2021-06-09
19	130	B	2021-06-10
143	42	W	2021-06-11
96	119	W	2021-06-12
149	141	W	2021-06-13
113	129	D	2021-06-14
34	93	D	2021-06-15
87	116	B	2021-06-16
65	132	D	2021-06-17
36	121	W	2021-06-18
131	72	W	2021-06-19
58	129	B	2021-06-20
54	120	B	2021-06-21
124	150	B	2021-06-22
103	13	B	2021-06-23
21	101	D	2021-06-24
33	16	D	2021-06-25
38	69	D	2021-06-26
82	100	W	2021-06-27
64	81	W	2021-06-28
52	28	D	2021-07-01
111	146	D	2021-07-02
47	86	D	2021-07-03
142	51	B	2021-07-04
70	24	W	2021-07-05
101	128	B	2021-07-06
76	13	D	2021-07-07
80	125	D	2021-07-08
124	101	D	2021-07-09
36	131	B	2021-07-10
45	75	D	2021-07-11
111	129	W	2021-07-12
92	43	W	2021-07-13
16	96	D	2021-07-14
120	116	D	2021-07-15
20	70	D	2021-07-16
28	57	D	2021-07-17
9	108	B	2021-07-18
33	42	D	2021-07-19
112	56	W	2021-07-20
76	25	D	2021-07-21
18	33	W	2021-07-22
142	74	W	2021-07-23
13	30	W	2021-07-24
30	97	B	2021-07-25
70	145	D	2021-07-26
46	3	B	2021-07-27
12	68	B	2021-07-28
93	24	B	2021-08-01
68	19	W	2021-08-02
2	72	B	2021-08-03
128	95	D	2021-08-04
4	86	D	2021-08-05
81	62	B	2021-08-06
121	59	B	2021-08-07
116	97	W	2021-08-08
78	32	W	2021-08-09
53	125	B	2021-08-10
82	56	B	2021-08-11
116	117	W	2021-08-12
56	124	B	2021-08-13
63	137	B	2021-08-14
70	86	D	2021-08-15
79	104	B	2021-08-16
94	86	D	2021-08-17
24	105	B	2021-08-18
46	130	W	2021-08-19
120	83	W	2021-08-20
29	145	D	2021-08-21
35	149	D	2021-08-22
54	139	W	2021-08-23
100	139	W	2021-08-24
141	9	D	2021-08-25
16	66	W	2021-08-26
49	139	B	2021-08-27
70	130	W	2021-08-28
72	11	W	2021-09-01
76	6	D	2021-09-02
69	11	W	2021-09-03
67	108	D	2021-09-04
147	73	W	2021-09-05
80	20	B	2021-09-06
33	95	W	2021-09-07
37	77	W	2021-09-08
4	133	B	2021-09-09
98	80	W	2021-09-10
78	10	D	2021-09-11
11	124	D	2021-09-12
26	89	D	2021-09-13
34	136	D	2021-09-14
86	125	B	2021-09-15
129	50	W	2021-09-16
137	31	B	2021-09-17
104	9	D	2021-09-18
136	19	B	2021-09-19
61	125	D	2021-09-20
53	88	W	2021-09-21
126	131	B	2021-09-22
8	31	W	2021-09-23
112	25	W	2021-09-24
51	118	W	2021-09-25
8	114	W	2021-09-26
101	56	W	2021-09-27
32	120	B	2021-09-28
120	80	D	2021-10-01
43	86	W	2021-10-02
69	73	D	2021-10-03
149	31	D	2021-10-04
24	94	D	2021-10-05
133	84	B	2021-10-06
146	3	D	2021-10-07
86	81	B	2021-10-08
146	88	W	2021-10-09
51	143	W	2021-10-10
84	8	D	2021-10-11
18	92	W	2021-10-12
123	55	D	2021-10-13
46	80	D	2021-10-14
85	15	B	2021-10-15
109	23	B	2021-10-16
79	15	W	2021-10-17
129	9	D	2021-10-18
110	25	B	2021-10-19
30	38	B	2021-10-20
96	80	D	2021-10-21
68	97	B	2021-10-22
20	86	B	2021-10-23
88	99	W	2021-10-24
118	3	D	2021-10-25
73	59	D	2021-10-26
101	132	W	2021-10-27
33	10	B	2021-10-28
88	109	B	2021-11-01
17	107	D	2021-11-02
33	103	D	2021-11-03
102	128	B	2021-11-04
36	120	D	2021-11-05
79	11	D	2021-11-06
129	126	W	2021-11-07
3	106	D	2021-11-08
103	33	B	2021-11-09
79	91	B	2021-11-10
57	103	W	2021-11-11
53	78	D	2021-11-12
75	45	W	2021-11-13
88	147	D	2021-11-14
46	63	W	2021-11-15
83	43	W	2021-11-16
21	144	W	2021-11-17
54	103	D	2021-11-18
28	31	B	2021-11-19
28	31	B	2021-11-20
\.

COPY PTDB4.game_record (id, game_result,ending) from stdin;
1	W	resignation
2	W	mate
3	D	agreement
4	W	resignation
5	D	time
6	B	resignation
7	B	time
8	D	time
\.

COPY PTDB4.pairings (id, white, black, result, match_date, id_record) from stdin;
350	89	130	W	2022-08-17	1
351	149	61	W	2022-08-17	2
352	21	39	D	2022-08-17	3
353	60	1	W	2022-08-17	4
354	66	91	D	2022-08-17	5
355	105	116	B	2022-08-17	6
356	63	132	D	2022-08-17	7
357	105	70	B	2022-08-17	8
\.

COPY PTDB4.formats (id, name) FROM stdin;
1	Double Round Robin
2	Single Round Robin
3	Swiss System
4	Single Elimination
5	Scheveningen System
\.

COPY PTDB4.openings (name) FROM stdin;
"Alekhine Defence"
"Indian Defence"
"Englund Gambit"
"Scandinavian Defence"
"Sicilian Defence"
"French Defence"
"Hungarian Defence"
"Queens Pawn Game"
\.


COPY PTDB4.openings_moves (move_number, move_W, move_B, opening_id) FROM stdin;
1	e4	Nf6	1
1	d4	Nf6	2
1	d4	e5	3
1	e4	d5	4
1	e4	c5	5
1	e4	e6	6
1	g3	d5	7
1	d4	d5	8
\.


COPY PTDB4.cities (id, city, street, street_number) FROM stdin;
1	Krakow	Lojasiewicza	6
2	Katowice	3 Maja	42
3	Vienna	Kaiser st.	112
4	Washington DC	White House	1
5	Sydney	Hobbit st.	214
\.
COPY PTDB4.places (id, country, city_id) FROM stdin;
1	Poland	1
2	Poland	2
3	Australia	3
4	United States	4
5	Austria	5
\.


COPY PTDB4.tournaments (id, name, format, place, start_date, end_date) FROM stdin;
1	TCS Cup	1	3	2019.04.30	2023.05.12
2	Weird Tournament	4	1	2021.03.12	2022.12.17
\.

COPY PTDB4.pairing_tournament (pairing_id, tournament_id) FROM stdin;
11	1
14	1
16	1
60	1
33	1
41	1
100	1
34	1
37	2
52	2
63	2
123	2
155	2
48	2
\.

CREATE OR REPLACE FUNCTION new_player()
    RETURNS TRIGGER AS
$$BEGIN
    insert into PTDB4.elo values (new.id,now(),new.max_elo);
    return new;
end;
$$
language plpgsql;