--
-- PostgreSQL database dump
--

\restrict gp2UWmfwPknSXCaU1iXlE1qZ2uxhTBUHpbBMfqvleOsBHucjD8ziL0qVIJC0drH

-- Dumped from database version 16.14
-- Dumped by pg_dump version 16.14

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

ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_role_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_pickup_points DROP CONSTRAINT IF EXISTS user_pickup_points_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_pickup_points DROP CONSTRAINT IF EXISTS user_pickup_points_pickup_point_id_fkey;
ALTER TABLE IF EXISTS ONLY public.user_cards DROP CONSTRAINT IF EXISTS user_cards_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.streets DROP CONSTRAINT IF EXISTS streets_city_id_fkey;
ALTER TABLE IF EXISTS ONLY public.sellers DROP CONSTRAINT IF EXISTS sellers_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.reviews DROP CONSTRAINT IF EXISTS reviews_product_id_fkey;
ALTER TABLE IF EXISTS ONLY public.reviews DROP CONSTRAINT IF EXISTS reviews_buyer_id_fkey;
ALTER TABLE IF EXISTS ONLY public.products DROP CONSTRAINT IF EXISTS products_subcategory_id_fkey;
ALTER TABLE IF EXISTS ONLY public.products DROP CONSTRAINT IF EXISTS products_seller_id_fkey;
ALTER TABLE IF EXISTS ONLY public.product_parameter_values DROP CONSTRAINT IF EXISTS product_parameter_values_unit_id_fkey;
ALTER TABLE IF EXISTS ONLY public.product_parameter_values DROP CONSTRAINT IF EXISTS product_parameter_values_product_id_fkey;
ALTER TABLE IF EXISTS ONLY public.product_parameter_values DROP CONSTRAINT IF EXISTS product_parameter_values_parameter_id_fkey;
ALTER TABLE IF EXISTS ONLY public.product_images DROP CONSTRAINT IF EXISTS product_images_product_id_fkey;
ALTER TABLE IF EXISTS ONLY public.podcategories DROP CONSTRAINT IF EXISTS podcategories_category_id_fkey;
ALTER TABLE IF EXISTS ONLY public.pickup_points DROP CONSTRAINT IF EXISTS pickup_points_city_id_fkey;
ALTER TABLE IF EXISTS ONLY public.payments DROP CONSTRAINT IF EXISTS payments_payment_method_id_fkey;
ALTER TABLE IF EXISTS ONLY public.payments DROP CONSTRAINT IF EXISTS payments_order_id_fkey;
ALTER TABLE IF EXISTS ONLY public.payments DROP CONSTRAINT IF EXISTS payments_card_id_fkey;
ALTER TABLE IF EXISTS ONLY public.parameters DROP CONSTRAINT IF EXISTS parameters_unit_id_fkey;
ALTER TABLE IF EXISTS ONLY public.orders DROP CONSTRAINT IF EXISTS orders_pickup_point_id_fkey;
ALTER TABLE IF EXISTS ONLY public.orders DROP CONSTRAINT IF EXISTS orders_buyer_id_fkey;
ALTER TABLE IF EXISTS ONLY public.order_items DROP CONSTRAINT IF EXISTS order_items_source_cart_item_id_fkey;
ALTER TABLE IF EXISTS ONLY public.order_items DROP CONSTRAINT IF EXISTS order_items_order_id_fkey;
ALTER TABLE IF EXISTS ONLY public.houses DROP CONSTRAINT IF EXISTS houses_street_id_fkey;
ALTER TABLE IF EXISTS ONLY public.products DROP CONSTRAINT IF EXISTS fk_products_podcategory;
ALTER TABLE IF EXISTS ONLY public.category_parameters DROP CONSTRAINT IF EXISTS category_parameters_podcategory_id_fkey;
ALTER TABLE IF EXISTS ONLY public.category_parameters DROP CONSTRAINT IF EXISTS category_parameters_parameter_id_fkey;
ALTER TABLE IF EXISTS ONLY public.carts DROP CONSTRAINT IF EXISTS carts_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.cart_items DROP CONSTRAINT IF EXISTS cart_items_product_id_fkey;
ALTER TABLE IF EXISTS ONLY public.cart_items DROP CONSTRAINT IF EXISTS cart_items_list_type_id_fkey;
ALTER TABLE IF EXISTS ONLY public.cart_items DROP CONSTRAINT IF EXISTS cart_items_cart_id_fkey;
DROP INDEX IF EXISTS public.idx_users_role_id;
DROP INDEX IF EXISTS public.idx_user_pickup_points_user_id;
DROP INDEX IF EXISTS public.idx_user_cards_user_id;
DROP INDEX IF EXISTS public.idx_streets_city_id;
DROP INDEX IF EXISTS public.idx_reviews_product_id;
DROP INDEX IF EXISTS public.idx_products_subcategory_id;
DROP INDEX IF EXISTS public.idx_products_seller_id;
DROP INDEX IF EXISTS public.idx_product_images_product_id;
DROP INDEX IF EXISTS public.idx_podcategories_category_id;
DROP INDEX IF EXISTS public.idx_pickup_points_city_id;
DROP INDEX IF EXISTS public.idx_payments_order_id;
DROP INDEX IF EXISTS public.idx_orders_created_at;
DROP INDEX IF EXISTS public.idx_orders_buyer_id;
DROP INDEX IF EXISTS public.idx_order_items_order_id;
DROP INDEX IF EXISTS public.idx_houses_street_id;
DROP INDEX IF EXISTS public.idx_category_parameters_podcategory_id;
DROP INDEX IF EXISTS public.idx_carts_user_id;
DROP INDEX IF EXISTS public.idx_cart_items_product_id;
DROP INDEX IF EXISTS public.idx_cart_items_list_type_id;
DROP INDEX IF EXISTS public.idx_cart_items_cart_id;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_phone_key;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_email_key;
ALTER TABLE IF EXISTS ONLY public.user_pickup_points DROP CONSTRAINT IF EXISTS user_pickup_points_user_id_pickup_point_id_key;
ALTER TABLE IF EXISTS ONLY public.user_pickup_points DROP CONSTRAINT IF EXISTS user_pickup_points_pkey;
ALTER TABLE IF EXISTS ONLY public.user_cards DROP CONSTRAINT IF EXISTS user_cards_pkey;
ALTER TABLE IF EXISTS ONLY public.streets DROP CONSTRAINT IF EXISTS streets_pkey;
ALTER TABLE IF EXISTS ONLY public.sellers DROP CONSTRAINT IF EXISTS sellers_user_id_key;
ALTER TABLE IF EXISTS ONLY public.sellers DROP CONSTRAINT IF EXISTS sellers_pkey;
ALTER TABLE IF EXISTS ONLY public.sellers DROP CONSTRAINT IF EXISTS sellers_inn_key;
ALTER TABLE IF EXISTS ONLY public.roles DROP CONSTRAINT IF EXISTS roles_pkey;
ALTER TABLE IF EXISTS ONLY public.roles DROP CONSTRAINT IF EXISTS roles_name_key;
ALTER TABLE IF EXISTS ONLY public.reviews DROP CONSTRAINT IF EXISTS reviews_pkey;
ALTER TABLE IF EXISTS ONLY public.reviews DROP CONSTRAINT IF EXISTS reviews_buyer_id_product_id_key;
ALTER TABLE IF EXISTS ONLY public.products DROP CONSTRAINT IF EXISTS products_pkey;
ALTER TABLE IF EXISTS ONLY public.product_parameter_values DROP CONSTRAINT IF EXISTS product_parameter_values_pkey;
ALTER TABLE IF EXISTS ONLY public.product_images DROP CONSTRAINT IF EXISTS product_images_pkey;
ALTER TABLE IF EXISTS ONLY public.podcategories DROP CONSTRAINT IF EXISTS podcategories_pkey;
ALTER TABLE IF EXISTS ONLY public.podcategories DROP CONSTRAINT IF EXISTS podcategories_name_key;
ALTER TABLE IF EXISTS ONLY public.pickup_points DROP CONSTRAINT IF EXISTS pickup_points_pkey;
ALTER TABLE IF EXISTS ONLY public.payments DROP CONSTRAINT IF EXISTS payments_pkey;
ALTER TABLE IF EXISTS ONLY public.payment_methods DROP CONSTRAINT IF EXISTS payment_methods_pkey;
ALTER TABLE IF EXISTS ONLY public.payment_methods DROP CONSTRAINT IF EXISTS payment_methods_name_key;
ALTER TABLE IF EXISTS ONLY public.parameters DROP CONSTRAINT IF EXISTS parameters_pkey;
ALTER TABLE IF EXISTS ONLY public.parameters DROP CONSTRAINT IF EXISTS parameters_name_key;
ALTER TABLE IF EXISTS ONLY public.orders DROP CONSTRAINT IF EXISTS orders_pkey;
ALTER TABLE IF EXISTS ONLY public.order_items DROP CONSTRAINT IF EXISTS order_items_pkey;
ALTER TABLE IF EXISTS ONLY public.measurement_units DROP CONSTRAINT IF EXISTS measurement_units_short_name_key;
ALTER TABLE IF EXISTS ONLY public.measurement_units DROP CONSTRAINT IF EXISTS measurement_units_pkey;
ALTER TABLE IF EXISTS ONLY public.measurement_units DROP CONSTRAINT IF EXISTS measurement_units_name_key;
ALTER TABLE IF EXISTS ONLY public.list_types DROP CONSTRAINT IF EXISTS list_types_pkey;
ALTER TABLE IF EXISTS ONLY public.list_types DROP CONSTRAINT IF EXISTS list_types_list_type_name_key;
ALTER TABLE IF EXISTS ONLY public.houses DROP CONSTRAINT IF EXISTS houses_pkey;
ALTER TABLE IF EXISTS ONLY public.cities DROP CONSTRAINT IF EXISTS cities_pkey;
ALTER TABLE IF EXISTS ONLY public.cities DROP CONSTRAINT IF EXISTS cities_city_name_key;
ALTER TABLE IF EXISTS ONLY public.category_parameters DROP CONSTRAINT IF EXISTS category_parameters_pkey;
ALTER TABLE IF EXISTS ONLY public.categories DROP CONSTRAINT IF EXISTS categories_pkey;
ALTER TABLE IF EXISTS ONLY public.categories DROP CONSTRAINT IF EXISTS categories_name_key;
ALTER TABLE IF EXISTS ONLY public.carts DROP CONSTRAINT IF EXISTS carts_pkey;
ALTER TABLE IF EXISTS ONLY public.cart_items DROP CONSTRAINT IF EXISTS cart_items_pkey;
ALTER TABLE IF EXISTS public.users ALTER COLUMN user_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.user_pickup_points ALTER COLUMN user_pickup_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.user_cards ALTER COLUMN card_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.streets ALTER COLUMN street_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.sellers ALTER COLUMN seller_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.roles ALTER COLUMN role_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.reviews ALTER COLUMN review_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.products ALTER COLUMN product_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.product_images ALTER COLUMN image_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.podcategories ALTER COLUMN podcategories_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.pickup_points ALTER COLUMN pickup_point_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.payments ALTER COLUMN payment_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.payment_methods ALTER COLUMN payment_method_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.parameters ALTER COLUMN parameter_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.orders ALTER COLUMN order_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.order_items ALTER COLUMN order_item_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.measurement_units ALTER COLUMN unit_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.list_types ALTER COLUMN list_type_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.houses ALTER COLUMN house_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.cities ALTER COLUMN city_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.categories ALTER COLUMN category_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.carts ALTER COLUMN cart_id DROP DEFAULT;
ALTER TABLE IF EXISTS public.cart_items ALTER COLUMN cart_item_id DROP DEFAULT;
DROP SEQUENCE IF EXISTS public.users_user_id_seq;
DROP TABLE IF EXISTS public.users;
DROP SEQUENCE IF EXISTS public.user_pickup_points_user_pickup_id_seq;
DROP TABLE IF EXISTS public.user_pickup_points;
DROP SEQUENCE IF EXISTS public.user_cards_card_id_seq;
DROP TABLE IF EXISTS public.user_cards;
DROP SEQUENCE IF EXISTS public.streets_street_id_seq;
DROP TABLE IF EXISTS public.streets;
DROP SEQUENCE IF EXISTS public.sellers_seller_id_seq;
DROP TABLE IF EXISTS public.sellers;
DROP SEQUENCE IF EXISTS public.roles_role_id_seq;
DROP TABLE IF EXISTS public.roles;
DROP SEQUENCE IF EXISTS public.reviews_review_id_seq;
DROP TABLE IF EXISTS public.reviews;
DROP SEQUENCE IF EXISTS public.products_product_id_seq;
DROP TABLE IF EXISTS public.products;
DROP TABLE IF EXISTS public.product_parameter_values;
DROP SEQUENCE IF EXISTS public.product_images_image_id_seq;
DROP TABLE IF EXISTS public.product_images;
DROP SEQUENCE IF EXISTS public.podcategories_podcategories_id_seq;
DROP TABLE IF EXISTS public.podcategories;
DROP SEQUENCE IF EXISTS public.pickup_points_pickup_point_id_seq;
DROP TABLE IF EXISTS public.pickup_points;
DROP SEQUENCE IF EXISTS public.payments_payment_id_seq;
DROP TABLE IF EXISTS public.payments;
DROP SEQUENCE IF EXISTS public.payment_methods_payment_method_id_seq;
DROP TABLE IF EXISTS public.payment_methods;
DROP SEQUENCE IF EXISTS public.parameters_parameter_id_seq;
DROP TABLE IF EXISTS public.parameters;
DROP SEQUENCE IF EXISTS public.orders_order_id_seq;
DROP TABLE IF EXISTS public.orders;
DROP SEQUENCE IF EXISTS public.order_items_order_item_id_seq;
DROP TABLE IF EXISTS public.order_items;
DROP SEQUENCE IF EXISTS public.measurement_units_unit_id_seq;
DROP TABLE IF EXISTS public.measurement_units;
DROP SEQUENCE IF EXISTS public.list_types_list_type_id_seq;
DROP TABLE IF EXISTS public.list_types;
DROP SEQUENCE IF EXISTS public.houses_house_id_seq;
DROP TABLE IF EXISTS public.houses;
DROP SEQUENCE IF EXISTS public.cities_city_id_seq;
DROP TABLE IF EXISTS public.cities;
DROP TABLE IF EXISTS public.category_parameters;
DROP SEQUENCE IF EXISTS public.categories_category_id_seq;
DROP TABLE IF EXISTS public.categories;
DROP SEQUENCE IF EXISTS public.carts_cart_id_seq;
DROP TABLE IF EXISTS public.carts;
DROP SEQUENCE IF EXISTS public.cart_items_cart_item_id_seq;
DROP TABLE IF EXISTS public.cart_items;
-- *not* dropping schema, since initdb creates it
--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS '';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: cart_items; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: cart_items_cart_item_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cart_items_cart_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cart_items_cart_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cart_items_cart_item_id_seq OWNED BY public.cart_items.cart_item_id;


