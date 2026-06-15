--
-- PostgreSQL database dump
--

\restrict VKNypDIPMlkoeTcT4071RDDT4dA30QobwmcwHOR3bstTxJkZ0u4V4DcuoaIgChx

-- Dumped from database version 16.13
-- Dumped by pg_dump version 16.13

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: marketplace
--

COPY public.roles (role_id, name) FROM stdin;
1	admin
2	buyer
3	seller
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: marketplace
--

COPY public.users (user_id, role_id, first_name, last_name, patronymic, phone, email, password_hash, gender, created_at) FROM stdin;
1	2	\N	\N	\N	\N	test@test.com	$2a$10$/qkzJn2N8P3.2xxZSDXbFu20D2K39R5XCyiSNYuC5UI9PvHKO1AES	\N	2026-03-02 12:18:55.849355+00
2	2	\N	\N	\N	\N	test1@test.com	$2a$10$H759GjaJJYN1Rzgrb06yHeZtcI4CLourRTzwCxWrXaNwyaj4/MRxy	\N	2026-03-02 12:23:06.090785+00
4	1	\N	\N	\N	\N	me2@test.com	$2a$10$dOIvBHfXE2Syje598nyYL.JtbzT1CUlWvPhaWX9ktsvQ3KjqjnBKy	\N	2026-03-02 12:26:11.429133+00
3	3	Ivan	Petrov	\N	\N	test2@test.com	$2a$10$meK4SfGYuppHfra6vw./su3l18pCMy8pzffef6JtFgethg/TPRJgm	\N	2026-03-02 12:25:22.119579+00
6	3	\N	\N	\N	\N	seller@test.com	$2a$10$XgeoyXdRF8kyNSa5ZyEo5uR40TPClwNDhiERepw/2.fdew1bcWlF6	\N	2026-03-06 23:05:37.462979+00
7	2	\N	\N	\N	\N	buyer2@gmail.com	$2a$10$GorMA5c0ntDBJCDsG3Ga3OFO5Ro2Ne188oSZlsjpYzn.FKgqEnWca	\N	2026-03-09 14:07:46.615698+00
8	2	\N	\N	\N	\N	buyer2@test.com	$2a$10$dcuer4wsSySEvUWCJc5Y7u7lDYgJtkwzHk8/4h7fSejL1wzn20oJy	\N	2026-03-09 14:32:42.777616+00
9	3	\N	\N	\N	\N	seller2@test.com	$2a$10$K0/GhFJ/vwy8vUboibMBfu2o5gh7yS7ERapTLmFOkajdcU99WPM8.	\N	2026-03-09 14:32:53.997084+00
10	3	\N	\N	\N	\N	sallers11@gmail.com	$2a$10$1AZgfWq0uX2ahufM7NF0JOEuL9BDMgo5GPKrehYaifI7i.Uv2hPUW	\N	2026-03-09 14:45:44.026507+00
5	2	╨╛╨║╨╛╨░╨╛	╨╗╨░╨╗╨░╨╗	╨┐╨╗╨┐╨╗╨╗╨░	+375 (29) 651-34-21	buyer@test.com	$2a$10$sAqteT1A9ILyCapWjfBFAe57qVZMapczbinc/UkvYB9Wt1pUQNSFu	female	2026-03-02 13:56:20.283802+00
\.


--
-- Data for Name: carts; Type: TABLE DATA; Schema: public; Owner: marketplace
--

COPY public.carts (cart_id, user_id, created_at) FROM stdin;
1	5	2026-03-02 14:07:41.352545+00
\.


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: marketplace
--

COPY public.categories (category_id, name) FROM stdin;
1	Electronics
\.


--
-- Data for Name: list_types; Type: TABLE DATA; Schema: public; Owner: marketplace
--

COPY public.list_types (list_type_id, list_type_name) FROM stdin;
1	cart
2	favorites
3	later
\.


--
-- Data for Name: sellers; Type: TABLE DATA; Schema: public; Owner: marketplace
--

COPY public.sellers (seller_id, shop_name, description, inn, unp, user_id) FROM stdin;
2	My Test Shop	\N	\N	\N	9
3	magn	\N	\N	\N	10
1	Demo Shop	Seed seller	0000000000	7387372727	6
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: marketplace
--

COPY public.products (product_id, category_id, seller_id, name, description, price, quantity, created_at, currency) FROM stdin;
1	1	1	iPhone Demo	Seed product for dev	999.99	10	2026-03-03 12:36:22.946494+00	RUB
2	1	1	Seller order tetsssss	test	100.00	5	2026-03-18 16:10:48.73772+00	BYN
3	1	1	test phone	╤é╨╡╨╗╨╡╤ä╨╛╨╜	200.00	200	2026-03-18 17:47:01.592237+00	BYN
\.


--
-- Data for Name: cart_items; Type: TABLE DATA; Schema: public; Owner: marketplace
--

