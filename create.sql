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
    group_id   integer REFERENCES ptdb4.groups
);

CREATE TABLE PTDB4.elo
(
    player_id   integer references PTDB4.players (id),
    acquired_on date,
    elo         integer check (elo > 0 and elo < 3400),
    unique (player_id, acquired_on)
);

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

CREATE TABLE PTDB4.openings
(
    id          serial PRIMARY KEY,
    opening_id  integer REFERENCES PTDB4.opening_name (id),
    move_number integer    NOT NULL,
    move_W      varchar(7) NOT NULL,
    move_B      varchar(7) NOT NULL
);--no indexing, table will be relatively small

CREATE TABLE PTDB4.opening_name
(
    id   serial PRIMARY KEY,
    name varchar(20) NOT NULL
);

CREATE TABLE PTDB4.game_record
(
    id          serial PRIMARY KEY,
    game_id     integer      NOT NULL REFERENCES ptdb4.pairings,
    game_result match_result NOT NULL,
    ending      varchar(10)--possible ending conditions
);

CREATE TABLE PTDB4.moves_record
(
    id          serial PRIMARY KEY,
    game_id     integer NOT NULL REFERENCES ptdb4.game_record,
    move_number integer NOT NULL,
    move_W      varchar(7), --if there are 3 knights on the board it is possible to need 7 characters to describe one move.
    move_B      varchar(7)  --it would be for example "Nd1xc3#". Black can be null if game ended on white move
);

CREATE INDEX each_game ON PTDB4.moves_record (game_id);

CREATE TABLE PTDB4.pairings
(
    id            serial PRIMARY KEY,
    white         integer      NOT NULL REFERENCES ptdb4.players,
    black         integer      NOT NULL REFERENCES ptdb4.players,
    tournament_id integer REFERENCES ptdb4.tournaments,
    "result"      match_result NOT NULL,
    match_date    date,
    id_record     integer REFERENCES ptdb4.game_record
);

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