--
-- Name: carts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.carts (
    cart_id bigint NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: carts_cart_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.carts_cart_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: carts_cart_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.carts_cart_id_seq OWNED BY public.carts.cart_id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories (
    category_id bigint NOT NULL,
    name text NOT NULL
);


--
-- Name: categories_category_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.categories_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.categories_category_id_seq OWNED BY public.categories.category_id;


--
-- Name: category_parameters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.category_parameters (
    parameter_id bigint NOT NULL,
    is_required boolean DEFAULT false NOT NULL,
    podcategory_id bigint NOT NULL
);


--
-- Name: cities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cities (
    city_id bigint NOT NULL,
    city_name text NOT NULL
);


--
-- Name: cities_city_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cities_city_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cities_city_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cities_city_id_seq OWNED BY public.cities.city_id;


--
-- Name: houses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.houses (
    house_id bigint NOT NULL,
    street_id bigint NOT NULL,
    house_number text NOT NULL
);


--
-- Name: houses_house_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.houses_house_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: houses_house_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.houses_house_id_seq OWNED BY public.houses.house_id;


--
-- Name: list_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.list_types (
    list_type_id bigint NOT NULL,
    list_type_name text NOT NULL
);


--
-- Name: list_types_list_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.list_types_list_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: list_types_list_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.list_types_list_type_id_seq OWNED BY public.list_types.list_type_id;


--
-- Name: measurement_units; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.measurement_units (
    unit_id bigint NOT NULL,
    name text NOT NULL,
    short_name text NOT NULL
);


--
-- Name: measurement_units_unit_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.measurement_units_unit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: measurement_units_unit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.measurement_units_unit_id_seq OWNED BY public.measurement_units.unit_id;


--
-- Name: order_items; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: order_items_order_item_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.order_items_order_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: order_items_order_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.order_items_order_item_id_seq OWNED BY public.order_items.order_item_id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: orders_order_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.orders_order_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: orders_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.orders_order_id_seq OWNED BY public.orders.order_id;


--
-- Name: parameters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.parameters (
    parameter_id bigint NOT NULL,
    name text NOT NULL,
    data_type text NOT NULL,
    unit_id bigint
);


--
-- Name: parameters_parameter_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.parameters_parameter_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: parameters_parameter_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.parameters_parameter_id_seq OWNED BY public.parameters.parameter_id;


--
-- Name: payment_methods; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payment_methods (
    payment_method_id bigint NOT NULL,
    name text NOT NULL
);


--
-- Name: payment_methods_payment_method_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payment_methods_payment_method_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payment_methods_payment_method_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.payment_methods_payment_method_id_seq OWNED BY public.payment_methods.payment_method_id;


--
-- Name: payments; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: payments_payment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payments_payment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payments_payment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.payments_payment_id_seq OWNED BY public.payments.payment_id;


--
-- Name: pickup_points; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pickup_points (
    pickup_point_id bigint NOT NULL,
    city_id bigint,
    house_id bigint
);


--
-- Name: pickup_points_pickup_point_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pickup_points_pickup_point_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pickup_points_pickup_point_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pickup_points_pickup_point_id_seq OWNED BY public.pickup_points.pickup_point_id;


--
-- Name: podcategories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.podcategories (
    podcategories_id bigint NOT NULL,
    name text NOT NULL,
    category_id bigint
);


--
-- Name: podcategories_podcategories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.podcategories_podcategories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: podcategories_podcategories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.podcategories_podcategories_id_seq OWNED BY public.podcategories.podcategories_id;


--
-- Name: product_images; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_images (
    image_id bigint NOT NULL,
    product_id bigint NOT NULL,
    image_url text NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL
);


--
-- Name: product_images_image_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.product_images_image_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_images_image_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.product_images_image_id_seq OWNED BY public.product_images.image_id;


--
-- Name: product_parameter_values; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.product_parameter_values (
    product_id bigint NOT NULL,
    parameter_id bigint NOT NULL,
    value_text text NOT NULL,
    unit_id bigint
);


--
-- Name: products; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.products (
    product_id bigint NOT NULL,
    seller_id bigint NOT NULL,
    name text NOT NULL,
    description text,
    price numeric(12,2) NOT NULL,
    quantity integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    currency text DEFAULT 'RUB'::text NOT NULL,
    subcategory_id bigint,
    podcategory_id bigint,
    CONSTRAINT products_price_check CHECK ((price >= (0)::numeric)),
    CONSTRAINT products_quantity_check CHECK ((quantity >= 0))
);


--
-- Name: products_product_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.products_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: products_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.products_product_id_seq OWNED BY public.products.product_id;


--
-- Name: reviews; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: reviews_review_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reviews_review_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reviews_review_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reviews_review_id_seq OWNED BY public.reviews.review_id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    role_id bigint NOT NULL,
    name text NOT NULL
);


