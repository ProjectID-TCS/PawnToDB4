COPY groups (id, group_name) FROM stdin;
1	"Red"
2	"Orange"
3	"Yellow"
4	"Green"
5	"Blue"
6	"Indigo"
7	"Violet"
8	"Pink"
9	"Purple"
10	"Turquoise"
11	"Gold"
12	"Lime"
13	"Maroon"
14	"Navy"
15	"Coral"
16	"Teal"
17	"Brown"
18	"White"
19	"Black"
20	"Sky"

COPY pairings (id, white, black, result, data) from stdin;
10 	 87 	 6 	 draw 	now()	
11 	 258 	 133 	 draw 	now()	
12 	 242 	 15 	 white 	now()	
13 	 78 	 97 	 white 	now()	
14 	 204 	 223 	 white 	now()	
15 	 46 	 270 	 draw 	now()	
16 	 260 	 22 	 black 	now()	
17 	 189 	 185 	 draw 	now()	
18 	 219 	 121 	 draw 	now()	
20 	 84 	 50 	 white 	now()	
21 	 290 	 268 	 black 	now()	
22 	 268 	 163 	 white 	now()	
23 	 156 	 118 	 draw 	now()	
24 	 266 	 195 	 draw 	now()	
25 	 181 	 259 	 white 	now()	
26 	 133 	 141 	 black 	now()	
27 	 22 	 277 	 black 	now()	
28 	 33 	 53 	 black 	now()	
30 	 40 	 132 	 draw 	now()	
31 	 92 	 286 	 draw 	now()	
32 	 112 	 157 	 white 	now()	
33 	 150 	 134 	 white 	now()	
34 	 51 	 89 	 black 	now()	
35 	 270 	 39 	 white 	now()	
36 	 231 	 209 	 draw 	now()	
37 	 182 	 290 	 draw 	now()	
38 	 11 	 167 	 draw 	now()	
39 	 244 	 10 	 draw 	now()	
40 	 66 	 295 	 draw 	now()	
41 	 148 	 190 	 black 	now()	
42 	 141 	 58 	 black 	now()	
43 	 214 	 32 	 draw 	now()	
44 	 21 	 128 	 black 	now()	
45 	 202 	 118 	 white 	now()	
46 	 284 	 36 	 white 	now()	
47 	 170 	 46 	 white 	now()	
48 	 67 	 88 	 black 	now()	
49 	 105 	 134 	 draw 	now()	
50 	 286 	 257 	 draw 	now()	
51 	 142 	 216 	 white 	now()	
52 	 113 	 75 	 white 	now()	
53 	 215 	 177 	 draw 	now()	
54 	 45 	 244 	 white 	now()	
55 	 136 	 25 	 black 	now()	
56 	 228 	 220 	 white 	now()	
57 	 269 	 225 	 black 	now()	
58 	 56 	 13 	 draw 	now()	
59 	 281 	 280 	 draw 	now()	
60 	 47 	 120 	 white 	now()	
61 	 130 	 74 	 black 	now()	
62 	 139 	 130 	 white 	now()	
63 	 274 	 137 	 black 	now()	
64 	 148 	 108 	 draw 	now()	
65 	 224 	 211 	 draw 	now()	
66 	 181 	 80 	 draw 	now()	
67 	 94 	 64 	 black 	now()	
68 	 39 	 206 	 draw 	now()	
69 	 56 	 75 	 draw 	now()	
70 	 161 	 1 	 white 	now()	
71 	 252 	 40 	 draw 	now()	
72 	 274 	 230 	 black 	now()	
73 	 287 	 162 	 draw 	now()	
74 	 176 	 258 	 black 	now()	
75 	 200 	 122 	 draw 	now()	
76 	 142 	 114 	 black 	now()	
77 	 165 	 198 	 black 	now()	
78 	 253 	 134 	 white 	now()	
79 	 226 	 239 	 white 	now()	
80 	 79 	 256 	 white 	now()	
81 	 62 	 74 	 black 	now()	
82 	 63 	 290 	 white 	now()	
83 	 43 	 174 	 draw 	now()	
84 	 99 	 140 	 draw 	now()	
85 	 211 	 7 	 draw 	now()	
86 	 96 	 299 	 draw 	now()	
87 	 244 	 155 	 draw 	now()	
88 	 20 	 34 	 white 	now()	
89 	 176 	 255 	 black 	now()	
90 	 8 	 47 	 draw 	now()	
91 	 109 	 63 	 black 	now()	
92 	 93 	 158 	 draw 	now()	
93 	 171 	 183 	 white 	now()	
94 	 49 	 203 	 black 	now()	
95 	 11 	 137 	 black 	now()	
96 	 292 	 9 	 black 	now()	
97 	 200 	 23 	 white 	now()	
98 	 75 	 208 	 white 	now()	
99 	 270 	 25 	 draw 	now()	
100 	 279 	 195 	 white 	now()	
101 	 245 	 58 	 draw 	now()	
102 	 108 	 185 	 white 	now()	
103 	 32 	 280 	 black 	now()	
104 	 94 	 247 	 draw 	now()	
105 	 201 	 184 	 black 	now()	
106 	 27 	 178 	 black 	now()	
107 	 96 	 297 	 draw 	now()	
108 	 72 	 20 	 black 	now()	
109 	 272 	 115 	 draw 	now()	
110 	 52 	 38 	 white 	now()	
111 	 147 	 236 	 draw 	now()	
112 	 47 	 27 	 white 	now()	
113 	 85 	 68 	 white 	now()	
114 	 163 	 191 	 draw 	now()	
115 	 289 	 50 	 white 	now()	
116 	 251 	 91 	 black 	now()	
117 	 229 	 45 	 black 	now()	
118 	 44 	 118 	 white 	now()	
119 	 237 	 201 	 white 	now()	
120 	 81 	 20 	 white 	now()	
121 	 273 	 13 	 black 	now()	
122 	 252 	 123 	 draw 	now()	
124 	 37 	 278 	 white 	now()	
125 	 47 	 11 	 draw 	now()	
126 	 259 	 147 	 draw 	now()	
127 	 103 	 46 	 black 	now()	
128 	 240 	 231 	 white 	now()	
129 	 86 	 286 	 white 	now()	
130 	 28 	 77 	 black 	now()	
131 	 234 	 65 	 white 	now()	
132 	 198 	 114 	 draw 	now()	
133 	 164 	 211 	 white 	now()	
134 	 94 	 225 	 white 	now()	
135 	 81 	 85 	 white 	now()	
136 	 10 	 158 	 white 	now()	
137 	 136 	 34 	 black 	now()	
138 	 136 	 67 	 black 	now()	
139 	 53 	 34 	 draw 	now()	
140 	 92 	 204 	 draw 	now()	
141 	 24 	 218 	 draw 	now()	
142 	 117 	 41 	 black 	now()	
143 	 62 	 220 	 draw 	now()	
144 	 176 	 6 	 black 	now()	
145 	 224 	 265 	 draw 	now()	
146 	 120 	 157 	 draw 	now()	
147 	 122 	 247 	 white 	now()	
148 	 65 	 233 	 draw 	now()	
149 	 282 	 226 	 draw 	now()	
150 	 85 	 254 	 black 	now()	
151 	 48 	 100 	 draw 	now()	
152 	 11 	 164 	 black 	now()	
153 	 63 	 201 	 black 	now()	
154 	 169 	 263 	 white 	now()	
155 	 109 	 189 	 black 	now()	
156 	 149 	 127 	 white 	now()	
157 	 283 	 28 	 black 	now()	
158 	 287 	 138 	 white 	now()	
159 	 130 	 94 	 draw 	now()	
160 	 80 	 258 	 draw 	now()	
161 	 30 	 79 	 black 	now()	
162 	 109 	 277 	 draw 	now()	
163 	 162 	 249 	 draw 	now()	
164 	 299 	 51 	 white 	now()	
165 	 162 	 101 	 black 	now()	
166 	 243 	 109 	 white 	now()	
167 	 4 	 81 	 black 	now()	
168 	 75 	 69 	 draw 	now()	
169 	 59 	 97 	 white 	now()	
170 	 108 	 21 	 draw 	now()	
171 	 151 	 205 	 black 	now()	
172 	 88 	 79 	 black 	now()	
173 	 143 	 11 	 white 	now()	
174 	 251 	 179 	 white 	now()	
175 	 153 	 288 	 white 	now()	
176 	 222 	 38 	 draw 	now()	
177 	 254 	 169 	 draw 	now()	
178 	 294 	 148 	 draw 	now()	
180 	 252 	 2 	 draw 	now()	
181 	 46 	 111 	 white 	now()	
182 	 52 	 91 	 black 	now()	
183 	 183 	 283 	 draw 	now()	
184 	 176 	 112 	 white 	now()	
185 	 263 	 239 	 white 	now()	
186 	 62 	 112 	 draw 	now()	
187 	 243 	 197 	 white 	now()	
188 	 170 	 292 	 draw 	now()	
189 	 114 	 102 	 white 	now()	
190 	 262 	 265 	 white 	now()	
191 	 107 	 89 	 draw 	now()	
192 	 96 	 66 	 draw 	now()	
193 	 151 	 211 	 white 	now()	
194 	 12 	 295 	 black 	now()	
195 	 256 	 246 	 white 	now()	
196 	 260 	 87 	 draw 	now()	
197 	 143 	 73 	 black 	now()	
198 	 1 	 118 	 black 	now()	
199 	 33 	 37 	 black 	now()	
200 	 267 	 93 	 draw 	now()	
201 	 36 	 289 	 white 	now()	
202 	 118 	 19 	 draw 	now()	
203 	 125 	 267 	 draw 	now()	
204 	 192 	 182 	 white 	now()	
205 	 184 	 234 	 white 	now()	
206 	 206 	 147 	 white 	now()	
208 	 93 	 233 	 draw 	now()	
209 	 36 	 62 	 black 	now()	
210 	 244 	 53 	 draw 	now()	
211 	 149 	 189 	 black 	now()	
212 	 217 	 27 	 draw 	now()	
213 	 204 	 140 	 black 	now()	
214 	 210 	 122 	 black 	now()	
215 	 156 	 239 	 draw 	now()	
216 	 48 	 109 	 black 	now()	
217 	 154 	 260 	 black 	now()	
218 	 290 	 233 	 draw 	now()	
219 	 250 	 35 	 white 	now()	
220 	 54 	 38 	 white 	now()	
221 	 27 	 36 	 draw 	now()	
222 	 241 	 228 	 draw 	now()	
223 	 268 	 2 	 white 	now()	
224 	 189 	 86 	 black 	now()	
225 	 297 	 292 	 white 	now()	
226 	 191 	 150 	 draw 	now()	
227 	 48 	 272 	 black 	now()	
228 	 254 	 141 	 white 	now()	
229 	 20 	 284 	 white 	now()	
230 	 75 	 142 	 white 	now()	
231 	 166 	 6 	 black 	now()	
232 	 6 	 25 	 draw 	now()	
233 	 221 	 95 	 black 	now()	
234 	 143 	 43 	 black 	now()	
235 	 90 	 97 	 white 	now()	
236 	 197 	 173 	 black 	now()	
237 	 60 	 16 	 draw 	now()	
238 	 83 	 105 	 white 	now()	
239 	 126 	 24 	 white 	now()	
240 	 276 	 237 	 draw 	now()	
241 	 19 	 208 	 draw 	now()	
242 	 107 	 129 	 black 	now()	
244 	 151 	 130 	 white 	now()	
245 	 144 	 170 	 white 	now()	
246 	 147 	 159 	 white 	now()	
247 	 6 	 241 	 white 	now()	
248 	 281 	 181 	 black 	now()	
249 	 250 	 94 	 draw 	now()	
250 	 252 	 127 	 black 	now()	
251 	 212 	 293 	 black 	now()	
252 	 250 	 235 	 draw 	now()	
253 	 234 	 198 	 draw 	now()	
254 	 165 	 20 	 white 	now()	
255 	 128 	 48 	 black 	now()	
256 	 59 	 101 	 draw 	now()	
257 	 33 	 176 	 white 	now()	
258 	 149 	 116 	 black 	now()	
259 	 174 	 241 	 white 	now()	
260 	 17 	 285 	 white 	now()	
261 	 63 	 124 	 black 	now()	
262 	 90 	 48 	 white 	now()	
263 	 64 	 22 	 draw 	now()	
264 	 11 	 18 	 black 	now()	
265 	 175 	 9 	 white 	now()	
266 	 40 	 245 	 white 	now()	
267 	 231 	 55 	 black 	now()	
268 	 250 	 265 	 white 	now()	
270 	 55 	 155 	 draw 	now()	
271 	 22 	 249 	 draw 	now()	
272 	 279 	 207 	 white 	now()	
273 	 36 	 112 	 white 	now()	
274 	 164 	 125 	 draw 	now()	
275 	 164 	 60 	 draw 	now()	
277 	 18 	 79 	 draw 	now()	
278 	 119 	 224 	 white 	now()	
279 	 123 	 106 	 white 	now()	
280 	 207 	 129 	 black 	now()	
281 	 150 	 194 	 white 	now()	
282 	 122 	 277 	 draw 	now()	
283 	 91 	 79 	 black 	now()	
284 	 160 	 221 	 white 	now()	
285 	 48 	 266 	 black 	now()	
286 	 184 	 250 	 white 	now()	
287 	 222 	 299 	 white 	now()	
288 	 58 	 106 	 white 	now()	
289 	 10 	 162 	 black 	now()	
290 	 107 	 142 	 draw 	now()	
291 	 97 	 187 	 black 	now()	
292 	 120 	 73 	 black 	now()	
293 	 197 	 244 	 white 	now()	
294 	 115 	 231 	 draw 	now()	
295 	 33 	 73 	 draw 	now()	
296 	 199 	 194 	 white 	now()	
297 	 41 	 273 	 white 	now()	
298 	 204 	 264 	 black 	now()	
299 	 109 	 191 	 black 	now()	
300 	 217 	 220 	 black 	now()	
302 	 108 	 22 	 draw 	now()	
303 	 257 	 108 	 black 	now()	
304 	 246 	 76 	 white 	now()	
305 	 158 	 91 	 draw 	now()	
306 	 297 	 30 	 black 	now()	
307 	 122 	 103 	 black 	now()	
308 	 86 	 288 	 black 	now()	
309 	 57 	 101 	 white 	now()	
COPY pairings (id, white, black, result, date, id_record) from stdin;
19 	 266 	 31 	 black 	now()   "1. e4 h5 2. h4 g6 3. d4 Bg7 4. Nc3 d6 5. Be3 a6 6. Qd2 b5 7. f3 Nd7 8. Nh3 Bb7 9. O-O-O Rc8 10. Ng5 c5 "
29 	 219 	 127 	 draw 	now()	"1. e4 c5 2. Nf3 d6 3. d4 Nf6 4. dxc5 Qa5+ 5. Nc3 Qxc5 6. Be3 Qa5 7. Qd2 Nc6 8. h3 g6 9. Bd3 Bg7 10. O-O O-O "
123 	 215 	 261 	 black 	now()	"1. f4 d5 2. Nf3 g6 3. g3 Bg7 4. Bg2 Nf6 5. O-O O-O 6. d3 c5 7. c3 Nc6 8. Na3 Rb8 9. Ne5 Nxe5 10. fxe5 Ne8 "
179 	 37 	 13 	 black 	now()	"1. d4 Nf6 2. c4 e6 3. Bg5 Be7 4. Nf3 d5 5. Nc3 O-O 6. e3 Nbd7 7. Qc2 c5 8. Rd1 cxd4 9. exd4 b6 10. Bd3 dxc4 "
207 	 65 	 221 	 white 	now()	"1. b3 e5 2. Bb2 Nc6 3. e3 Nf6 4. c4 Be7 5. Nf3 e4 6. Nd4 Nxd4 7. Bxd4 O-O 8. Nc3 c5 9. Be5 d6 10. Bg3 Bf5 "
243 	 172 	 252 	 draw 	now()	"1. e4 c6 2. Nf3 g6 3. d3 Bg7 4. Nbd2 e5 5. c3 d5 6. Be2 Ne7 7. O-O O-O 8. Re1 h6 9. Bf1 Qc7 10. Qe2 d4"
269 	 72 	 54 	 draw 	now()	"1. c4 f5 2. Nc3 Nf6 3. e4 fxe4 4. d3 e5 5. dxe4 Bb4 6. Bd3 Bxc3+ 7. bxc3 d6 8. Ne2 Nbd7 9. O-O Nc5 10. f4 O-O "
276 	 162 	 36 	 white 	now()	"1. d4 Nf6 2. c4 c5 3. d5 b5 4. Nf3 e6 5. Bg5 exd5 6. cxd5 d6 7. e4 a6 8. a4 Be7 9. Bxf6 Bxf6 10. axb5 Bxb2 "
301 	 168 	 281 	 black 	now()	"1. d4 f5 2. c4 Nf6 3. g3 e6 4. Bg2 Be7 5. Nf3 O-O 6. O-O Ne4 7. Nbd2 Bf6 8. Qc2 d5 9. b3 c5 10. cxd5 exd5 "

