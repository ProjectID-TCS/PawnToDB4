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
    name        varchar(40) NOT NULL, -- some variant names are really long as they should include time of games and number of players to keep name unique or close to unique
    description varchar(200)
);

CREATE TABLE PTDB4.cities
(
    id            serial PRIMARY KEY,
    city          varchar(85) NOT NULL, --Taumatawhakatangi­hangakoauauotamatea­turipukakapikimaunga­horonukupokaiwhen­uakitanatahu (New Zealand)
    street        varchar(38),          --Jean Baptiste Point du Sable Lake Shore Drive (Chicago)
    street_number varchar(10)           --couldn't find longer, tried though
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
    if (select * from tournaments where id = new.tournament_id) is null then
        return old;
    end if;
    return new;
END;
$$
language plpgsql;



CREATE TABLE PTDB4.openings
(
    id          serial PRIMARY KEY,
    move_number integer    NOT NULL,
    move_W      varchar(7) NOT NULL,
    move_B      varchar(7) NOT NULL,
    unique(id,move_number)
);--no indexing, table will be relatively small

CREATE TABLE PTDB4.opening_name
(
    id   integer references PTDB4.openings not null unique,
    name varchar(20) NOT NULL
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
    id          serial PRIMARY KEY,
    game_id     integer NOT NULL REFERENCES ptdb4.game_record,
    move_number integer NOT NULL,
    move_W      varchar(7), --if there are 3 knights on the board it is possible to need 7 characters to describe one move.
    move_B      varchar(7)  --it would be for example "Nd1xc3#". Black can be null if game ended on white move
);
create or replace function fill_moves(id int,opening_id int)
    returns void as
$$
declare
    move record;
BEGIN
    for move in (select op.move_number, op.move_W, op.move_B from PTDB4.openings op where id = op.opening_id) loop
        --todo
        end loop;
end;
$$
language plpgsql;
create or replace function opening_chck()
    returns trigger as
$$
declare
    move_opening record;
    move record;
begin
    if new.opening is not null then -- opening
    for move_opening in select move_number, move_W,move_B from PTDB4.openings o where id = new.opening loop
        if (select move_W, move_B from ptdb4.moves_record where game_id = new.id) is not null then
            select mr.move_W, mr.move_B from ptdb4.moves_record mr where game_id = new.id and mr.move_number = move_opening.move_number into move;
            if move.move_b <> move_opening.move_b or move.move_w <> move_opening.move_w then
                new.opening := null;
                return new;
            end if;
        else
            if move_opening.move_number = 1 then
            select fill_moves(new.id,new.opening);
            return new;
            else
                new.opening := null;
                return new;
            end if;
        end if;
        end loop;
    end if;
    return new;
end;
$$
language plpgsql;

create trigger opening_chck
    before insert or update on PTDB4.game_record
    for each row execute procedure opening_chck();
create or replace function moves_chck()
    returns trigger as
$$BEGIN

    return new;
end;
$$
language plpgsql;

create or replace trigger moves_chck
    before insert or update on PTDB4.moves_record
    for each row execute procedure moves_chck();

CREATE INDEX each_game ON PTDB4.moves_record (game_id);

CREATE TABLE PTDB4.pairings
(
    id            serial PRIMARY KEY,
    white         integer      NOT NULL REFERENCES ptdb4.players,
    black         integer      NOT NULL REFERENCES ptdb4.players,
    tournament_id integer REFERENCES ptdb4.tournaments,
    "result"      PTDB4.match_result NOT NULL,
    match_date    date,
    id_record     integer REFERENCES ptdb4.game_record
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
24	29	W	2021-09-25
93	116	D	2021-09-25
89	36	W	2021-09-25
124	42	B	2021-09-25
26	113	W	2021-09-25
4	104	D	2021-09-25
57	24	D	2021-09-26
108	100	B	2021-09-26
1	12	D	2021-09-26
82	27	B	2021-09-26
81	5	W	2021-09-26
83	96	W	2021-09-26
39	134	D	2021-09-26
61	147	W	2021-09-26
83	89	W	2021-09-27
121	24	B	2021-09-27
103	44	B	2021-09-27
41	81	D	2021-09-27
114	16	D	2021-09-27
39	67	W	2021-09-27
32	91	W	2021-09-27
45	96	D	2021-09-27
30	84	W	2021-09-27
35	25	D	2021-09-27
81	99	B	2021-09-28
6	146	B	2021-09-28
105	76	B	2021-09-28
26	77	D	2021-09-28
63	70	W	2021-09-28
5	83	B	2021-09-29
51	126	D	2021-09-29
121	130	W	2021-09-29
148	137	W	2021-09-29
138	45	W	2021-09-29
149	111	D	2021-09-29
147	56	W	2021-09-30
2	62	B	2021-09-30
35	32	W	2021-09-30
20	67	D	2021-09-30
22	96	B	2021-09-30
88	19	W	2021-09-30
129	61	B	2021-09-30
46	95	W	2021-10-11
39	91	W	2021-10-11
122	51	W	2021-10-11
109	65	D	2021-10-11
88	111	W	2021-10-11
75	129	B	2021-10-12
24	94	B	2021-10-12
65	33	B	2021-10-13
57	80	W	2021-10-13
36	99	B	2021-10-13
74	78	W	2021-10-13
15	45	B	2021-10-13
14	140	D	2021-10-14
19	136	B	2021-10-14
119	100	B	2021-10-14
124	82	B	2021-10-14
147	122	B	2021-10-14
67	46	W	2021-10-15
60	126	B	2021-11-20
118	76	W	2021-11-20
79	115	B	2021-11-20
44	86	D	2021-11-20
102	19	W	2021-11-20
18	71	W	2021-11-20
109	90	W	2021-11-21
148	142	B	2021-11-21
107	104	B	2021-11-21
63	92	W	2021-11-21
112	95	D	2021-11-21
93	105	D	2021-11-21
14	17	W	2021-11-21
127	17	D	2021-11-22
36	13	B	2021-11-22
19	120	W	2021-11-22
137	11	W	2021-11-22
39	37	B	2021-11-22
40	111	B	2021-11-22
104	53	D	2021-11-23
40	4	D	2021-11-23
132	135	B	2021-11-23
127	94	B	2021-11-23
63	62	D	2021-11-23
27	49	W	2021-11-23
27	1	D	2021-11-24
137	49	D	2021-11-24
85	25	W	2021-11-24
90	62	D	2021-11-24
16	5	B	2021-11-24
13	26	B	2021-11-25
11	98	D	2021-11-25
19	142	D	2021-11-25
68	61	D	2021-11-25
143	95	B	2021-11-25
76	112	B	2021-11-25
134	76	D	2021-11-26
96	11	B	2021-11-26
77	27	D	2021-11-26
124	73	W	2021-11-26
150	114	D	2021-11-26
81	31	W	2021-11-26
7	34	W	2021-11-26
20	77	D	2021-11-27
81	73	W	2021-11-27
111	22	B	2021-11-27
87	44	D	2021-11-27
112	144	W	2021-11-27
126	21	D	2021-11-27
30	137	D	2021-11-27
94	79	W	2021-11-27
120	110	D	2021-11-27
83	73	W	2021-11-28
141	4	D	2021-11-28
33	37	W	2021-11-28
103	147	B	2021-11-28
57	32	D	2021-11-28
67	116	D	2021-11-28
48	50	B	2021-11-28
128	95	D	2021-11-29
114	100	B	2022-01-01
140	109	W	2022-01-01
9	7	B	2022-01-01
97	41	D	2022-01-01
95	148	D	2022-01-01
112	9	D	2022-01-02
101	13	W	2022-01-02
67	121	D	2022-01-02
118	3	D	2022-01-02
95	69	W	2022-01-03
141	144	D	2022-01-03
21	2	D	2022-01-03
36	41	W	2022-01-03
129	18	D	2022-01-03
77	84	W	2022-01-04
87	116	W	2022-01-04
137	86	B	2022-01-04
66	2	D	2022-01-04
68	1	B	2022-01-04
34	71	D	2022-01-04
76	53	B	2022-01-04
84	9	D	2022-01-05
89	24	D	2022-01-05
83	15	B	2022-01-06
106	31	B	2022-01-06
131	119	W	2022-01-06
22	2	D	2022-01-06
149	145	W	2022-01-06
53	52	B	2022-01-06
19	130	B	2022-01-10
143	42	W	2022-01-10
96	119	W	2022-01-10
149	141	W	2022-01-10
113	129	D	2022-01-10
34	93	D	2022-01-11
87	116	B	2022-01-11
65	132	D	2022-01-11
36	121	W	2022-01-11
131	72	W	2022-01-11
58	129	B	2022-01-12
54	120	B	2022-01-12
124	150	B	2022-01-12
103	13	B	2022-01-12
21	101	D	2022-01-12
33	16	D	2022-01-12
38	69	D	2022-01-13
82	100	W	2022-01-13
64	81	W	2022-01-13
52	28	D	2022-01-13
111	146	D	2022-01-13
47	86	D	2022-01-13
142	51	B	2022-01-14
70	24	W	2022-01-14
101	128	B	2022-01-14
76	13	D	2022-01-14
80	125	D	2022-01-14
124	102	D	2022-01-14
36	131	B	2022-01-14
45	75	D	2022-01-15
111	129	W	2022-03-15
92	43	W	2022-03-15
16	96	D	2022-03-15
120	116	D	2022-03-15
20	70	D	2022-03-16
28	57	D	2022-03-16
9	108	B	2022-03-16
33	42	D	2022-03-16
112	56	W	2022-03-16
76	25	D	2022-03-17
18	33	W	2022-03-17
142	74	W	2022-03-17
13	30	W	2022-03-17
29	97	B	2022-03-17
70	145	D	2022-03-17
46	3	B	2022-03-18
12	68	B	2022-03-18
93	24	B	2022-03-18
67	19	W	2022-03-18
2	72	B	2022-03-18
128	95	D	2022-03-19
4	86	D	2022-03-19
81	62	B	2022-03-19
121	59	B	2022-03-19
116	97	W	2022-03-19
78	32	W	2022-03-19
53	125	B	2022-03-19
82	56	B	2022-03-19
116	117	W	2022-03-20
56	124	B	2022-03-20
63	137	B	2022-04-11
70	85	D	2022-04-11
79	104	B	2022-04-11
93	86	D	2022-04-11
24	105	B	2022-04-11
46	130	W	2022-04-12
120	83	W	2022-04-12
29	145	D	2022-04-12
35	149	D	2022-04-12
54	139	W	2022-04-12
100	139	W	2022-04-12
141	9	D	2022-04-13
16	66	W	2022-04-13
49	139	B	2022-04-13
70	130	W	2022-04-13
72	11	W	2022-04-13
76	6	D	2022-04-13
69	11	W	2022-04-13
67	108	D	2022-04-14
147	73	W	2022-04-14
80	20	B	2022-04-14
33	95	W	2022-04-14
37	77	W	2022-04-14
4	133	B	2022-04-14
98	80	W	2022-04-14
78	10	D	2022-04-14
11	124	D	2022-04-15
26	89	D	2022-04-15
34	136	D	2022-04-15
86	125	B	2022-04-15
129	50	W	2022-06-15
137	31	B	2022-06-15
104	9	D	2022-06-15
136	19	B	2022-06-15
61	125	D	2022-06-15
53	88	W	2022-06-16
126	131	B	2022-06-16
8	31	W	2022-06-16
112	25	W	2022-06-16
51	118	W	2022-06-16
8	114	W	2022-06-17
101	56	W	2022-06-17
32	120	B	2022-06-17
120	80	D	2022-06-17
43	86	W	2022-06-17
69	73	D	2022-06-18
149	31	D	2022-06-18
24	94	D	2022-06-18
133	84	B	2022-06-18
146	3	D	2022-06-18
86	81	B	2022-06-18
146	88	W	2022-06-19
51	143	W	2022-06-19
84	8	D	2022-06-19
18	92	W	2022-06-19
123	55	D	2022-06-19
46	80	D	2022-06-19
85	15	B	2022-06-20
109	23	B	2022-06-20
79	15	W	2022-06-20
129	9	D	2022-06-20
110	25	B	2022-06-21
30	38	B	2022-06-21
96	80	D	2022-06-21
68	97	B	2022-06-21
20	86	B	2022-06-21
88	99	W	2022-06-22
118	3	D	2022-06-22
73	59	D	2022-06-22
101	132	W	2022-06-22
33	10	B	2022-06-22
88	109	B	2022-06-23
17	107	D	2022-06-23
33	103	D	2022-06-23
102	128	B	2022-06-23
36	120	D	2022-06-23
79	11	D	2022-06-24
129	126	W	2022-06-24
3	106	D	2022-06-24
103	33	B	2022-06-24
79	91	B	2022-06-24
57	103	W	2022-06-24
53	78	D	2022-06-24
75	45	W	2022-06-25
88	147	D	2022-06-25
46	63	W	2022-06-25
83	43	W	2022-06-25
21	144	W	2022-06-25
54	103	D	2022-06-26
28	31	B	2022-06-26
\.

-- COPY PTDB4.move_record (id, record) from stdin;
-- 1	1. f4 d5 2. Nf3 g6 3. g3 Bg7 4. Bg2 Nf6 5. O-O O-O 6. d3 c5 7. c3 Nc6 8. Na3 Rb8 9. Ne5 Nxe5 10. fxe5 Ne8
-- 2	1. e4 h5 2. h4 g6 3. d4 Bg7 4. Nc3 d6 5. Be3 a6 6. Qd2 b5 7. f3 Nd7 8. Nh3 Bb7 9. O-O-O Rc8 10. Ng5 c5
-- 3	1. e4 c5 2. Nf3 d6 3. d4 Nf6 4. dxc5 Qa5+ 5. Nc3 Qxc5 6. Be3 Qa5 7. Qd2 Nc6 8. h3 g6 9. Bd3 Bg7 10. O-O O-O
-- 4	1. d4 Nf6 2. c4 e6 3. Bg5 Be7 4. Nf3 d5 5. Nc3 O-O 6. e3 Nbd7 7. Qc2 c5 8. Rd1 cxd4 9. exd4 b6 10. Bd3 dxc4
-- 5	1. b3 e5 2. Bb2 Nc6 3. e3 Nf6 4. c4 Be7 5. Nf3 e4 6. Nd4 Nxd4 7. Bxd4 O-O 8. Nc3 c5 9. Be5 d6 10. Bg3 Bf5
-- 6	1. e4 c6 2. Nf3 g6 3. d3 Bg7 4. Nbd2 e5 5. c3 d5 6. Be2 Ne7 7. O-O O-O 8. Re1 h6 9. Bf1 Qc7 10. Qe2 d4
-- 7	1. c4 f5 2. Nc3 Nf6 3. e4 fxe4 4. d3 e5 5. dxe4 Bb4 6. Bd3 Bxc3+ 7. bxc3 d6 8. Ne2 Nbd7 9. O-O Nc5 10. f4 O-O
-- 8	1. d4 Nf6 2. c4 c5 3. d5 b5 4. Nf3 e6 5. Bg5 exd5 6. cxd5 d6 7. e4 a6 8. a4 Be7 9. Bxf6 Bxf6 10. axb5 Bxb2
-- 9	1. d4 f5 2. c4 Nf6 3. g3 e6 4. Bg2 Be7 5. Nf3 O-O 6. O-O Ne4 7. Nbd2 Bf6 8. Qc2 d5 9. b3 c5 10. cxd5 exd5
-- \.

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

COPY PTDB4.openings (id,move_number, move_W,move_B) FROM stdin;
1	1	e4	Nf6
2	1	d4	Nf6
3	1	d4	e5
4	1	e4	d5
5	1	e4	c5
6	1	e4	e6
7	1	g3	d5
8	1	d4	d5
\.

COPY PTDB4.opening_name (id, name) FROM stdin;
1	Alekhine Defence
2	Indian Defence
3	Englund Gambit
4	Scandinavian Defence
5	Sicilian Defence
6	French Defence
7	Hungarian Defence
8	Queens Pawn Game
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