--
-- Name: roles_role_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.roles_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.roles_role_id_seq OWNED BY public.roles.role_id;


--
-- Name: sellers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sellers (
    seller_id bigint NOT NULL,
    shop_name text NOT NULL,
    description text,
    inn text,
    unp text,
    user_id bigint
);


--
-- Name: sellers_seller_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sellers_seller_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sellers_seller_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sellers_seller_id_seq OWNED BY public.sellers.seller_id;


--
-- Name: streets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.streets (
    street_id bigint NOT NULL,
    city_id bigint NOT NULL,
    street_name text NOT NULL
);


--
-- Name: streets_street_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.streets_street_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: streets_street_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.streets_street_id_seq OWNED BY public.streets.street_id;


--
-- Name: user_cards; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_cards (
    card_id bigint NOT NULL,
    user_id bigint NOT NULL,
    card_number text NOT NULL
);


--
-- Name: user_cards_card_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_cards_card_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_cards_card_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_cards_card_id_seq OWNED BY public.user_cards.card_id;


--
-- Name: user_pickup_points; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_pickup_points (
    user_pickup_id bigint NOT NULL,
    user_id bigint NOT NULL,
    pickup_point_id bigint NOT NULL
);


--
-- Name: user_pickup_points_user_pickup_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_pickup_points_user_pickup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_pickup_points_user_pickup_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_pickup_points_user_pickup_id_seq OWNED BY public.user_pickup_points.user_pickup_id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
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
    is_blocked boolean DEFAULT false NOT NULL,
    email_verified boolean DEFAULT false
);


