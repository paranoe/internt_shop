--
-- PostgreSQL database dump
--

\restrict nbiBYHjbh8LjVTIVFrb0gbsEO3QJh42dqtHv55WHyVueKNyec1zmX4uAqTnH8PR

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: cart_items; Type: TABLE; Schema: public; Owner: marketplace
--

CREATE TABLE public.cart_items (
    cart_item_id bigint NOT NULL,
    cart_id bigint NOT NULL,
    product_id bigint NOT NULL,
    quantity integer NOT NULL,
    added_at timestamp with time zone DEFAULT now() NOT NULL,
    selected_for_purchase boolean DEFAULT true NOT NULL,
    list_type_id bigint NOT NULL,
    status text,
    CONSTRAINT cart_items_quantity_check CHECK ((quantity > 0))
);


ALTER TABLE public.cart_items OWNER TO marketplace;

--
-- Name: cart_items_cart_item_id_seq; Type: SEQUENCE; Schema: public; Owner: marketplace
--

CREATE SEQUENCE public.cart_items_cart_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cart_items_cart_item_id_seq OWNER TO marketplace;

--
-- Name: cart_items_cart_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: marketplace
--

ALTER SEQUENCE public.cart_items_cart_item_id_seq OWNED BY public.cart_items.cart_item_id;


--
-- Name: carts; Type: TABLE; Schema: public; Owner: marketplace
--

