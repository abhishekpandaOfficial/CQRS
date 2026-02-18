\c catalog_write;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Write-side table (normalized)
CREATE TABLE IF NOT EXISTS products (
  id UUID PRIMARY KEY,
  sku TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  description TEXT NULL,
  price NUMERIC(18,2) NOT NULL,
  currency CHAR(3) NOT NULL DEFAULT 'INR',
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  version INT NOT NULL DEFAULT 0
);

CREATE INDEX IF NOT EXISTS ix_products_name ON products (name);

-- Outbox table (reliable event publishing)
CREATE TABLE IF NOT EXISTS outbox_messages (
  id UUID PRIMARY KEY,
  aggregate_id UUID NOT NULL,
  event_type TEXT NOT NULL,
  event_version INT NOT NULL DEFAULT 1,
  occurred_at TIMESTAMPTZ NOT NULL,
  correlation_id UUID NULL,
  payload JSONB NOT NULL,

  status TEXT NOT NULL DEFAULT 'Pending', -- Pending | Published | Failed
  attempts INT NOT NULL DEFAULT 0,
  last_error TEXT NULL,
  next_attempt_at TIMESTAMPTZ NULL,

  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  published_at TIMESTAMPTZ NULL
);

CREATE INDEX IF NOT EXISTS ix_outbox_status_next_attempt
ON outbox_messages (status, next_attempt_at);

CREATE INDEX IF NOT EXISTS ix_outbox_occurred
ON outbox_messages (occurred_at);