--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;


--
-- Name: cart_items cart_item_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_items ALTER COLUMN cart_item_id SET DEFAULT nextval('public.cart_items_cart_item_id_seq'::regclass);


--
-- Name: carts cart_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.carts ALTER COLUMN cart_id SET DEFAULT nextval('public.carts_cart_id_seq'::regclass);


--
-- Name: categories category_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories ALTER COLUMN category_id SET DEFAULT nextval('public.categories_category_id_seq'::regclass);


--
-- Name: cities city_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cities ALTER COLUMN city_id SET DEFAULT nextval('public.cities_city_id_seq'::regclass);


--
-- Name: houses house_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.houses ALTER COLUMN house_id SET DEFAULT nextval('public.houses_house_id_seq'::regclass);


--
-- Name: list_types list_type_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.list_types ALTER COLUMN list_type_id SET DEFAULT nextval('public.list_types_list_type_id_seq'::regclass);


--
-- Name: measurement_units unit_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.measurement_units ALTER COLUMN unit_id SET DEFAULT nextval('public.measurement_units_unit_id_seq'::regclass);


--
-- Name: order_items order_item_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items ALTER COLUMN order_item_id SET DEFAULT nextval('public.order_items_order_item_id_seq'::regclass);


--
-- Name: orders order_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders ALTER COLUMN order_id SET DEFAULT nextval('public.orders_order_id_seq'::regclass);


--
-- Name: parameters parameter_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parameters ALTER COLUMN parameter_id SET DEFAULT nextval('public.parameters_parameter_id_seq'::regclass);


--
-- Name: payment_methods payment_method_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_methods ALTER COLUMN payment_method_id SET DEFAULT nextval('public.payment_methods_payment_method_id_seq'::regclass);


--
-- Name: payments payment_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments ALTER COLUMN payment_id SET DEFAULT nextval('public.payments_payment_id_seq'::regclass);


--
-- Name: pickup_points pickup_point_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pickup_points ALTER COLUMN pickup_point_id SET DEFAULT nextval('public.pickup_points_pickup_point_id_seq'::regclass);


--
-- Name: podcategories podcategories_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.podcategories ALTER COLUMN podcategories_id SET DEFAULT nextval('public.podcategories_podcategories_id_seq'::regclass);


