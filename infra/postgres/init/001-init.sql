BEGIN;

-- 1) Справочники ролей / пользователей
CREATE TABLE IF NOT EXISTS roles (
  role_id   BIGSERIAL PRIMARY KEY,
  name      TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS users (
  user_id        BIGSERIAL PRIMARY KEY,
  role_id        BIGINT NOT NULL REFERENCES roles(role_id) ON DELETE RESTRICT,
  first_name     TEXT,
  last_name      TEXT,
  patronymic     TEXT,
  phone          TEXT UNIQUE,
  email          TEXT UNIQUE,
  password_hash  TEXT NOT NULL,
  gender         TEXT,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_users_role_id ON users(role_id);

-- 2) Карты пользователя
CREATE TABLE IF NOT EXISTS user_cards (
  card_id     BIGSERIAL PRIMARY KEY,
  user_id     BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  card_number TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_user_cards_user_id ON user_cards(user_id);

-- 3) Адресные справочники (пока не используем в MVP, но таблицы есть)
CREATE TABLE IF NOT EXISTS cities (
  city_id   BIGSERIAL PRIMARY KEY,
  city_name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS streets (
  street_id   BIGSERIAL PRIMARY KEY,
  city_id     BIGINT NOT NULL REFERENCES cities(city_id) ON DELETE CASCADE,
  street_name TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_streets_city_id ON streets(city_id);

CREATE TABLE IF NOT EXISTS houses (
  house_id     BIGSERIAL PRIMARY KEY,
  street_id    BIGINT NOT NULL REFERENCES streets(street_id) ON DELETE CASCADE,
  house_number TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_houses_street_id ON houses(street_id);

-- 4) ПВЗ (по твоему решению: привязка к городу)
CREATE TABLE IF NOT EXISTS pickup_points (
  pickup_point_id BIGSERIAL PRIMARY KEY,
  city_id         BIGINT NOT NULL REFERENCES cities(city_id) ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_pickup_points_city_id ON pickup_points(city_id);

CREATE TABLE IF NOT EXISTS user_pickup_points (
  user_pickup_id  BIGSERIAL PRIMARY KEY,
  user_id         BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  pickup_point_id BIGINT NOT NULL REFERENCES pickup_points(pickup_point_id) ON DELETE RESTRICT,
  UNIQUE (user_id, pickup_point_id)
);

CREATE INDEX IF NOT EXISTS idx_user_pickup_points_user_id ON user_pickup_points(user_id);

-- 5) Категории / подкатегории (подкатегории пока без FK как на твоей схеме)
CREATE TABLE IF NOT EXISTS podcategories (
  podcategories_id BIGSERIAL PRIMARY KEY,
  name             TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS categories (
  category_id BIGSERIAL PRIMARY KEY,
  name        TEXT NOT NULL UNIQUE
);

-- 6) Параметры и связи
CREATE TABLE IF NOT EXISTS parameters (
  parameter_id BIGSERIAL PRIMARY KEY,
  name         TEXT NOT NULL UNIQUE,
  data_type    TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS category_parameters (
  category_id  BIGINT NOT NULL REFERENCES categories(category_id) ON DELETE CASCADE,
  parameter_id BIGINT NOT NULL REFERENCES parameters(parameter_id) ON DELETE CASCADE,
  is_required  BOOLEAN NOT NULL DEFAULT FALSE,
  PRIMARY KEY (category_id, parameter_id)
);

-- 7) Продавцы
CREATE TABLE IF NOT EXISTS sellers (
  seller_id    BIGSERIAL PRIMARY KEY,
  shop_name    TEXT NOT NULL,
  description  TEXT,
  inn          TEXT UNIQUE,
  url          TEXT
);

-- 8) Товары
CREATE TABLE IF NOT EXISTS products (
  product_id   BIGSERIAL PRIMARY KEY,
  category_id  BIGINT NOT NULL REFERENCES categories(category_id) ON DELETE RESTRICT,
  seller_id    BIGINT NOT NULL REFERENCES sellers(seller_id) ON DELETE RESTRICT,
  name         TEXT NOT NULL,
  description  TEXT,
  price        NUMERIC(12,2) NOT NULL CHECK (price >= 0),
  quantity     INT NOT NULL DEFAULT 0 CHECK (quantity >= 0),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  currency     TEXT NOT NULL DEFAULT 'RUB'
);

CREATE INDEX IF NOT EXISTS idx_products_category_id ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_seller_id ON products(seller_id);

CREATE TABLE IF NOT EXISTS product_images (
  image_id    BIGSERIAL PRIMARY KEY,
  product_id  BIGINT NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
  image_url   TEXT NOT NULL,
  sort_order  INT NOT NULL DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_product_images_product_id ON product_images(product_id);

CREATE TABLE IF NOT EXISTS product_parameter_values (
  product_id   BIGINT NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
  parameter_id BIGINT NOT NULL REFERENCES parameters(parameter_id) ON DELETE CASCADE,
  value_text   TEXT NOT NULL,
  PRIMARY KEY (product_id, parameter_id)
);

-- 9) Типы списков / корзина
CREATE TABLE IF NOT EXISTS list_types (
  list_type_id   BIGSERIAL PRIMARY KEY,
  list_type_name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS carts (
  cart_id    BIGSERIAL PRIMARY KEY,
  user_id    BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_carts_user_id ON carts(user_id);

CREATE TABLE IF NOT EXISTS cart_items (
  cart_item_id          BIGSERIAL PRIMARY KEY,
  cart_id               BIGINT NOT NULL REFERENCES carts(cart_id) ON DELETE CASCADE,
  product_id            BIGINT NOT NULL REFERENCES products(product_id) ON DELETE RESTRICT,
  quantity              INT NOT NULL CHECK (quantity > 0),
  added_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
  selected_for_purchase BOOLEAN NOT NULL DEFAULT TRUE,
  list_type_id          BIGINT NOT NULL REFERENCES list_types(list_type_id) ON DELETE RESTRICT,
  status                TEXT
);

CREATE INDEX IF NOT EXISTS idx_cart_items_cart_id ON cart_items(cart_id);
CREATE INDEX IF NOT EXISTS idx_cart_items_product_id ON cart_items(product_id);
CREATE INDEX IF NOT EXISTS idx_cart_items_list_type_id ON cart_items(list_type_id);

-- 10) Заказы / оплата
CREATE TABLE IF NOT EXISTS orders (
  order_id         BIGSERIAL PRIMARY KEY,
  buyer_id         BIGINT NOT NULL REFERENCES users(user_id) ON DELETE RESTRICT,
  pickup_point_id  BIGINT NOT NULL REFERENCES pickup_points(pickup_point_id) ON DELETE RESTRICT,
  total_amount     NUMERIC(12,2) NOT NULL CHECK (total_amount >= 0),
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  status           TEXT NOT NULL DEFAULT 'created'
);

CREATE INDEX IF NOT EXISTS idx_orders_buyer_id ON orders(buyer_id);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at);

CREATE TABLE IF NOT EXISTS order_items (
  order_item_id        BIGSERIAL PRIMARY KEY,
  order_id             BIGINT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
  quantity             INT NOT NULL CHECK (quantity > 0),
  source_cart_item_id  BIGINT REFERENCES cart_items(cart_item_id) ON DELETE SET NULL,
  price_snapshot       NUMERIC(12,2) NOT NULL CHECK (price_snapshot >= 0)
);

CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);

CREATE TABLE IF NOT EXISTS payment_methods (
  payment_method_id BIGSERIAL PRIMARY KEY,
  name              TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS payments (
  payment_id        BIGSERIAL PRIMARY KEY,
  order_id          BIGINT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
  payment_method_id BIGINT NOT NULL REFERENCES payment_methods(payment_method_id) ON DELETE RESTRICT,
  card_id           BIGINT REFERENCES user_cards(card_id) ON DELETE SET NULL,
  amount            NUMERIC(12,2) NOT NULL CHECK (amount >= 0),
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_payments_order_id ON payments(order_id);

-- 11) Отзывы
CREATE TABLE IF NOT EXISTS reviews (
  review_id   BIGSERIAL PRIMARY KEY,
  buyer_id    BIGINT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  product_id  BIGINT NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
  rating      SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment     TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (buyer_id, product_id)
);

CREATE INDEX IF NOT EXISTS idx_reviews_product_id ON reviews(product_id);

-- SEED (минимально полезное)
INSERT INTO roles(name) VALUES ('admin'), ('buyer'), ('seller')
ON CONFLICT (name) DO NOTHING;

INSERT INTO payment_methods(name) VALUES ('card'), ('cash')
ON CONFLICT (name) DO NOTHING;

INSERT INTO list_types(list_type_name) VALUES ('cart'), ('favorites'), ('later')
ON CONFLICT (list_type_name) DO NOTHING;

COMMIT;