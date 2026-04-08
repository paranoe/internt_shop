BEGIN;

ALTER TABLE category_parameters
ADD COLUMN IF NOT EXISTS podcategory_id BIGINT;

INSERT INTO category_parameters (podcategory_id, parameter_id, is_required)
SELECT
  p.podcategories_id,
  cp.parameter_id,
  cp.is_required
FROM category_parameters cp
JOIN podcategories p
  ON p.category_id = cp.category_id
WHERE cp.category_id IS NOT NULL
ON CONFLICT DO NOTHING;

ALTER TABLE category_parameters
DROP CONSTRAINT IF EXISTS category_parameters_pkey;

ALTER TABLE category_parameters
DROP CONSTRAINT IF EXISTS category_parameters_category_id_fkey;

DROP INDEX IF EXISTS idx_category_parameters_category_id;

ALTER TABLE category_parameters
DROP COLUMN IF EXISTS category_id;

ALTER TABLE category_parameters
ALTER COLUMN podcategory_id SET NOT NULL;

ALTER TABLE category_parameters
ADD CONSTRAINT category_parameters_pkey
PRIMARY KEY (podcategory_id, parameter_id);

ALTER TABLE category_parameters
ADD CONSTRAINT category_parameters_podcategory_id_fkey
FOREIGN KEY (podcategory_id)
REFERENCES podcategories(podcategories_id)
ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS idx_category_parameters_podcategory_id
ON category_parameters(podcategory_id);

COMMIT;