--
-- Name: product_images image_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_images ALTER COLUMN image_id SET DEFAULT nextval('public.product_images_image_id_seq'::regclass);


--
-- Name: products product_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products ALTER COLUMN product_id SET DEFAULT nextval('public.products_product_id_seq'::regclass);


--
-- Name: reviews review_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews ALTER COLUMN review_id SET DEFAULT nextval('public.reviews_review_id_seq'::regclass);


--
-- Name: roles role_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles ALTER COLUMN role_id SET DEFAULT nextval('public.roles_role_id_seq'::regclass);


--
-- Name: sellers seller_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sellers ALTER COLUMN seller_id SET DEFAULT nextval('public.sellers_seller_id_seq'::regclass);


--
-- Name: streets street_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.streets ALTER COLUMN street_id SET DEFAULT nextval('public.streets_street_id_seq'::regclass);


--
-- Name: user_cards card_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_cards ALTER COLUMN card_id SET DEFAULT nextval('public.user_cards_card_id_seq'::regclass);


--
-- Name: user_pickup_points user_pickup_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_pickup_points ALTER COLUMN user_pickup_id SET DEFAULT nextval('public.user_pickup_points_user_pickup_id_seq'::regclass);


--
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


--
-- Data for Name: cart_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cart_items (cart_item_id, cart_id, product_id, quantity, added_at, selected_for_purchase, list_type_id, status) FROM stdin;
15	1	1	1	2026-03-18 05:31:43.190552+00	f	1	ordered
16	1	2	2	2026-03-18 16:11:51.184974+00	t	1	ordered
17	1	2	1	2026-03-18 16:47:47.421991+00	f	1	ordered
27	1	6	1	2026-06-15 10:43:02.509222+00	f	1	ordered
28	1	6	1	2026-06-15 10:44:04.402749+00	f	2	active
\.


--
-- Data for Name: carts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.carts (cart_id, user_id, created_at) FROM stdin;
1	5	2026-03-02 14:07:41.352545+00
\.


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.categories (category_id, name) FROM stdin;
1	Electronics
\.


--
-- Data for Name: category_parameters; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.category_parameters (parameter_id, is_required, podcategory_id) FROM stdin;
17	t	2
16	t	2
\.


--
-- Data for Name: cities; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cities (city_id, city_name) FROM stdin;
1	Moscow
2	аушвиц
\.


--
-- Data for Name: houses; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.houses (house_id, street_id, house_number) FROM stdin;
1	1	20
\.


--
-- Data for Name: list_types; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.list_types (list_type_id, list_type_name) FROM stdin;
1	cart
2	favorites
3	later
\.


--
-- Data for Name: measurement_units; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.measurement_units (unit_id, name, short_name) FROM stdin;
1	Цвет	цв
2	Длина	дл
\.


--
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_items (order_item_id, order_id, quantity, source_cart_item_id, price_snapshot) FROM stdin;
1	1	2	\N	999.99
2	2	1	\N	999.99
3	3	1	16	99.99
4	3	1	15	999.99
5	4	1	17	99.99
6	5	1	27	120.00
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.orders (order_id, buyer_id, pickup_point_id, total_amount, created_at, status) FROM stdin;
1	5	2	1999.98	2026-03-03 14:47:04.6883+00	delivered
2	5	2	999.99	2026-03-13 16:28:51.749556+00	created
3	5	2	1099.98	2026-03-18 16:12:25.181054+00	created
4	5	2	99.99	2026-03-18 16:48:03.157125+00	delivered
5	5	4	120.00	2026-06-15 10:43:44.601916+00	created
\.


--
-- Data for Name: parameters; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.parameters (parameter_id, name, data_type, unit_id) FROM stdin;
16	Цвет	text	\N
17	Материал	text	\N
\.


--
-- Data for Name: payment_methods; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payment_methods (payment_method_id, name) FROM stdin;
1	card
2	cash
4	cash_on_pickup
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payments (payment_id, order_id, payment_method_id, card_id, amount, created_at) FROM stdin;
1	1	1	\N	1999.98	2026-03-06 22:43:14.149846+00
2	4	1	5	99.99	2026-03-18 16:48:03.157125+00
3	5	1	5	120.00	2026-06-15 10:43:44.601916+00
\.


--
-- Data for Name: pickup_points; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.pickup_points (pickup_point_id, city_id, house_id) FROM stdin;
2	1	\N
4	\N	1
\.


--
-- Data for Name: podcategories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.podcategories (podcategories_id, name, category_id) FROM stdin;
1	Клавиатуры	1
2	Мышь	1
\.


--
-- Data for Name: product_images; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_images (image_id, product_id, image_url, sort_order) FROM stdin;
1	3	https://image2url.com/r2/default/images/1773856134583-f6b5876b-783d-4c79-b657-b136c24b8096.png	1
2	3	https://image2url.com/r2/default/images/1773856389531-26fdd4e4-b3cc-484e-9c5b-d070e290152d.jpg	2
3	6	https://s3.twcstorage.ru/8829b146-a8e6-4ca3-993d-60dc7dc4dd39/products/6/1781520157338_2628742777.jpg	1
\.


--
-- Data for Name: product_parameter_values; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.product_parameter_values (product_id, parameter_id, value_text, unit_id) FROM stdin;
6	17	пластик	\N
6	16	черный	1
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.products (product_id, seller_id, name, description, price, quantity, created_at, currency, subcategory_id, podcategory_id) FROM stdin;
1	1	iPhone Demo	Seed product for dev	999.99	10	2026-03-03 12:36:22.946494+00	RUB	\N	\N
2	1	Seller order tetsssss	test	100.00	5	2026-03-18 16:10:48.73772+00	BYN	\N	\N
3	1	test phone	╤é╨╡╨╗╨╡╤ä╨╛╨╜	200.00	200	2026-03-18 17:47:01.592237+00	BYN	\N	\N
6	1	Мышь игровая	Класная мышь подойдет для игр	120.00	200	2026-06-15 10:42:27.644505+00	BYN	2	\N
\.