COPY public.cart_items (cart_item_id, cart_id, product_id, quantity, added_at, selected_for_purchase, list_type_id, status) FROM stdin;
15	1	1	1	2026-03-18 05:31:43.190552+00	f	1	ordered
16	1	2	2	2026-03-18 16:11:51.184974+00	t	1	ordered
17	1	2	1	2026-03-18 16:47:47.421991+00	f	1	ordered
26	1	3	1	2026-03-21 12:49:12.123959+00	t	1	active
\.


--
-- Data for Name: parameters; Type: TABLE DATA; Schema: public; Owner: marketplace
--

COPY public.parameters (parameter_id, name, data_type) FROM stdin;
1	╨æ╤Ç╨╡╨╜╨┤	text
2	╨£╨╛╨┤╨╡╨╗╤î	text
3	╨ª╨▓╨╡╤é	text
4	╨£╨░╤é╨╡╤Ç╨╕╨░╨╗	text
5	╨á╨░╨╖╨╝╨╡╤Ç	text
6	╨ö╨╕╨░╨│╨╛╨╜╨░╨╗╤î	number
7	╨ƒ╨░╨╝╤Å╤é╤î	number
8	╨₧╨▒╤è╤æ╨╝	number
9	╨Æ╨╡╤ü	number
10	╨ƒ╨╛╨╗	text
11	╨í╨╡╨╖╨╛╨╜	text
12	╨Æ╨╛╨╖╤Ç╨░╤ü╤é	text
13	╨í╨╛╨▓╨╝╨╡╤ü╤é╨╕╨╝╨╛╤ü╤é╤î	text
14	╨É╤Ç╤é╨╕╨║╤â╨╗	text
15	╨ô╨░╤Ç╨░╨╜╤é╨╕╤Å	boolean
\.


--
-- Data for Name: category_parameters; Type: TABLE DATA; Schema: public; Owner: marketplace
--

COPY public.category_parameters (category_id, parameter_id, is_required) FROM stdin;
\.


--
-- Data for Name: cities; Type: TABLE DATA; Schema: public; Owner: marketplace
--

COPY public.cities (city_id, city_name) FROM stdin;
1	Moscow
\.


--
-- Data for Name: streets; Type: TABLE DATA; Schema: public; Owner: marketplace
--

COPY public.streets (street_id, city_id, street_name) FROM stdin;
\.


--
-- Data for Name: houses; Type: TABLE DATA; Schema: public; Owner: marketplace
--

COPY public.houses (house_id, street_id, house_number) FROM stdin;
\.


--
-- Data for Name: pickup_points; Type: TABLE DATA; Schema: public; Owner: marketplace
--

COPY public.pickup_points (pickup_point_id, city_id) FROM stdin;
2	1
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: marketplace
--

COPY public.orders (order_id, buyer_id, pickup_point_id, total_amount, created_at, status) FROM stdin;
1	5	2	1999.98	2026-03-03 14:47:04.6883+00	delivered
2	5	2	999.99	2026-03-13 16:28:51.749556+00	created
3	5	2	1099.98	2026-03-18 16:12:25.181054+00	created
4	5	2	99.99	2026-03-18 16:48:03.157125+00	delivered
\.


--
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: marketplace
--

COPY public.order_items (order_item_id, order_id, quantity, source_cart_item_id, price_snapshot) FROM stdin;
1	1	2	\N	999.99
2	2	1	\N	999.99
3	3	1	16	99.99
4	3	1	15	999.99
5	4	1	17	99.99
\.


--
-- Data for Name: payment_methods; Type: TABLE DATA; Schema: public; Owner: marketplace
--

COPY public.payment_methods (payment_method_id, name) FROM stdin;
1	card
2	cash
4	cash_on_pickup
\.


--
-- Data for Name: user_cards; Type: TABLE DATA; Schema: public; Owner: marketplace
--

COPY public.user_cards (card_id, user_id, card_number) FROM stdin;
5	5	**** **** **** 9633
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: marketplace
--

COPY public.payments (payment_id, order_id, payment_method_id, card_id, amount, created_at) FROM stdin;
1	1	1	\N	1999.98	2026-03-06 22:43:14.149846+00
2	4	1	5	99.99	2026-03-18 16:48:03.157125+00
\.


--
-- Data for Name: podcategories; Type: TABLE DATA; Schema: public; Owner: marketplace
--

COPY public.podcategories (podcategories_id, name) FROM stdin;
\.


--
-- Data for Name: product_images; Type: TABLE DATA; Schema: public; Owner: marketplace
--

COPY public.product_images (image_id, product_id, image_url, sort_order) FROM stdin;
1	3	https://image2url.com/r2/default/images/1773856134583-f6b5876b-783d-4c79-b657-b136c24b8096.png	1
2	3	https://image2url.com/r2/default/images/1773856389531-26fdd4e4-b3cc-484e-9c5b-d070e290152d.jpg	2
\.


--
-- Data for Name: product_parameter_values; Type: TABLE DATA; Schema: public; Owner: marketplace
--

