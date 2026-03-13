DO $$
DECLARE
  cid int;
  sid int;
  pid int;
  lt_cart int;
  lt_fav int;
BEGIN
  -- category
  SELECT category_id INTO cid FROM categories WHERE name = 'Electronics' LIMIT 1;
  IF cid IS NULL THEN
    INSERT INTO categories(name) VALUES ('Electronics') RETURNING category_id INTO cid;
  END IF;

  -- seller
  SELECT seller_id INTO sid FROM sellers WHERE shop_name = 'Demo Shop' LIMIT 1;
  IF sid IS NULL THEN
    INSERT INTO sellers(shop_name, description, inn, url)
    VALUES ('Demo Shop', 'Seed seller', '0000000000', 'https://example.com')
    RETURNING seller_id INTO sid;
  END IF;

  -- product
  SELECT product_id INTO pid FROM products WHERE name = 'iPhone Demo' AND seller_id = sid LIMIT 1;
  IF pid IS NULL THEN
    INSERT INTO products(category_id, seller_id, name, description, price, quantity, created_at, currency)
    VALUES (cid, sid, 'iPhone Demo', 'Seed product for dev', 999.99, 10, now(), 'RUB')
    RETURNING product_id INTO pid;
  END IF;

  -- list types (optional)
  SELECT list_type_id INTO lt_cart FROM list_types WHERE list_type_name = 'cart' LIMIT 1;
  IF lt_cart IS NULL THEN
    INSERT INTO list_types(list_type_name) VALUES ('cart') RETURNING list_type_id INTO lt_cart;
  END IF;

  SELECT list_type_id INTO lt_fav FROM list_types WHERE list_type_name = 'favorites' LIMIT 1;
  IF lt_fav IS NULL THEN
    INSERT INTO list_types(list_type_name) VALUES ('favorites') RETURNING list_type_id INTO lt_fav;
  END IF;

  RAISE NOTICE 'Seed OK: category_id=%, seller_id=%, product_id=%', cid, sid, pid;
END $$;
-- =========================
-- Pickup points seed (dev)
-- =========================
DO $$
DECLARE
  v_city_id bigint;
  v_pickup_id bigint;
BEGIN
  -- 1) City
  INSERT INTO cities (city_name)
  VALUES ('Moscow')
  ON CONFLICT (city_name) DO UPDATE SET city_name = EXCLUDED.city_name
  RETURNING city_id INTO v_city_id;

  -- если ON CONFLICT сделал UPDATE, RETURNING может не сработать в старых схемах,
  -- поэтому подстрахуемся:
  IF v_city_id IS NULL THEN
    SELECT city_id INTO v_city_id FROM cities WHERE city_name = 'Moscow';
  END IF;

  -- 2) Pickup points (минимально под твою структуру: только city_id)
  INSERT INTO pickup_points (city_id)
  VALUES (v_city_id)
  RETURNING pickup_point_id INTO v_pickup_id;

  RAISE NOTICE 'Seed OK: city_id=%, pickup_point_id=%', v_city_id, v_pickup_id;
END $$;