--
-- Data for Name: reviews; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.reviews (review_id, buyer_id, product_id, rating, comment, created_at, moderation_status) FROM stdin;
1	5	1	4	??????? ?????	2026-03-09 07:13:12.671837+00	approved
2	5	2	5	╨▓╤ü╨╡ ╨╛╤é╨╗╨╕╤ç╨╜╨╛	2026-03-22 07:54:37.064636+00	approved
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.roles (role_id, name) FROM stdin;
1	admin
2	buyer
3	seller
\.


--
-- Data for Name: sellers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sellers (seller_id, shop_name, description, inn, unp, user_id) FROM stdin;
2	My Test Shop	\N	\N	\N	9
3	magn	\N	\N	\N	10
1	Demo Shop	Seed seller	0000000000	7387372727	6
\.


--
-- Data for Name: streets; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.streets (street_id, city_id, street_name) FROM stdin;
1	1	Первомайска
\.


--
-- Data for Name: user_cards; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_cards (card_id, user_id, card_number) FROM stdin;
5	5	**** **** **** 9633
\.


--
-- Data for Name: user_pickup_points; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_pickup_points (user_pickup_id, user_id, pickup_point_id) FROM stdin;
2	5	2
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (user_id, role_id, first_name, last_name, patronymic, phone, email, password_hash, gender, created_at, is_blocked, email_verified) FROM stdin;
1	2	\N	\N	\N	\N	test@test.com	$2a$10$/qkzJn2N8P3.2xxZSDXbFu20D2K39R5XCyiSNYuC5UI9PvHKO1AES	\N	2026-03-02 12:18:55.849355+00	f	t
4	1	\N	\N	\N	\N	me2@test.com	$2a$10$dOIvBHfXE2Syje598nyYL.JtbzT1CUlWvPhaWX9ktsvQ3KjqjnBKy	\N	2026-03-02 12:26:11.429133+00	f	t
3	3	Ivan	Petrov	\N	\N	test2@test.com	$2a$10$meK4SfGYuppHfra6vw./su3l18pCMy8pzffef6JtFgethg/TPRJgm	\N	2026-03-02 12:25:22.119579+00	f	t
6	3	\N	\N	\N	\N	seller@test.com	$2a$10$XgeoyXdRF8kyNSa5ZyEo5uR40TPClwNDhiERepw/2.fdew1bcWlF6	\N	2026-03-06 23:05:37.462979+00	f	t
7	2	\N	\N	\N	\N	buyer2@gmail.com	$2a$10$GorMA5c0ntDBJCDsG3Ga3OFO5Ro2Ne188oSZlsjpYzn.FKgqEnWca	\N	2026-03-09 14:07:46.615698+00	f	t
8	2	\N	\N	\N	\N	buyer2@test.com	$2a$10$dcuer4wsSySEvUWCJc5Y7u7lDYgJtkwzHk8/4h7fSejL1wzn20oJy	\N	2026-03-09 14:32:42.777616+00	f	t
9	3	\N	\N	\N	\N	seller2@test.com	$2a$10$K0/GhFJ/vwy8vUboibMBfu2o5gh7yS7ERapTLmFOkajdcU99WPM8.	\N	2026-03-09 14:32:53.997084+00	f	t
10	3	\N	\N	\N	\N	sallers11@gmail.com	$2a$10$1AZgfWq0uX2ahufM7NF0JOEuL9BDMgo5GPKrehYaifI7i.Uv2hPUW	\N	2026-03-09 14:45:44.026507+00	f	t
5	2	╨╛╨║╨╛╨░╨╛	╨╗╨░╨╗╨░╨╗	╨┐╨╗╨┐╨╗╨╗╨░	+375 (29) 651-34-21	buyer@test.com	$2a$10$sAqteT1A9ILyCapWjfBFAe57qVZMapczbinc/UkvYB9Wt1pUQNSFu	female	2026-03-02 13:56:20.283802+00	f	t
2	2	\N	\N	\N	\N	test1@test.com	$2a$10$H759GjaJJYN1Rzgrb06yHeZtcI4CLourRTzwCxWrXaNwyaj4/MRxy	\N	2026-03-02 12:23:06.090785+00	f	t
\.


--
-- Name: cart_items_cart_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cart_items_cart_item_id_seq', 28, true);


--
-- Name: carts_cart_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.carts_cart_id_seq', 1, true);


--
-- Name: categories_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.categories_category_id_seq', 1, true);


--
-- Name: cities_city_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cities_city_id_seq', 2, true);


--
-- Name: houses_house_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.houses_house_id_seq', 1, true);


--
-- Name: list_types_list_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.list_types_list_type_id_seq', 3, true);


--
-- Name: measurement_units_unit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.measurement_units_unit_id_seq', 2, true);


--
-- Name: order_items_order_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.order_items_order_item_id_seq', 6, true);


--
-- Name: orders_order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.orders_order_id_seq', 5, true);


--
-- Name: parameters_parameter_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.parameters_parameter_id_seq', 17, true);


--
-- Name: payment_methods_payment_method_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.payment_methods_payment_method_id_seq', 4, true);


--
-- Name: payments_payment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.payments_payment_id_seq', 3, true);


--
-- Name: pickup_points_pickup_point_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.pickup_points_pickup_point_id_seq', 4, true);


--
-- Name: podcategories_podcategories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.podcategories_podcategories_id_seq', 2, true);


--
-- Name: product_images_image_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.product_images_image_id_seq', 3, true);


--
-- Name: products_product_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.products_product_id_seq', 6, true);


--
-- Name: reviews_review_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.reviews_review_id_seq', 2, true);


--
-- Name: roles_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.roles_role_id_seq', 3, true);


--
-- Name: sellers_seller_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sellers_seller_id_seq', 4, true);


--
-- Name: streets_street_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.streets_street_id_seq', 1, true);