COPY players (id,first_name,last_name, group_id, elo, max_elo) FROM stdin;
1	"Haldorsen"	"Benjamin"	15	2448	2570
2	"Tomashevsky"	"Evgeny"	6	2705	2840
3	"Kozak"	"Adam"	3	2445	2567
4	"Kovalev"	"Vladislav"	4	2703	2838
5	"Mazur"	"Stefan"	16	2441	2563
6	"Mamedov"	"Rauf"	16	2701	2836
7	"Filip"	"Lucian-Ioan"	20	2438	2560
8	"Ragger"	"Markus"	14	2696	2831
9	"Kourkoulos-Arditis"	"Stamatis"	2	2435	2557
10	"Korobov"	"Anton"	13	2686	2820
11	"Tomazini"	"Zan"	16	2431	2553
12	"Eljanov"	"Pavel"	14	2682	2816
13	"Banzea"	"Alexandru-Bogdan"	15	2427	2548
14	"Nisipeanu"	"Liviu-Dieter"	17	2670	2804
15	"Radovanovic"	"Nikola"	15	2426	2547
16	"Berkes"	"Ferenc"	15	2666	2799
17	"Arsovic"	"Zoran"	7	2422	2543
18	"Safarli"	"Eltaj"	8	2662	2795
19	"Hnydiuk"	"Aleksander"	18	2417	2538
20	"Edouard"	"Romain"	11	2658	2791
21	"Tica"	"Sven"	18	2416	2537
22	"Parligras"	"Mircea-Emilian"	11	2657	2790
23	"Erdogdu"	"Mert"	2	2413	2534
24	"Fressinet"	"Laurent"	3	2652	2785
25	"Nikitenko"	"Mihail"	18	2408	2528
26	"Alekseenko"	"Kirill"	6	2644	2776
27	"Duzhakov"	"Ilya"	14	2405	2525
28	"Anton"	"Guijarro David"	17	2643	2775
29	"Gadimbayli"	"Abdulla"	13	2404	2524
30	"Alekseev"	"Evgeny"	2	2640	2772
31	"Zarubitski"	"Viachaslau"	7	2404	2524
32	"Lysyj"	"Igor"	1	2635	2767
33	"Drnovsek"	"Gal"	1	2402	2522
34	"Hovhannisyan"	"Robert"	12	2634	2766
35	"Osmak"	"Iulija"	14	2399	2519
36	"Lagarde"	"Maxime"	10	2631	2763
37	"Kamer"	"Kayra"	11	2397	2517
38	"Gledura"	"Benjamin"	8	2630	2762
39	"Di"	"Benedetto Edoardo"	19	2394	2514
40	"Kobalia"	"Mikhail"	4	2627	2758
41	"Saraci"	"Nderim"	4	2391	2511
42	"Paravyan"	"David"	6	2627	2758
43	"Kaasen"	"Tor Fredrik"	6	2383	2502
44	"Jobava"	"Baadur"	18	2622	2753
45	"Arsovic"	"Goran"	17	2380	2499
46	"Van"	"Foreest Jorden"	2	2621	2752
47	"Ayats"	"Llobera Gerard"	18	2377	2496
48	"Kozul"	"Zdenko"	12	2619	2750
49	"Zlatanovic"	"Boroljub"	17	2376	2495
50	"Smirin"	"Ilia"	17	2618	2749
51	"Drazic"	"Sinisa"	4	2370	2489
52	"Martirosyan"	"Haik M."	6	2616	2747
53	"Stoyanov"	"Tsvetan"	18	2370	2489
54	"Vocaturo"	"Daniele"	1	2616	2747
55	"Kalogeris"	"Ioannis"	18	2368	2486
56	"Chigaev"	"Maksim"	16	2613	2744
57	"Serarols"	"Mabras Bernat"	6	2363	2481
58	"Erdos"	"Viktor"	9	2612	2743
59	"Mihajlov"	"Sebastian"	8	2356	2474
60	"Lupulescu"	"Constantin"	7	2611	2742
61	"Dimic"	"Pavle"	19	2351	2469
62	"Predke"	"Alexandr"	8	2611	2742
63	"Pogosyan"	"Stefan"	19	2347	2464
64	"Goganov"	"Aleksey"	9	2610	2741
65	"Oboladze"	"Luka"	19	2340	2457
66	"Deac"	"Bogdan-Daniel"	11	2609	2739
67	"Mitsis"	"Georgios"	12	2338	2455
68	"Esipenko"	"Andrey"	17	2603	2733
69	"Klabis"	"Rokas"	16	2333	2450
70	"Moussard"	"Jules"	12	2601	2731
71	"Radovanovic"	"Dusan"	11	2331	2448
72	"Bartel"	"Mateusz"	4	2600	2730
73	"Osmanodja"	"Filiz"	11	2326	2442
74	"Antipov"	"Mikhail Al."	14	2594	2724
75	"Tsvetkov"	"Andrey"	3	2322	2438
76	"Donchenko"	"Alexander"	4	2593	2723
77	"Rabatin"	"Jakub"	6	2313	2429
78	"Petrov"	"Nikita"	5	2591	2721
79	"Tate"	"Alan"	6	2306	2421
80	"Can"	"Emre"	14	2586	2715
81	"Petkov"	"Momchil"	16	2296	2411
82	"Nikolov"	"Momchil"	6	2584	2713
83	"Antova"	"Gabriela"	2	2286	2400
84	"Santos"	"Latasa Jaime"	5	2582	2711
85	"Sokolovsky"	"Yahli"	17	2278	2392
86	"Wagner"	"Dennis"	10	2580	2709
87	"Ozenir"	"Ekin Baris"	6	2265	2378
88	"Maze"	"Sebastien"	18	2578	2707
89	"Martic"	"Zlatko"	12	2261	2374
90	"Aleksandrov"	"Aleksej"	11	2574	2703
91	"Gueci"	"Tea"	19	2252	2365
92	"Djukic"	"Nikola"	12	2572	2701
93	"Doncevic"	"Dario"	13	2249	2361
94	"Meshkovs"	"Nikita"	14	2568	2696
95	"Jarvenpaa"	"Jari"	3	2243	2355
96	"Petrosyan"	"Manuel"	10	2564	2692
97	"Ingebretsen"	"Jens E"	10	2243	2355
98	"Alonso"	"Rosell Alvar"	14	2559	2687
99	"Heinemann"	"Josefine"	8	2238	2350
100	"Martinovic"	"Sasa"	13	2558	2686
101	"Sukovic"	"Andrej"	17	2235	2347
102	"Halkias"	"Stelios"	15	2552	2680
103	"Milikow"	"Elie"	4	2226	2337
104	"Kadric"	"Denis"	2	2547	2674
105	"Tadic"	"Stefan"	15	2223	2334
106	"Kulaots"	"Kaido"	6	2544	2671
107	"Polatel"	"Ali"	12	2220	2331
108	"Zhigalko"	"Andrey"	2	2541	2668
109	"Stoinev"	"Metodi"	5	2215	2326
110	"Stupak"	"Kirill"	15	2537	2664
111	"Van"	"Dael Siem"	2	2207	2317
112	"Gazik"	"Viktor"	14	2535	2662
113	"Gunduz"	"Umut Erdem"	10	2205	2315
114	"Kelires"	"Andreas"	7	2529	2655
115	"Milikow"	"Yoav"	12	2200	2310
116	"Lobanov"	"Sergei"	13	2526	2652
117	"Karaoglan"	"Doruk"	5	2197	2307
118	"Basso"	"Pier Luigi"	3	2521	2647
119	"Martinkus"	"Rolandas"	6	2185	2294
120	"Demidov"	"Mikhail"	14	2520	2646
121	"Isik"	"Alparslan"	14	2180	2289
122	"Potapov"	"Pavel"	7	2517	2643
123	"Veleski"	"Robert"	10	2177	2286
124	"Valsecchi"	"Alessio"	7	2515	2641
125	"Chigaeva"	"Anastasia"	4	2167	2275
126	"Zanan"	"Evgeny"	17	2514	2640
127	"De"	"Seroux Camille"	3	2160	2268
128	"Dragnev"	"Valentin"	11	2511	2637
129	"Marinskii"	"Yurii"	16	2156	2264
130	"Mirzoev"	"Emil"	7	2511	2637
131	"Uruci"	"Besim"	12	2137	2244
132	"Keymer"	"Vincent"	5	2509	2634
133	"Sekelja"	"Marko"	6	2120	2226
134	"Baron"	"Tal"	4	2506	2631
135	"Aydincelebi"	"Kagan"	15	2115	2221
136	"Quparadze"	"Giga"	17	2501	2626
137	"Ivanova"	"Karina"	18	2114	2220
138	"Neverov"	"Valeriy"	6	2496	2621
139	"Tomashevskaya"	"Lidia"	17	2112	2218
140	"Matviishen"	"Viktor"	18	2490	2615
141	"Asllani"	"Muhamet"	18	2105	2210
142	"Sargsyan"	"Shant"	5	2488	2612
143	"Caglar"	"Sila"	4	2094	2199
144	"Plenca"	"Jadranko"	12	2487	2611
145	"Konstantinov"	"Aleksandar"	14	2079	2183
146	"Fakhrutdinov"	"Timur"	5	2485	2609
147	"Angun"	"Batu"	1	2076	2180
148	"Studer"	"Noel"	6	2479	2603
149	"Pantovic"	"Dragan M"	13	2063	2166
150	"Livaic"	"Leon"	19	2477	2601
