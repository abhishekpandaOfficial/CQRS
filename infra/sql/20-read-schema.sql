\c catalog_read;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Read model (denormalized for fast queries)
CREATE TABLE IF NOT EXISTS catalog_product_read (
  product_id UUID PRIMARY KEY,
  sku TEXT NOT NULL,
  name TEXT NOT NULL,
  description TEXT NULL,
  price NUMERIC(18,2) NOT NULL,
  currency CHAR(3) NOT NULL,
  is_active BOOLEAN NOT NULL,

  -- query helpers
  search_text TEXT NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_catalog_search_text
ON catalog_product_read USING GIN (to_tsvector('simple', search_text));

CREATE INDEX IF NOT EXISTS ix_catalog_price
ON catalog_product_read (price);

CREATE INDEX IF NOT EXISTS ix_catalog_active
ON catalog_product_read (is_active);

-- Idempotency table to ensure "exactly-once effect"
CREATE TABLE IF NOT EXISTS processed_events (
  event_id UUID PRIMARY KEY,
  event_type TEXT NOT NULL,
  processed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Optional: capture failures for debugging (mini-DLQ in DB)
CREATE TABLE IF NOT EXISTS projection_failures (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  event_id UUID NULL,
  event_type TEXT NULL,
  payload JSONB NULL,
  error TEXT NOT NULL,
  failed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