COPY public.product_parameter_values (product_id, parameter_id, value_text) FROM stdin;
\.


--
-- Data for Name: reviews; Type: TABLE DATA; Schema: public; Owner: marketplace
--

COPY public.reviews (review_id, buyer_id, product_id, rating, comment, created_at) FROM stdin;
1	5	1	4	??????? ?????	2026-03-09 07:13:12.671837+00
2	5	2	5	╨▓╤ü╨╡ ╨╛╤é╨╗╨╕╤ç╨╜╨╛	2026-03-22 07:54:37.064636+00
\.


--
-- Data for Name: user_pickup_points; Type: TABLE DATA; Schema: public; Owner: marketplace
--

COPY public.user_pickup_points (user_pickup_id, user_id, pickup_point_id) FROM stdin;
2	5	2
\.


--
-- Name: cart_items_cart_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: marketplace
--

SELECT pg_catalog.setval('public.cart_items_cart_item_id_seq', 26, true);


--
-- Name: carts_cart_id_seq; Type: SEQUENCE SET; Schema: public; Owner: marketplace
--

SELECT pg_catalog.setval('public.carts_cart_id_seq', 1, true);


--
-- Name: categories_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: marketplace
--

SELECT pg_catalog.setval('public.categories_category_id_seq', 1, true);


--
-- Name: cities_city_id_seq; Type: SEQUENCE SET; Schema: public; Owner: marketplace
--

SELECT pg_catalog.setval('public.cities_city_id_seq', 1, true);


--
-- Name: houses_house_id_seq; Type: SEQUENCE SET; Schema: public; Owner: marketplace
--

SELECT pg_catalog.setval('public.houses_house_id_seq', 1, false);


--
-- Name: list_types_list_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: marketplace
--

SELECT pg_catalog.setval('public.list_types_list_type_id_seq', 3, true);


--
-- Name: order_items_order_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: marketplace
--

SELECT pg_catalog.setval('public.order_items_order_item_id_seq', 5, true);


--
-- Name: orders_order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: marketplace
--

SELECT pg_catalog.setval('public.orders_order_id_seq', 4, true);


--
-- Name: parameters_parameter_id_seq; Type: SEQUENCE SET; Schema: public; Owner: marketplace
--

SELECT pg_catalog.setval('public.parameters_parameter_id_seq', 15, true);


--
-- Name: payment_methods_payment_method_id_seq; Type: SEQUENCE SET; Schema: public; Owner: marketplace
--

SELECT pg_catalog.setval('public.payment_methods_payment_method_id_seq', 4, true);


--
-- Name: payments_payment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: marketplace
--

SELECT pg_catalog.setval('public.payments_payment_id_seq', 2, true);


--
-- Name: pickup_points_pickup_point_id_seq; Type: SEQUENCE SET; Schema: public; Owner: marketplace
--

SELECT pg_catalog.setval('public.pickup_points_pickup_point_id_seq', 2, true);


--
-- Name: podcategories_podcategories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: marketplace
--

SELECT pg_catalog.setval('public.podcategories_podcategories_id_seq', 1, false);


--
-- Name: product_images_image_id_seq; Type: SEQUENCE SET; Schema: public; Owner: marketplace
--

SELECT pg_catalog.setval('public.product_images_image_id_seq', 2, true);


--
-- Name: products_product_id_seq; Type: SEQUENCE SET; Schema: public; Owner: marketplace
--

SELECT pg_catalog.setval('public.products_product_id_seq', 3, true);


--
-- Name: reviews_review_id_seq; Type: SEQUENCE SET; Schema: public; Owner: marketplace
--

SELECT pg_catalog.setval('public.reviews_review_id_seq', 2, true);


--
-- Name: roles_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: marketplace
--

SELECT pg_catalog.setval('public.roles_role_id_seq', 3, true);


--
-- Name: sellers_seller_id_seq; Type: SEQUENCE SET; Schema: public; Owner: marketplace
--

SELECT pg_catalog.setval('public.sellers_seller_id_seq', 4, true);


--
-- Name: streets_street_id_seq; Type: SEQUENCE SET; Schema: public; Owner: marketplace
--

SELECT pg_catalog.setval('public.streets_street_id_seq', 1, false);


--
-- Name: user_cards_card_id_seq; Type: SEQUENCE SET; Schema: public; Owner: marketplace
--

SELECT pg_catalog.setval('public.user_cards_card_id_seq', 5, true);


--
-- Name: user_pickup_points_user_pickup_id_seq; Type: SEQUENCE SET; Schema: public; Owner: marketplace
--

SELECT pg_catalog.setval('public.user_pickup_points_user_pickup_id_seq', 2, true);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: marketplace
--

SELECT pg_catalog.setval('public.users_user_id_seq', 10, true);


--
-- PostgreSQL database dump complete
--

\unrestrict VKNypDIPMlkoeTcT4071RDDT4dA30QobwmcwHOR3bstTxJkZ0u4V4DcuoaIgChx