COPY PTDB4.players (id, first_name, last_name, group_id, elo, max_elo) FROM stdin;
1	Haldorsen	Benjamin	15	2448	2570
2	Tomashevsky	Evgeny	6	2705	2840
3	Kozak	Adam	3	2445	2567
4	Kovalev	Vladislav	4	2703	2838
5	Mazur	Stefan	16	2441	2563
6	Mamedov	Rauf	16	2701	2836
7	Filip	Lucian-Ioan	20	2438	2560
8	Ragger	Markus	14	2696	2831
9	Kourkoulos-Arditis	Stamatis	2	2435	2557
10	Korobov	Anton	13	2686	2820
11	Tomazini	Zan	16	2431	2553
12	Eljanov	Pavel	14	2682	2816
13	Banzea	Alexandru-Bogdan	15	2427	2548
14	Nisipeanu	Liviu-Dieter	17	2670	2804
15	Radovanovic	Nikola	15	2426	2547
16	Berkes	Ferenc	15	2666	2799
17	Arsovic	Zoran	7	2422	2543
18	Safarli	Eltaj	8	2662	2795
19	Hnydiuk	Aleksander	18	2417	2538
20	Edouard	Romain	11	2658	2791
21	Tica	Sven	18	2416	2537
22	Parligras	Mircea-Emilian	11	2657	2790
23	Erdogdu	Mert	2	2413	2534
24	Fressinet	Laurent	3	2652	2785
25	Nikitenko	Mihail	18	2408	2528
26	Alekseenko	Kirill	6	2644	2776
27	Duzhakov	Ilya	14	2405	2525
28	Anton	Guijarro David	17	2643	2775
29	Gadimbayli	Abdulla	13	2404	2524
30	Alekseev	Evgeny	2	2640	2772
31	Zarubitski	Viachaslau	7	2404	2524
32	Lysyj	Igor	1	2635	2767
33	Drnovsek	Gal	1	2402	2522
34	Hovhannisyan	Robert	12	2634	2766
35	Osmak	Iulija	14	2399	2519
36	Lagarde	Maxime	10	2631	2763
37	Kamer	Kayra	11	2397	2517
38	Gledura	Benjamin	8	2630	2762
39	Di	Benedetto Edoardo	19	2394	2514
40	Kobalia	Mikhail	4	2627	2758
41	Saraci	Nderim	4	2391	2511
42	Paravyan	David	6	2627	2758
43	Kaasen	Tor Fredrik	6	2383	2502
44	Jobava	Baadur	18	2622	2753
45	Arsovic	Goran	17	2380	2499
46	Van	Foreest Jorden	2	2621	2752
47	Ayats	Llobera Gerard	18	2377	2496
48	Kozul	Zdenko	12	2619	2750
49	Zlatanovic	Boroljub	17	2376	2495
50	Smirin	Ilia	17	2618	2749
51	Drazic	Sinisa	4	2370	2489
52	Martirosyan	Haik M.	6	2616	2747
53	Stoyanov	Tsvetan	18	2370	2489
54	Vocaturo	Daniele	1	2616	2747
55	Kalogeris	Ioannis	18	2368	2486
56	Chigaev	Maksim	16	2613	2744
57	Serarols	Mabras Bernat	6	2363	2481
58	Erdos	Viktor	9	2612	2743
59	Mihajlov	Sebastian	8	2356	2474
60	Lupulescu	Constantin	7	2611	2742
61	Dimic	Pavle	19	2351	2469
62	Predke	Alexandr	8	2611	2742
63	Pogosyan	Stefan	19	2347	2464
64	Goganov	Aleksey	9	2610	2741
65	Oboladze	Luka	19	2340	2457
66	Deac	Bogdan-Daniel	11	2609	2739
67	Mitsis	Georgios	12	2338	2455
68	Esipenko	Andrey	17	2603	2733
69	Klabis	Rokas	16	2333	2450
70	Moussard	Jules	12	2601	2731
71	Radovanovic	Dusan	11	2331	2448
72	Bartel	Mateusz	4	2600	2730
73	Osmanodja	Filiz	11	2326	2442
74	Antipov	Mikhail Al.	14	2594	2724
75	Tsvetkov	Andrey	3	2322	2438
76	Donchenko	Alexander	4	2593	2723
77	Rabatin	Jakub	6	2313	2429
78	Petrov	Nikita	5	2591	2721
79	Tate	Alan	6	2306	2421
80	Can	Emre	14	2586	2715
81	Petkov	Momchil	16	2296	2411
82	Nikolov	Momchil	6	2584	2713
83	Antova	Gabriela	2	2286	2400
84	Santos	Latasa Jaime	5	2582	2711
85	Sokolovsky	Yahli	17	2278	2392
86	Wagner	Dennis	10	2580	2709
87	Ozenir	Ekin Baris	6	2265	2378
88	Maze	Sebastien	18	2578	2707
89	Martic	Zlatko	12	2261	2374
90	Aleksandrov	Aleksej	11	2574	2703
91	Gueci	Tea	19	2252	2365
92	Djukic	Nikola	12	2572	2701
93	Doncevic	Dario	13	2249	2361
94	Meshkovs	Nikita	14	2568	2696
95	Jarvenpaa	Jari	3	2243	2355
96	Petrosyan	Manuel	10	2564	2692
97	Ingebretsen	Jens E	10	2243	2355
98	Alonso	Rosell Alvar	14	2559	2687
99	Heinemann	Josefine	8	2238	2350
100	Martinovic	Sasa	13	2558	2686
101	Sukovic	Andrej	17	2235	2347
102	Halkias	Stelios	15	2552	2680
103	Milikow	Elie	4	2226	2337
104	Kadric	Denis	2	2547	2674
105	Tadic	Stefan	15	2223	2334
106	Kulaots	Kaido	6	2544	2671
107	Polatel	Ali	12	2220	2331
108	Zhigalko	Andrey	2	2541	2668
109	Stoinev	Metodi	5	2215	2326
110	Stupak	Kirill	15	2537	2664
111	Van	Dael Siem	2	2207	2317
112	Gazik	Viktor	14	2535	2662
113	Gunduz	Umut Erdem	10	2205	2315
114	Kelires	Andreas	7	2529	2655
115	Milikow	Yoav	12	2200	2310
116	Lobanov	Sergei	13	2526	2652
117	Karaoglan	Doruk	5	2197	2307
118	Basso	Pier Luigi	3	2521	2647
119	Martinkus	Rolandas	6	2185	2294
120	Demidov	Mikhail	14	2520	2646
121	Isik	Alparslan	14	2180	2289
122	Potapov	Pavel	7	2517	2643
123	Veleski	Robert	10	2177	2286
124	Valsecchi	Alessio	7	2515	2641
125	Chigaeva	Anastasia	4	2167	2275
126	Zanan	Evgeny	17	2514	2640
127	De	Seroux Camille	3	2160	2268
128	Dragnev	Valentin	11	2511	2637
129	Marinskii	Yurii	16	2156	2264
130	Mirzoev	Emil	7	2511	2637
131	Uruci	Besim	12	2137	2244
132	Keymer	Vincent	5	2509	2634
133	Sekelja	Marko	6	2120	2226
134	Baron	Tal	4	2506	2631
135	Aydincelebi	Kagan	15	2115	2221
136	Quparadze	Giga	17	2501	2626
137	Ivanova	Karina	18	2114	2220
138	Neverov	Valeriy	6	2496	2621
139	Tomashevskaya	Lidia	17	2112	2218
140	Matviishen	Viktor	18	2490	2615
141	Asllani	Muhamet	18	2105	2210
142	Sargsyan	Shant	5	2488	2612
143	Caglar	Sila	4	2094	2199
144	Plenca	Jadranko	12	2487	2611
145	Konstantinov	Aleksandar	14	2079	2183
146	Fakhrutdinov	Timur	5	2485	2609
147	Angun	Batu	1	2076	2180
148	Studer	Noel	6	2479	2603
149	Pantovic	Dragan M	13	2063	2166
150	Livaic	Leon	19	2477	2601
\.