--
-- Name: user_cards_card_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.user_cards_card_id_seq', 5, true);


--
-- Name: user_pickup_points_user_pickup_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.user_pickup_points_user_pickup_id_seq', 2, true);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_user_id_seq', 10, true);


--
-- Name: cart_items cart_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_pkey PRIMARY KEY (cart_item_id);


--
-- Name: carts carts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.carts
    ADD CONSTRAINT carts_pkey PRIMARY KEY (cart_id);


--
-- Name: categories categories_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_name_key UNIQUE (name);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (category_id);


--
-- Name: category_parameters category_parameters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category_parameters
    ADD CONSTRAINT category_parameters_pkey PRIMARY KEY (podcategory_id, parameter_id);


--
-- Name: cities cities_city_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT cities_city_name_key UNIQUE (city_name);


--
-- Name: cities cities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (city_id);


--
-- Name: houses houses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.houses
    ADD CONSTRAINT houses_pkey PRIMARY KEY (house_id);


--
-- Name: list_types list_types_list_type_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.list_types
    ADD CONSTRAINT list_types_list_type_name_key UNIQUE (list_type_name);


--
-- Name: list_types list_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.list_types
    ADD CONSTRAINT list_types_pkey PRIMARY KEY (list_type_id);


--
-- Name: measurement_units measurement_units_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.measurement_units
    ADD CONSTRAINT measurement_units_name_key UNIQUE (name);


--
-- Name: measurement_units measurement_units_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.measurement_units
    ADD CONSTRAINT measurement_units_pkey PRIMARY KEY (unit_id);


--
-- Name: measurement_units measurement_units_short_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.measurement_units
    ADD CONSTRAINT measurement_units_short_name_key UNIQUE (short_name);


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (order_item_id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);


--
-- Name: parameters parameters_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parameters
    ADD CONSTRAINT parameters_name_key UNIQUE (name);


--
-- Name: parameters parameters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parameters
    ADD CONSTRAINT parameters_pkey PRIMARY KEY (parameter_id);


--
-- Name: payment_methods payment_methods_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_methods
    ADD CONSTRAINT payment_methods_name_key UNIQUE (name);