CREATE TABLE public.carts (
    cart_id bigint NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.carts OWNER TO marketplace;

--
-- Name: carts_cart_id_seq; Type: SEQUENCE; Schema: public; Owner: marketplace
--

CREATE SEQUENCE public.carts_cart_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.carts_cart_id_seq OWNER TO marketplace;

--
-- Name: carts_cart_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: marketplace
--

ALTER SEQUENCE public.carts_cart_id_seq OWNED BY public.carts.cart_id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: marketplace
--

CREATE TABLE public.categories (
    category_id bigint NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.categories OWNER TO marketplace;

--
-- Name: categories_category_id_seq; Type: SEQUENCE; Schema: public; Owner: marketplace
--

CREATE SEQUENCE public.categories_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.categories_category_id_seq OWNER TO marketplace;

--
-- Name: categories_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: marketplace
--

ALTER SEQUENCE public.categories_category_id_seq OWNED BY public.categories.category_id;


--
-- Name: category_parameters; Type: TABLE; Schema: public; Owner: marketplace
--

CREATE TABLE public.category_parameters (
    parameter_id bigint NOT NULL,
    is_required boolean DEFAULT false NOT NULL,
    podcategory_id bigint NOT NULL
);


ALTER TABLE public.category_parameters OWNER TO marketplace;

--
-- Name: cities; Type: TABLE; Schema: public; Owner: marketplace
--

CREATE TABLE public.cities (
    city_id bigint NOT NULL,
    city_name text NOT NULL
);


ALTER TABLE public.cities OWNER TO marketplace;

--
-- Name: cities_city_id_seq; Type: SEQUENCE; Schema: public; Owner: marketplace
--

CREATE SEQUENCE public.cities_city_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cities_city_id_seq OWNER TO marketplace;

--
-- Name: cities_city_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: marketplace
--

ALTER SEQUENCE public.cities_city_id_seq OWNED BY public.cities.city_id;


--
-- Name: houses; Type: TABLE; Schema: public; Owner: marketplace
--

CREATE TABLE public.houses (
    house_id bigint NOT NULL,
    street_id bigint NOT NULL,
    house_number text NOT NULL
);


ALTER TABLE public.houses OWNER TO marketplace;

--
-- Name: houses_house_id_seq; Type: SEQUENCE; Schema: public; Owner: marketplace
--

CREATE SEQUENCE public.houses_house_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.houses_house_id_seq OWNER TO marketplace;

--
-- Name: houses_house_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: marketplace
--

ALTER SEQUENCE public.houses_house_id_seq OWNED BY public.houses.house_id;


--
-- Name: list_types; Type: TABLE; Schema: public; Owner: marketplace
--

CREATE TABLE public.list_types (
    list_type_id bigint NOT NULL,
    list_type_name text NOT NULL
);


ALTER TABLE public.list_types OWNER TO marketplace;

--
-- Name: list_types_list_type_id_seq; Type: SEQUENCE; Schema: public; Owner: marketplace
--

CREATE SEQUENCE public.list_types_list_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.list_types_list_type_id_seq OWNER TO marketplace;

--
-- Name: list_types_list_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: marketplace
--

ALTER SEQUENCE public.list_types_list_type_id_seq OWNED BY public.list_types.list_type_id;


--
-- Name: measurement_units; Type: TABLE; Schema: public; Owner: marketplace
--

CREATE TABLE public.measurement_units (
    unit_id bigint NOT NULL,
    name text NOT NULL,
    short_name text NOT NULL
);


ALTER TABLE public.measurement_units OWNER TO marketplace;

--
-- Name: measurement_units_unit_id_seq; Type: SEQUENCE; Schema: public; Owner: marketplace
--

CREATE SEQUENCE public.measurement_units_unit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.measurement_units_unit_id_seq OWNER TO marketplace;

--
-- Name: measurement_units_unit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: marketplace
--

ALTER SEQUENCE public.measurement_units_unit_id_seq OWNED BY public.measurement_units.unit_id;


--
-- Name: order_items; Type: TABLE; Schema: public; Owner: marketplace
--

CREATE TABLE public.order_items (
    order_item_id bigint NOT NULL,
    order_id bigint NOT NULL,
    quantity integer NOT NULL,
    source_cart_item_id bigint,
    price_snapshot numeric(12,2) NOT NULL,
    CONSTRAINT order_items_price_snapshot_check CHECK ((price_snapshot >= (0)::numeric)),
    CONSTRAINT order_items_quantity_check CHECK ((quantity > 0))
);


ALTER TABLE public.order_items OWNER TO marketplace;

--
-- Name: order_items_order_item_id_seq; Type: SEQUENCE; Schema: public; Owner: marketplace
--

CREATE SEQUENCE public.order_items_order_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_items_order_item_id_seq OWNER TO marketplace;

--
-- Name: order_items_order_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: marketplace
--

ALTER SEQUENCE public.order_items_order_item_id_seq OWNED BY public.order_items.order_item_id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: marketplace
--

CREATE TABLE public.orders (
    order_id bigint NOT NULL,
    buyer_id bigint NOT NULL,
    pickup_point_id bigint NOT NULL,
    total_amount numeric(12,2) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    status text DEFAULT 'created'::text NOT NULL,
    CONSTRAINT orders_total_amount_check CHECK ((total_amount >= (0)::numeric))
);


ALTER TABLE public.orders OWNER TO marketplace;

--
-- Name: orders_order_id_seq; Type: SEQUENCE; Schema: public; Owner: marketplace
--

CREATE SEQUENCE public.orders_order_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.orders_order_id_seq OWNER TO marketplace;

--
-- Name: orders_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: marketplace
--

ALTER SEQUENCE public.orders_order_id_seq OWNED BY public.orders.order_id;


--
-- Name: parameters; Type: TABLE; Schema: public; Owner: marketplace
--

CREATE TABLE public.parameters (
    parameter_id bigint NOT NULL,
    name text NOT NULL,
    data_type text NOT NULL,
    unit_id bigint
);


ALTER TABLE public.parameters OWNER TO marketplace;

--
-- Name: parameters_parameter_id_seq; Type: SEQUENCE; Schema: public; Owner: marketplace
--

CREATE SEQUENCE public.parameters_parameter_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.parameters_parameter_id_seq OWNER TO marketplace;

--
-- Name: parameters_parameter_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: marketplace
--

ALTER SEQUENCE public.parameters_parameter_id_seq OWNED BY public.parameters.parameter_id;


--
-- Name: payment_methods; Type: TABLE; Schema: public; Owner: marketplace
--

CREATE TABLE public.payment_methods (
    payment_method_id bigint NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.payment_methods OWNER TO marketplace;

--
-- Name: payment_methods_payment_method_id_seq; Type: SEQUENCE; Schema: public; Owner: marketplace
--

CREATE SEQUENCE public.payment_methods_payment_method_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payment_methods_payment_method_id_seq OWNER TO marketplace;

--
-- Name: payment_methods_payment_method_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: marketplace
--

ALTER SEQUENCE public.payment_methods_payment_method_id_seq OWNED BY public.payment_methods.payment_method_id;


--
-- Name: payments; Type: TABLE; Schema: public; Owner: marketplace
--

CREATE TABLE public.payments (
    payment_id bigint NOT NULL,
    order_id bigint NOT NULL,
    payment_method_id bigint NOT NULL,
    card_id bigint,
    amount numeric(12,2) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT payments_amount_check CHECK ((amount >= (0)::numeric))
);


ALTER TABLE public.payments OWNER TO marketplace;

--
-- Name: payments_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: marketplace
--

CREATE SEQUENCE public.payments_payment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payments_payment_id_seq OWNER TO marketplace;

--
-- Name: payments_payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: marketplace
--

ALTER SEQUENCE public.payments_payment_id_seq OWNED BY public.payments.payment_id;


--
-- Name: pickup_points; Type: TABLE; Schema: public; Owner: marketplace
--

CREATE TABLE public.pickup_points (
    pickup_point_id bigint NOT NULL,
    city_id bigint NOT NULL
);


ALTER TABLE public.pickup_points OWNER TO marketplace;

--
-- Name: pickup_points_pickup_point_id_seq; Type: SEQUENCE; Schema: public; Owner: marketplace
--

CREATE SEQUENCE public.pickup_points_pickup_point_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pickup_points_pickup_point_id_seq OWNER TO marketplace;

--
-- Name: pickup_points_pickup_point_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: marketplace
--

ALTER SEQUENCE public.pickup_points_pickup_point_id_seq OWNED BY public.pickup_points.pickup_point_id;


--
-- Name: podcategories; Type: TABLE; Schema: public; Owner: marketplace
--

CREATE TABLE public.podcategories (
    podcategories_id bigint NOT NULL,
    name text NOT NULL,
    category_id bigint
);


ALTER TABLE public.podcategories OWNER TO marketplace;

--
-- Name: podcategories_podcategories_id_seq; Type: SEQUENCE; Schema: public; Owner: marketplace
--

CREATE SEQUENCE public.podcategories_podcategories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.podcategories_podcategories_id_seq OWNER TO marketplace;

--
-- Name: podcategories_podcategories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: marketplace
--

ALTER SEQUENCE public.podcategories_podcategories_id_seq OWNED BY public.podcategories.podcategories_id;


--
-- Name: product_images; Type: TABLE; Schema: public; Owner: marketplace
--

CREATE TABLE public.product_images (
    image_id bigint NOT NULL,
    product_id bigint NOT NULL,
    image_url text NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.product_images OWNER TO marketplace;

--
-- Name: product_images_image_id_seq; Type: SEQUENCE; Schema: public; Owner: marketplace
--

CREATE SEQUENCE public.product_images_image_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.product_images_image_id_seq OWNER TO marketplace;

--
-- Name: product_images_image_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: marketplace
--

ALTER SEQUENCE public.product_images_image_id_seq OWNED BY public.product_images.image_id;


--
-- Name: product_parameter_values; Type: TABLE; Schema: public; Owner: marketplace
--

CREATE TABLE public.product_parameter_values (
    product_id bigint NOT NULL,
    parameter_id bigint NOT NULL,
    value_text text NOT NULL,
    unit_id bigint
);


ALTER TABLE public.product_parameter_values OWNER TO marketplace;

--
-- Name: products; Type: TABLE; Schema: public; Owner: marketplace
--

CREATE TABLE public.products (
    product_id bigint NOT NULL,
    category_id bigint NOT NULL,
    seller_id bigint NOT NULL,
    name text NOT NULL,
    description text,
    price numeric(12,2) NOT NULL,
    quantity integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    currency text DEFAULT 'RUB'::text NOT NULL,
    subcategory_id bigint,
    CONSTRAINT products_price_check CHECK ((price >= (0)::numeric)),
    CONSTRAINT products_quantity_check CHECK ((quantity >= 0))
);


ALTER TABLE public.products OWNER TO marketplace;

--
-- Name: products_product_id_seq; Type: SEQUENCE; Schema: public; Owner: marketplace
--

CREATE SEQUENCE public.products_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.products_product_id_seq OWNER TO marketplace;

--
-- Name: products_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: marketplace
--

ALTER SEQUENCE public.products_product_id_seq OWNED BY public.products.product_id;


--
-- Name: reviews; Type: TABLE; Schema: public; Owner: marketplace
--

CREATE TABLE public.reviews (
    review_id bigint NOT NULL,
    buyer_id bigint NOT NULL,
    product_id bigint NOT NULL,
    rating smallint NOT NULL,
    comment text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    moderation_status text DEFAULT 'approved'::text NOT NULL,
    CONSTRAINT reviews_moderation_status_check CHECK ((moderation_status = ANY (ARRAY['pending'::text, 'approved'::text, 'rejected'::text]))),
    CONSTRAINT reviews_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


ALTER TABLE public.reviews OWNER TO marketplace;

--
-- Name: reviews_review_id_seq; Type: SEQUENCE; Schema: public; Owner: marketplace
--

CREATE SEQUENCE public.reviews_review_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.reviews_review_id_seq OWNER TO marketplace;

--
-- Name: reviews_review_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: marketplace
--

ALTER SEQUENCE public.reviews_review_id_seq OWNED BY public.reviews.review_id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: marketplace
--

CREATE TABLE public.roles (
    role_id bigint NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.roles OWNER TO marketplace;

--
-- Name: roles_role_id_seq; Type: SEQUENCE; Schema: public; Owner: marketplace
--

CREATE SEQUENCE public.roles_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roles_role_id_seq OWNER TO marketplace;

--
-- Name: roles_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: marketplace
--

ALTER SEQUENCE public.roles_role_id_seq OWNED BY public.roles.role_id;


--
-- Name: sellers; Type: TABLE; Schema: public; Owner: marketplace
--

CREATE TABLE public.sellers (
    seller_id bigint NOT NULL,
    shop_name text NOT NULL,
    description text,
    inn text,
    unp text,
    user_id bigint
);


ALTER TABLE public.sellers OWNER TO marketplace;

--
-- Name: sellers_seller_id_seq; Type: SEQUENCE; Schema: public; Owner: marketplace
--

CREATE SEQUENCE public.sellers_seller_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sellers_seller_id_seq OWNER TO marketplace;

--
-- Name: sellers_seller_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: marketplace
--

ALTER SEQUENCE public.sellers_seller_id_seq OWNED BY public.sellers.seller_id;


--
-- Name: streets; Type: TABLE; Schema: public; Owner: marketplace
--

CREATE TABLE public.streets (
    street_id bigint NOT NULL,
    city_id bigint NOT NULL,
    street_name text NOT NULL
);


ALTER TABLE public.streets OWNER TO marketplace;

--
-- Name: streets_street_id_seq; Type: SEQUENCE; Schema: public; Owner: marketplace
--

CREATE SEQUENCE public.streets_street_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.streets_street_id_seq OWNER TO marketplace;

--
-- Name: streets_street_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: marketplace
--

ALTER SEQUENCE public.streets_street_id_seq OWNED BY public.streets.street_id;


--
-- Name: user_cards; Type: TABLE; Schema: public; Owner: marketplace
--

CREATE TABLE public.user_cards (
    card_id bigint NOT NULL,
    user_id bigint NOT NULL,
    card_number text NOT NULL
);


ALTER TABLE public.user_cards OWNER TO marketplace;

--
-- Name: user_cards_card_id_seq; Type: SEQUENCE; Schema: public; Owner: marketplace
--

CREATE SEQUENCE public.user_cards_card_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_cards_card_id_seq OWNER TO marketplace;

--
-- Name: user_cards_card_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: marketplace
--

ALTER SEQUENCE public.user_cards_card_id_seq OWNED BY public.user_cards.card_id;


--
-- Name: user_pickup_points; Type: TABLE; Schema: public; Owner: marketplace
--

CREATE TABLE public.user_pickup_points (
    user_pickup_id bigint NOT NULL,
    user_id bigint NOT NULL,
    pickup_point_id bigint NOT NULL
);


ALTER TABLE public.user_pickup_points OWNER TO marketplace;

--
-- Name: user_pickup_points_user_pickup_id_seq; Type: SEQUENCE; Schema: public; Owner: marketplace
--

CREATE SEQUENCE public.user_pickup_points_user_pickup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_pickup_points_user_pickup_id_seq OWNER TO marketplace;

--
-- Name: user_pickup_points_user_pickup_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: marketplace
--

ALTER SEQUENCE public.user_pickup_points_user_pickup_id_seq OWNED BY public.user_pickup_points.user_pickup_id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: marketplace
--

CREATE TABLE public.users (
    user_id bigint NOT NULL,
    role_id bigint NOT NULL,
    first_name text,
    last_name text,
    patronymic text,
    phone text,
    email text,
    password_hash text NOT NULL,
    gender text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    is_blocked boolean DEFAULT false NOT NULL
);


ALTER TABLE public.users OWNER TO marketplace;

--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: marketplace
--

CREATE SEQUENCE public.users_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_user_id_seq OWNER TO marketplace;

--
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: marketplace
--

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;


--
-- Name: cart_items cart_item_id; Type: DEFAULT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.cart_items ALTER COLUMN cart_item_id SET DEFAULT nextval('public.cart_items_cart_item_id_seq'::regclass);


--
-- Name: carts cart_id; Type: DEFAULT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.carts ALTER COLUMN cart_id SET DEFAULT nextval('public.carts_cart_id_seq'::regclass);


--
-- Name: categories category_id; Type: DEFAULT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.categories ALTER COLUMN category_id SET DEFAULT nextval('public.categories_category_id_seq'::regclass);


--
-- Name: cities city_id; Type: DEFAULT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.cities ALTER COLUMN city_id SET DEFAULT nextval('public.cities_city_id_seq'::regclass);


--
-- Name: houses house_id; Type: DEFAULT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.houses ALTER COLUMN house_id SET DEFAULT nextval('public.houses_house_id_seq'::regclass);


--
-- Name: list_types list_type_id; Type: DEFAULT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.list_types ALTER COLUMN list_type_id SET DEFAULT nextval('public.list_types_list_type_id_seq'::regclass);


--
-- Name: measurement_units unit_id; Type: DEFAULT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.measurement_units ALTER COLUMN unit_id SET DEFAULT nextval('public.measurement_units_unit_id_seq'::regclass);


--
-- Name: order_items order_item_id; Type: DEFAULT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.order_items ALTER COLUMN order_item_id SET DEFAULT nextval('public.order_items_order_item_id_seq'::regclass);


--
-- Name: orders order_id; Type: DEFAULT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.orders ALTER COLUMN order_id SET DEFAULT nextval('public.orders_order_id_seq'::regclass);


--
-- Name: parameters parameter_id; Type: DEFAULT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.parameters ALTER COLUMN parameter_id SET DEFAULT nextval('public.parameters_parameter_id_seq'::regclass);


--
-- Name: payment_methods payment_method_id; Type: DEFAULT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.payment_methods ALTER COLUMN payment_method_id SET DEFAULT nextval('public.payment_methods_payment_method_id_seq'::regclass);


--
-- Name: payments payment_id; Type: DEFAULT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.payments ALTER COLUMN payment_id SET DEFAULT nextval('public.payments_payment_id_seq'::regclass);


--
-- Name: pickup_points pickup_point_id; Type: DEFAULT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.pickup_points ALTER COLUMN pickup_point_id SET DEFAULT nextval('public.pickup_points_pickup_point_id_seq'::regclass);


--
-- Name: podcategories podcategories_id; Type: DEFAULT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.podcategories ALTER COLUMN podcategories_id SET DEFAULT nextval('public.podcategories_podcategories_id_seq'::regclass);


--
-- Name: product_images image_id; Type: DEFAULT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.product_images ALTER COLUMN image_id SET DEFAULT nextval('public.product_images_image_id_seq'::regclass);


--
-- Name: products product_id; Type: DEFAULT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.products ALTER COLUMN product_id SET DEFAULT nextval('public.products_product_id_seq'::regclass);


--
-- Name: reviews review_id; Type: DEFAULT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.reviews ALTER COLUMN review_id SET DEFAULT nextval('public.reviews_review_id_seq'::regclass);


--
-- Name: roles role_id; Type: DEFAULT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.roles ALTER COLUMN role_id SET DEFAULT nextval('public.roles_role_id_seq'::regclass);


--
-- Name: sellers seller_id; Type: DEFAULT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.sellers ALTER COLUMN seller_id SET DEFAULT nextval('public.sellers_seller_id_seq'::regclass);


--
-- Name: streets street_id; Type: DEFAULT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.streets ALTER COLUMN street_id SET DEFAULT nextval('public.streets_street_id_seq'::regclass);


--
-- Name: user_cards card_id; Type: DEFAULT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.user_cards ALTER COLUMN card_id SET DEFAULT nextval('public.user_cards_card_id_seq'::regclass);


--
-- Name: user_pickup_points user_pickup_id; Type: DEFAULT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.user_pickup_points ALTER COLUMN user_pickup_id SET DEFAULT nextval('public.user_pickup_points_user_pickup_id_seq'::regclass);


--
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


--
-- Name: cart_items cart_items_pkey; Type: CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_pkey PRIMARY KEY (cart_item_id);


--
-- Name: carts carts_pkey; Type: CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.carts
    ADD CONSTRAINT carts_pkey PRIMARY KEY (cart_id);


--
-- Name: categories categories_name_key; Type: CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_name_key UNIQUE (name);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (category_id);


--
-- Name: category_parameters category_parameters_pkey; Type: CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.category_parameters
    ADD CONSTRAINT category_parameters_pkey PRIMARY KEY (podcategory_id, parameter_id);


--
-- Name: cities cities_city_name_key; Type: CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT cities_city_name_key UNIQUE (city_name);


--
-- Name: cities cities_pkey; Type: CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (city_id);


--
-- Name: houses houses_pkey; Type: CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.houses
    ADD CONSTRAINT houses_pkey PRIMARY KEY (house_id);


--
-- Name: list_types list_types_list_type_name_key; Type: CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.list_types
    ADD CONSTRAINT list_types_list_type_name_key UNIQUE (list_type_name);


--
-- Name: list_types list_types_pkey; Type: CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.list_types
    ADD CONSTRAINT list_types_pkey PRIMARY KEY (list_type_id);


--
-- Name: measurement_units measurement_units_name_key; Type: CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.measurement_units
    ADD CONSTRAINT measurement_units_name_key UNIQUE (name);


--
-- Name: measurement_units measurement_units_pkey; Type: CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.measurement_units
    ADD CONSTRAINT measurement_units_pkey PRIMARY KEY (unit_id);


--
-- Name: measurement_units measurement_units_short_name_key; Type: CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.measurement_units
    ADD CONSTRAINT measurement_units_short_name_key UNIQUE (short_name);


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (order_item_id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);


--
-- Name: parameters parameters_name_key; Type: CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.parameters
    ADD CONSTRAINT parameters_name_key UNIQUE (name);


--
-- Name: parameters parameters_pkey; Type: CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.parameters
    ADD CONSTRAINT parameters_pkey PRIMARY KEY (parameter_id);


--
-- Name: payment_methods payment_methods_name_key; Type: CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.payment_methods
    ADD CONSTRAINT payment_methods_name_key UNIQUE (name);


--
-- Name: payment_methods payment_methods_pkey; Type: CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.payment_methods
    ADD CONSTRAINT payment_methods_pkey PRIMARY KEY (payment_method_id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (payment_id);


--
-- Name: pickup_points pickup_points_pkey; Type: CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.pickup_points
    ADD CONSTRAINT pickup_points_pkey PRIMARY KEY (pickup_point_id);


--
-- Name: podcategories podcategories_name_key; Type: CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.podcategories
    ADD CONSTRAINT podcategories_name_key UNIQUE (name);


--
-- Name: podcategories podcategories_pkey; Type: CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.podcategories
    ADD CONSTRAINT podcategories_pkey PRIMARY KEY (podcategories_id);


--
-- Name: product_images product_images_pkey; Type: CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.product_images
    ADD CONSTRAINT product_images_pkey PRIMARY KEY (image_id);


--
-- Name: product_parameter_values product_parameter_values_pkey; Type: CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.product_parameter_values
    ADD CONSTRAINT product_parameter_values_pkey PRIMARY KEY (product_id, parameter_id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (product_id);


--
-- Name: reviews reviews_buyer_id_product_id_key; Type: CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_buyer_id_product_id_key UNIQUE (buyer_id, product_id);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (review_id);


--
-- Name: roles roles_name_key; Type: CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key UNIQUE (name);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (role_id);


--
-- Name: sellers sellers_inn_key; Type: CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.sellers
    ADD CONSTRAINT sellers_inn_key UNIQUE (inn);


--
-- Name: sellers sellers_pkey; Type: CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.sellers
    ADD CONSTRAINT sellers_pkey PRIMARY KEY (seller_id);


--
-- Name: sellers sellers_user_id_key; Type: CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.sellers
    ADD CONSTRAINT sellers_user_id_key UNIQUE (user_id);


--
-- Name: streets streets_pkey; Type: CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.streets
    ADD CONSTRAINT streets_pkey PRIMARY KEY (street_id);


--
-- Name: user_cards user_cards_pkey; Type: CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.user_cards
    ADD CONSTRAINT user_cards_pkey PRIMARY KEY (card_id);


--
-- Name: user_pickup_points user_pickup_points_pkey; Type: CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.user_pickup_points
    ADD CONSTRAINT user_pickup_points_pkey PRIMARY KEY (user_pickup_id);


--
-- Name: user_pickup_points user_pickup_points_user_id_pickup_point_id_key; Type: CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.user_pickup_points
    ADD CONSTRAINT user_pickup_points_user_id_pickup_point_id_key UNIQUE (user_id, pickup_point_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: idx_cart_items_cart_id; Type: INDEX; Schema: public; Owner: marketplace
--

CREATE INDEX idx_cart_items_cart_id ON public.cart_items USING btree (cart_id);


--
-- Name: idx_cart_items_list_type_id; Type: INDEX; Schema: public; Owner: marketplace
--

CREATE INDEX idx_cart_items_list_type_id ON public.cart_items USING btree (list_type_id);


--
-- Name: idx_cart_items_product_id; Type: INDEX; Schema: public; Owner: marketplace
--

CREATE INDEX idx_cart_items_product_id ON public.cart_items USING btree (product_id);


--
-- Name: idx_carts_user_id; Type: INDEX; Schema: public; Owner: marketplace
--

CREATE INDEX idx_carts_user_id ON public.carts USING btree (user_id);


--
-- Name: idx_category_parameters_podcategory_id; Type: INDEX; Schema: public; Owner: marketplace
--

CREATE INDEX idx_category_parameters_podcategory_id ON public.category_parameters USING btree (podcategory_id);


--
-- Name: idx_houses_street_id; Type: INDEX; Schema: public; Owner: marketplace
--

CREATE INDEX idx_houses_street_id ON public.houses USING btree (street_id);


--
-- Name: idx_order_items_order_id; Type: INDEX; Schema: public; Owner: marketplace
--

CREATE INDEX idx_order_items_order_id ON public.order_items USING btree (order_id);


--
-- Name: idx_orders_buyer_id; Type: INDEX; Schema: public; Owner: marketplace
--

CREATE INDEX idx_orders_buyer_id ON public.orders USING btree (buyer_id);


--
-- Name: idx_orders_created_at; Type: INDEX; Schema: public; Owner: marketplace
--

CREATE INDEX idx_orders_created_at ON public.orders USING btree (created_at);


--
-- Name: idx_payments_order_id; Type: INDEX; Schema: public; Owner: marketplace
--

CREATE INDEX idx_payments_order_id ON public.payments USING btree (order_id);


--
-- Name: idx_pickup_points_city_id; Type: INDEX; Schema: public; Owner: marketplace
--

CREATE INDEX idx_pickup_points_city_id ON public.pickup_points USING btree (city_id);


--
-- Name: idx_podcategories_category_id; Type: INDEX; Schema: public; Owner: marketplace
--

CREATE INDEX idx_podcategories_category_id ON public.podcategories USING btree (category_id);


--
-- Name: idx_product_images_product_id; Type: INDEX; Schema: public; Owner: marketplace
--

CREATE INDEX idx_product_images_product_id ON public.product_images USING btree (product_id);


--
-- Name: idx_products_category_id; Type: INDEX; Schema: public; Owner: marketplace
--

CREATE INDEX idx_products_category_id ON public.products USING btree (category_id);


--
-- Name: idx_products_seller_id; Type: INDEX; Schema: public; Owner: marketplace
--

CREATE INDEX idx_products_seller_id ON public.products USING btree (seller_id);


--
-- Name: idx_products_subcategory_id; Type: INDEX; Schema: public; Owner: marketplace
--

CREATE INDEX idx_products_subcategory_id ON public.products USING btree (subcategory_id);


--
-- Name: idx_reviews_product_id; Type: INDEX; Schema: public; Owner: marketplace
--

CREATE INDEX idx_reviews_product_id ON public.reviews USING btree (product_id);


--
-- Name: idx_streets_city_id; Type: INDEX; Schema: public; Owner: marketplace
--

CREATE INDEX idx_streets_city_id ON public.streets USING btree (city_id);


--
-- Name: idx_user_cards_user_id; Type: INDEX; Schema: public; Owner: marketplace
--

CREATE INDEX idx_user_cards_user_id ON public.user_cards USING btree (user_id);


--
-- Name: idx_user_pickup_points_user_id; Type: INDEX; Schema: public; Owner: marketplace
--

CREATE INDEX idx_user_pickup_points_user_id ON public.user_pickup_points USING btree (user_id);


--
-- Name: idx_users_role_id; Type: INDEX; Schema: public; Owner: marketplace
--

CREATE INDEX idx_users_role_id ON public.users USING btree (role_id);


--
-- Name: cart_items cart_items_cart_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_cart_id_fkey FOREIGN KEY (cart_id) REFERENCES public.carts(cart_id) ON DELETE CASCADE;


--
-- Name: cart_items cart_items_list_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_list_type_id_fkey FOREIGN KEY (list_type_id) REFERENCES public.list_types(list_type_id) ON DELETE RESTRICT;


--
-- Name: cart_items cart_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id) ON DELETE RESTRICT;


--
-- Name: carts carts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.carts
    ADD CONSTRAINT carts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: category_parameters category_parameters_parameter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.category_parameters
    ADD CONSTRAINT category_parameters_parameter_id_fkey FOREIGN KEY (parameter_id) REFERENCES public.parameters(parameter_id) ON DELETE CASCADE;


--
-- Name: category_parameters category_parameters_podcategory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.category_parameters
    ADD CONSTRAINT category_parameters_podcategory_id_fkey FOREIGN KEY (podcategory_id) REFERENCES public.podcategories(podcategories_id) ON DELETE CASCADE;


--
-- Name: houses houses_street_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.houses
    ADD CONSTRAINT houses_street_id_fkey FOREIGN KEY (street_id) REFERENCES public.streets(street_id) ON DELETE CASCADE;


--
-- Name: order_items order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(order_id) ON DELETE CASCADE;


--
-- Name: order_items order_items_source_cart_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_source_cart_item_id_fkey FOREIGN KEY (source_cart_item_id) REFERENCES public.cart_items(cart_item_id) ON DELETE SET NULL;


--
-- Name: orders orders_buyer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_buyer_id_fkey FOREIGN KEY (buyer_id) REFERENCES public.users(user_id) ON DELETE RESTRICT;


--
-- Name: orders orders_pickup_point_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pickup_point_id_fkey FOREIGN KEY (pickup_point_id) REFERENCES public.pickup_points(pickup_point_id) ON DELETE RESTRICT;


--
-- Name: parameters parameters_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.parameters
    ADD CONSTRAINT parameters_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.measurement_units(unit_id) ON DELETE SET NULL;


--
-- Name: payments payments_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_card_id_fkey FOREIGN KEY (card_id) REFERENCES public.user_cards(card_id) ON DELETE SET NULL;


--
-- Name: payments payments_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(order_id) ON DELETE CASCADE;


--
-- Name: payments payments_payment_method_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_payment_method_id_fkey FOREIGN KEY (payment_method_id) REFERENCES public.payment_methods(payment_method_id) ON DELETE RESTRICT;


--
-- Name: pickup_points pickup_points_city_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.pickup_points
    ADD CONSTRAINT pickup_points_city_id_fkey FOREIGN KEY (city_id) REFERENCES public.cities(city_id) ON DELETE RESTRICT;


--
-- Name: podcategories podcategories_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.podcategories
    ADD CONSTRAINT podcategories_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(category_id) ON DELETE CASCADE;


--
-- Name: product_images product_images_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.product_images
    ADD CONSTRAINT product_images_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id) ON DELETE CASCADE;


--
-- Name: product_parameter_values product_parameter_values_parameter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.product_parameter_values
    ADD CONSTRAINT product_parameter_values_parameter_id_fkey FOREIGN KEY (parameter_id) REFERENCES public.parameters(parameter_id) ON DELETE CASCADE;


--
-- Name: product_parameter_values product_parameter_values_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.product_parameter_values
    ADD CONSTRAINT product_parameter_values_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id) ON DELETE CASCADE;


--
-- Name: product_parameter_values product_parameter_values_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.product_parameter_values
    ADD CONSTRAINT product_parameter_values_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.measurement_units(unit_id) ON DELETE SET NULL;


--
-- Name: products products_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(category_id) ON DELETE RESTRICT;


--
-- Name: products products_seller_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_seller_id_fkey FOREIGN KEY (seller_id) REFERENCES public.sellers(seller_id) ON DELETE RESTRICT;


--
-- Name: products products_subcategory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_subcategory_id_fkey FOREIGN KEY (subcategory_id) REFERENCES public.podcategories(podcategories_id) ON DELETE SET NULL;


--
-- Name: reviews reviews_buyer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_buyer_id_fkey FOREIGN KEY (buyer_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: reviews reviews_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id) ON DELETE CASCADE;


--
-- Name: sellers sellers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.sellers
    ADD CONSTRAINT sellers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE RESTRICT;


--
-- Name: streets streets_city_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.streets
    ADD CONSTRAINT streets_city_id_fkey FOREIGN KEY (city_id) REFERENCES public.cities(city_id) ON DELETE CASCADE;


--
-- Name: user_cards user_cards_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.user_cards
    ADD CONSTRAINT user_cards_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: user_pickup_points user_pickup_points_pickup_point_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.user_pickup_points
    ADD CONSTRAINT user_pickup_points_pickup_point_id_fkey FOREIGN KEY (pickup_point_id) REFERENCES public.pickup_points(pickup_point_id) ON DELETE RESTRICT;


--
-- Name: user_pickup_points user_pickup_points_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.user_pickup_points
    ADD CONSTRAINT user_pickup_points_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: users users_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: marketplace
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(role_id) ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

\unrestrict nbiBYHjbh8LjVTIVFrb0gbsEO3QJh42dqtHv55WHyVueKNyec1zmX4uAqTnH8PR