COPY PTDB4.pairings (id, white, black, result, match_date) from stdin;
10	24	29	W	2021-09-27
11	93	116	D	2021-09-27
12	89	36	W	2021-09-27
13	124	42	B	2021-09-27
14	26	113	W	2021-09-27
15	4	104	D	2021-09-27
16	57	24	D	2021-09-27
17	108	100	B	2021-09-27
18	1	12	D	2021-09-27
19	82	27	B	2021-09-27
20	81	5	W	2021-09-27
21	83	96	W	2021-09-27
22	39	134	D	2021-09-27
23	61	147	W	2021-09-27
24	83	89	W	2021-09-27
25	121	24	B	2021-09-27
26	103	44	B	2021-09-27
27	41	81	D	2021-09-27
28	114	16	D	2021-09-27
29	39	67	W	2021-09-27
30	32	91	W	2021-09-27  
31	45	96	D	2021-09-27
32	30	84	W	2021-09-27
33	35	25	D	2021-09-27
34	81	99	B	2021-09-27
35	6	148	B	2021-09-27
36	105	76	B	2021-09-27
37	26	77	D	2021-09-27
38	63	70	W	2021-09-27
39	5	83	B	2021-09-27
40	51	126	D	2021-09-27
41	121	130	W	2021-09-27
42	148	137	W	2021-09-27
43	138	45	W	2021-09-27
44	149	111	D	2021-09-27
45	148	56	W	2021-09-27
46	2	62	B	2021-09-27
47	35	32	W	2021-09-27
48	20	67	D	2021-09-27
49	22	96	B	2021-09-27
50	88	19	W	2021-09-27
51	130	61	B	2021-09-27
52	46	96	W	2021-09-27
53	39	91	W	2021-09-27
54	122	51	W	2021-09-27
55	109	65	D	2021-09-27
56	88	111	W	2021-09-27
57	75	129	B	2021-09-27
58	124	94	B	2021-09-27
59	65	33	B	2021-09-27
60	57	80	W	2021-09-27
61	36	99	B	2021-09-27
62	74	78	W	2021-09-27
63	15	45	B	2021-09-27
64	14	140	D	2021-09-27
65	19	136	B	2021-09-27
66	119	100	B	2021-09-27
67	124	82	B	2021-09-27
68	147	122	B	2021-09-27
69	67	46	W	2021-09-27
70	60	126	B	2021-11-20
71	118	76	W	2021-11-20
72	79	115	B	2021-11-20
73	44	86	D	2021-11-20
74	102	19	W	2021-11-20
75	18	71	W	2021-11-20
76	109	90	W	2021-11-20
77	148	142	B	2021-11-20
78	107	104	B	2021-11-20
79	63	92	W	2021-11-20
80	112	95	D	2021-11-20
81	93	105	D	2021-11-20
82	14	17	W	2021-11-20
83	127	17	D	2021-11-20
84	36	13	B	2021-11-20
85	19	120	W	2021-11-20
86	137	11	W	2021-11-20
87	39	37	B	2021-11-20
88	40	111	B	2021-11-20
89	104	53	D	2021-11-20
90	40	4	D	2021-11-20
91	132	135	B	2021-11-20
92	127	94	B	2021-11-20
93	63	62	D	2021-11-20
94	27	49	W	2021-11-20
95	27	1	D	2021-11-20
96	137	49	D	2021-11-20
97	85	25	W	2021-11-20
98	90	62	D	2021-11-20
99	16	5	B	2021-11-20
100	13	26	B	2021-11-20
101	11	98	D	2021-11-20
102	19	142	D	2021-11-20
103	68	61	D	2021-11-20
104	143	95	B	2021-11-20
105	76	112	B	2021-11-20
106	134	76	D	2021-11-20
107	96	11	B	2021-11-20
108	77	27	D	2021-11-20
109	124	73	W	2021-11-20
110	150	114	D	2021-11-20
111	81	31	W	2021-11-20
112	7	34	W	2021-11-20
113	20	77	D	2021-11-20
114	81	73	W	2021-11-20
115	111	22	B	2021-11-20
116	87	44	D	2021-11-20
117	112	144	W	2021-11-20
118	126	21	D	2021-11-20
119	30	137	D	2021-11-20
120	94	79	W	2021-11-20
121	120	110	D	2021-11-20
122	83	73	W	2021-11-20
123	141	4	D	2021-11-20
124	33	37	W	2021-11-20
125	103	147	B	2021-11-20
126	57	32	D	2021-11-20
127	67	116	D	2021-11-20
128	48	50	B	2021-11-20
129	128	95	D	2021-11-20
130	114	100	B	2022-01-10
131	140	109	W	2022-01-10
132	9	7	B	2022-01-10
133	97	41	D	2022-01-10
134	95	148	D	2022-01-10
135	112	9	D	2022-01-10
136	101	13	W	2022-01-10
137	67	121	D	2022-01-10
138	118	3	D	2022-01-10
139	95	69	W	2022-01-10
140	141	144	D	2022-01-10
141	21	2	D	2022-01-10
142	36	41	W	2022-01-10
143	129	18	D	2022-01-10
144	77	84	W	2022-01-10
145	87	116	W	2022-01-10
146	137	86	B	2022-01-10
147	66	2	D	2022-01-10
148	68	1	B	2022-01-10
149	34	71	D	2022-01-10
150	76	53	B	2022-01-10
151	84	9	D	2022-01-10
152	89	24	D	2022-01-10
153	83	15	B	2022-01-10
154	106	31	B	2022-01-10
155	131	119	W	2022-01-10
156	22	2	D	2022-01-10
157	149	145	W	2022-01-10
158	53	52	B	2022-01-10
159	19	130	B	2022-01-10
160	143	42	W	2022-01-10
161	96	119	W	2022-01-10
162	149	141	W	2022-01-10
163	113	129	D	2022-01-10
164	34	93	D	2022-01-10
165	87	116	B	2022-01-10
166	65	132	D	2022-01-10
167	36	121	W	2022-01-10
168	131	72	W	2022-01-10
169	58	129	B	2022-01-10
170	54	120	B	2022-01-10
171	124	150	B	2022-01-10
172	103	13	B	2022-01-10
173	21	101	D	2022-01-10
174	33	16	D	2022-01-10
175	38	69	D	2022-01-10
176	82	100	W	2022-01-10
177	64	81	W	2022-01-10
178	52	28	D	2022-01-10
179	111	146	D	2022-01-10
180	47	86	D	2022-01-10
181	142	51	B	2022-01-10
182	70	24	W	2022-01-10
183	101	128	B	2022-01-10
184	76	13	D	2022-01-10
185	80	125	D	2022-01-10
186	124	101	D	2022-01-10
187	36	131	B	2022-01-10
188	45	75	D	2022-01-10
190	111	129	W	2022-03-18
191	92	43	W	2022-03-18
192	16	96	D	2022-03-18
193	120	116	D	2022-03-18
194	20	70	D	2022-03-18
195	28	57	D	2022-03-18
196	9	108	B	2022-03-18
197	33	42	D	2022-03-18
198	112	56	W	2022-03-18
199	76	25	D	2022-03-18
200	18	33	W	2022-03-18
201	142	74	W	2022-03-18
202	13	30	W	2022-03-18
203	30	97	B	2022-03-18
204	70	145	D	2022-03-18
205	46	3	B	2022-03-18
206	12	68	B	2022-03-18
207	93	24	B	2022-03-18
208	68	19	W	2022-03-18
209	2	72	B	2022-03-18
210	128	95	D	2022-03-18
211	4	86	D	2022-03-18
212	81	62	B	2022-03-18
213	121	59	B	2022-03-18
214	116	97	W	2022-03-18
215	78	32	W	2022-03-18
216	53	125	B	2022-03-18
217	82	56	B	2022-03-18
218	116	117	W	2022-03-18
219	56	124	B	2022-03-18
220	63	137	B	2022-03-18
221	70	86	D	2022-03-18
222	79	104	B	2022-03-18
223	94	86	D	2022-03-18
224	24	105	B	2022-03-18
225	46	130	W	2022-03-18
226	120	83	W	2022-03-18
227	29	145	D	2022-03-18
228	35	149	D	2022-03-18
229	54	139	W	2022-03-18
230	100	139	W	2022-03-18
231	141	9	D	2022-03-18
232	16	66	W	2022-03-18
233	49	139	B	2022-03-18
234	70	130	W	2022-03-18
235	72	11	W	2022-03-18
236	76	6	D	2022-03-18
237	69	11	W	2022-03-18
238	67	108	D	2022-03-18
239	147	73	W	2022-03-18
240	80	20	B	2022-03-18
241	33	95	W	2022-03-18
242	37	77	W	2022-03-18
243	4	133	B	2022-03-18
244	98	80	W	2022-03-18
245	78	10	D	2022-03-18
246	11	124	D	2022-03-18
247	26	89	D	2022-03-18
248	34	136	D	2022-03-18
249	86	125	B	2022-03-18
250	129	50	W	2022-06-15
251	137	31	B	2022-06-15
252	104	9	D	2022-06-15
253	136	19	B	2022-06-15
254	61	125	D	2022-06-15
255	53	88	W	2022-06-15
256	126	131	B	2022-06-15
257	8	31	W	2022-06-15
258	112	25	W	2022-06-15
259	51	118	W	2022-06-15
260	8	114	W	2022-06-15
261	101	56	W	2022-06-15
262	32	120	B	2022-06-15
263	120	80	D	2022-06-15
264	43	86	W	2022-06-15
265	69	73	D	2022-06-15
266	149	31	D	2022-06-15
267	24	94	D	2022-06-15
268	133	84	B	2022-06-15
269	146	3	D	2022-06-15
270	86	81	B	2022-06-15
271	146	88	W	2022-06-15
272	51	143	W	2022-06-15
273	84	8	D	2022-06-15
274	18	92	W	2022-06-15
275	123	55	D	2022-06-15
276	46	80	D	2022-06-15
277	85	15	B	2022-06-15
278	109	23	B	2022-06-15
279	79	15	W	2022-06-15
280	129	9	D	2022-06-15
281	110	25	B	2022-06-15
282	30	38	B	2022-06-15
283	96	80	D	2022-06-15
284	68	97	B	2022-06-15
285	20	86	B	2022-06-15
286	88	99	W	2022-06-15
287	118	3	D	2022-06-15
288	73	59	D	2022-06-15
289	101	132	W	2022-06-15
290	33	10	B	2022-06-15
291	88	109	B	2022-06-15
292	17	107	D	2022-06-15
293	33	103	D	2022-06-15
294	102	128	B	2022-06-15
295	36	120	D	2022-06-15
296	79	11	D	2022-06-15
297	129	126	W	2022-06-15
298	3	106	D	2022-06-15
299	103	33	B	2022-06-15
300	79	91	B	2022-06-15
301	57	103	W	2022-06-15
302	53	78	D	2022-06-15
303	75	45	W	2022-06-15
304	88	147	D	2022-06-15
305	46	63	W	2022-06-15
306	83	43	W	2022-06-15
307	21	144	W	2022-06-15
308	54	103	D	2022-06-15
309	28	31	B	2022-06-15
\.
--
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

COPY PTDB4.game_record (id, id_record, game_result) from stdin;
1	9	W
2	8	W
3	7	D
4	6	W
5	5	D
6	4	B
7	3	B
8	2	D
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

COPY PTDB4.openings (id, first_moves, name) FROM stdin;
1   1   1   e4  Nf6
2   2   1   d4  Nf6
3   3   1   d4  e5
4   4   1   e4  d5
5   5   1   e4  c5
6   6   1   e4  e6
7   7   1   g3  d5
8   8   1   d4  d5
\.

COPY PTDB4.opening_name (id, name) FROM stdin;
1   Alekhine Defence
2   Indian Defence
3   Englund Gambit
4   Scandinavian Defence
5   Sicilian Defence
6   French Defence
7   Hungarian Defence
8   Queens Pawn Game

COPY PTDB4.places (id, country, city_id) FROM stdin;
1	Poland	1
2	Poland	2
3	Australia	3
4	United States	4
5	Austria	5
\.

COPY PTDB4.cities (id, city, street, street_number) FROM stdin;
1	Krakow	Lojasiewicza	6
2	Katowice	3 Maja	42
3	Vienna	Kaiser st.	112
4	Washington DC	White House	1
5	Sydney	Hobbit st.	214

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