--
-- Name: payment_methods payment_methods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payment_methods
    ADD CONSTRAINT payment_methods_pkey PRIMARY KEY (payment_method_id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (payment_id);


--
-- Name: pickup_points pickup_points_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pickup_points
    ADD CONSTRAINT pickup_points_pkey PRIMARY KEY (pickup_point_id);


--
-- Name: podcategories podcategories_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.podcategories
    ADD CONSTRAINT podcategories_name_key UNIQUE (name);


--
-- Name: podcategories podcategories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.podcategories
    ADD CONSTRAINT podcategories_pkey PRIMARY KEY (podcategories_id);


--
-- Name: product_images product_images_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_images
    ADD CONSTRAINT product_images_pkey PRIMARY KEY (image_id);


--
-- Name: product_parameter_values product_parameter_values_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_parameter_values
    ADD CONSTRAINT product_parameter_values_pkey PRIMARY KEY (product_id, parameter_id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (product_id);


--
-- Name: reviews reviews_buyer_id_product_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_buyer_id_product_id_key UNIQUE (buyer_id, product_id);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (review_id);


--
-- Name: roles roles_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key UNIQUE (name);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (role_id);


--
-- Name: sellers sellers_inn_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sellers
    ADD CONSTRAINT sellers_inn_key UNIQUE (inn);


--
-- Name: sellers sellers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sellers
    ADD CONSTRAINT sellers_pkey PRIMARY KEY (seller_id);


--
-- Name: sellers sellers_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sellers
    ADD CONSTRAINT sellers_user_id_key UNIQUE (user_id);


--
-- Name: streets streets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.streets
    ADD CONSTRAINT streets_pkey PRIMARY KEY (street_id);


--
-- Name: user_cards user_cards_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_cards
    ADD CONSTRAINT user_cards_pkey PRIMARY KEY (card_id);


--
-- Name: user_pickup_points user_pickup_points_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_pickup_points
    ADD CONSTRAINT user_pickup_points_pkey PRIMARY KEY (user_pickup_id);


--
-- Name: user_pickup_points user_pickup_points_user_id_pickup_point_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_pickup_points
    ADD CONSTRAINT user_pickup_points_user_id_pickup_point_id_key UNIQUE (user_id, pickup_point_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: idx_cart_items_cart_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cart_items_cart_id ON public.cart_items USING btree (cart_id);


--
-- Name: idx_cart_items_list_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cart_items_list_type_id ON public.cart_items USING btree (list_type_id);


--
-- Name: idx_cart_items_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cart_items_product_id ON public.cart_items USING btree (product_id);


--
-- Name: idx_carts_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_carts_user_id ON public.carts USING btree (user_id);


--
-- Name: idx_category_parameters_podcategory_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_category_parameters_podcategory_id ON public.category_parameters USING btree (podcategory_id);


--
-- Name: idx_houses_street_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_houses_street_id ON public.houses USING btree (street_id);


--
-- Name: idx_order_items_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_order_items_order_id ON public.order_items USING btree (order_id);


--
-- Name: idx_orders_buyer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_orders_buyer_id ON public.orders USING btree (buyer_id);


--
-- Name: idx_orders_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_orders_created_at ON public.orders USING btree (created_at);


--
-- Name: idx_payments_order_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_payments_order_id ON public.payments USING btree (order_id);


--
-- Name: idx_pickup_points_city_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_pickup_points_city_id ON public.pickup_points USING btree (city_id);


--
-- Name: idx_podcategories_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_podcategories_category_id ON public.podcategories USING btree (category_id);


--
-- Name: idx_product_images_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_product_images_product_id ON public.product_images USING btree (product_id);


--
-- Name: idx_products_seller_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_products_seller_id ON public.products USING btree (seller_id);


--
-- Name: idx_products_subcategory_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_products_subcategory_id ON public.products USING btree (subcategory_id);


--
-- Name: idx_reviews_product_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reviews_product_id ON public.reviews USING btree (product_id);


--
-- Name: idx_streets_city_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_streets_city_id ON public.streets USING btree (city_id);


--
-- Name: idx_user_cards_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_cards_user_id ON public.user_cards USING btree (user_id);


--
-- Name: idx_user_pickup_points_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_user_pickup_points_user_id ON public.user_pickup_points USING btree (user_id);


--
-- Name: idx_users_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_role_id ON public.users USING btree (role_id);


--
-- Name: cart_items cart_items_cart_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_cart_id_fkey FOREIGN KEY (cart_id) REFERENCES public.carts(cart_id) ON DELETE CASCADE;


--
-- Name: cart_items cart_items_list_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_list_type_id_fkey FOREIGN KEY (list_type_id) REFERENCES public.list_types(list_type_id) ON DELETE RESTRICT;


--
-- Name: cart_items cart_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cart_items
    ADD CONSTRAINT cart_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id) ON DELETE RESTRICT;


--
-- Name: carts carts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.carts
    ADD CONSTRAINT carts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: category_parameters category_parameters_parameter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category_parameters
    ADD CONSTRAINT category_parameters_parameter_id_fkey FOREIGN KEY (parameter_id) REFERENCES public.parameters(parameter_id) ON DELETE CASCADE;


--
-- Name: category_parameters category_parameters_podcategory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category_parameters
    ADD CONSTRAINT category_parameters_podcategory_id_fkey FOREIGN KEY (podcategory_id) REFERENCES public.podcategories(podcategories_id) ON DELETE CASCADE;


--
-- Name: products fk_products_podcategory; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT fk_products_podcategory FOREIGN KEY (podcategory_id) REFERENCES public.podcategories(podcategories_id);


--
-- Name: houses houses_street_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.houses
    ADD CONSTRAINT houses_street_id_fkey FOREIGN KEY (street_id) REFERENCES public.streets(street_id) ON DELETE CASCADE;


--
-- Name: order_items order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(order_id) ON DELETE CASCADE;


--
-- Name: order_items order_items_source_cart_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_source_cart_item_id_fkey FOREIGN KEY (source_cart_item_id) REFERENCES public.cart_items(cart_item_id) ON DELETE SET NULL;


--
-- Name: orders orders_buyer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_buyer_id_fkey FOREIGN KEY (buyer_id) REFERENCES public.users(user_id) ON DELETE RESTRICT;


--
-- Name: orders orders_pickup_point_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pickup_point_id_fkey FOREIGN KEY (pickup_point_id) REFERENCES public.pickup_points(pickup_point_id) ON DELETE RESTRICT;


--
-- Name: parameters parameters_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.parameters
    ADD CONSTRAINT parameters_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.measurement_units(unit_id) ON DELETE SET NULL;


--
-- Name: payments payments_card_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_card_id_fkey FOREIGN KEY (card_id) REFERENCES public.user_cards(card_id) ON DELETE SET NULL;


--
-- Name: payments payments_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(order_id) ON DELETE CASCADE;


--
-- Name: payments payments_payment_method_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_payment_method_id_fkey FOREIGN KEY (payment_method_id) REFERENCES public.payment_methods(payment_method_id) ON DELETE RESTRICT;


--
-- Name: pickup_points pickup_points_city_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pickup_points
    ADD CONSTRAINT pickup_points_city_id_fkey FOREIGN KEY (city_id) REFERENCES public.cities(city_id) ON DELETE RESTRICT;


--
-- Name: podcategories podcategories_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.podcategories
    ADD CONSTRAINT podcategories_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(category_id) ON DELETE CASCADE;


--
-- Name: product_images product_images_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_images
    ADD CONSTRAINT product_images_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id) ON DELETE CASCADE;


--
-- Name: product_parameter_values product_parameter_values_parameter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_parameter_values
    ADD CONSTRAINT product_parameter_values_parameter_id_fkey FOREIGN KEY (parameter_id) REFERENCES public.parameters(parameter_id) ON DELETE CASCADE;


--
-- Name: product_parameter_values product_parameter_values_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_parameter_values
    ADD CONSTRAINT product_parameter_values_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id) ON DELETE CASCADE;


--
-- Name: product_parameter_values product_parameter_values_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.product_parameter_values
    ADD CONSTRAINT product_parameter_values_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.measurement_units(unit_id) ON DELETE SET NULL;


--
-- Name: products products_seller_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_seller_id_fkey FOREIGN KEY (seller_id) REFERENCES public.sellers(seller_id) ON DELETE RESTRICT;


--
-- Name: products products_subcategory_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_subcategory_id_fkey FOREIGN KEY (subcategory_id) REFERENCES public.podcategories(podcategories_id) ON DELETE SET NULL;


--
-- Name: reviews reviews_buyer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_buyer_id_fkey FOREIGN KEY (buyer_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: reviews reviews_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id) ON DELETE CASCADE;


--
-- Name: sellers sellers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sellers
    ADD CONSTRAINT sellers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE RESTRICT;


--
-- Name: streets streets_city_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.streets
    ADD CONSTRAINT streets_city_id_fkey FOREIGN KEY (city_id) REFERENCES public.cities(city_id) ON DELETE CASCADE;


--
-- Name: user_cards user_cards_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_cards
    ADD CONSTRAINT user_cards_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: user_pickup_points user_pickup_points_pickup_point_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_pickup_points
    ADD CONSTRAINT user_pickup_points_pickup_point_id_fkey FOREIGN KEY (pickup_point_id) REFERENCES public.pickup_points(pickup_point_id) ON DELETE RESTRICT;


--
-- Name: user_pickup_points user_pickup_points_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_pickup_points
    ADD CONSTRAINT user_pickup_points_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE CASCADE;


--
-- Name: users users_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(role_id) ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

\unrestrict gp2UWmfwPknSXCaU1iXlE1qZ2uxhTBUHpbBMfqvleOsBHucjD8ziL0qVIJC0drH

