-- Proposed PostgreSQL schema for production BizLens SaaS.
-- This schema is a starting point and should be reviewed before production use.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE tenants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  business_type TEXT,
  base_currency CHAR(3) NOT NULL DEFAULT 'INR',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT NOT NULL UNIQUE,
  display_name TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE tenant_memberships (
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('owner','admin','analyst','viewer')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (tenant_id, user_id)
);

CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  sku TEXT,
  name TEXT NOT NULL,
  category TEXT,
  unit_of_measure TEXT NOT NULL DEFAULT 'unit',
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, sku)
);

CREATE TABLE sales_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  external_transaction_id TEXT,
  transaction_date DATE NOT NULL,
  product_id UUID REFERENCES products(id) ON DELETE SET NULL,
  product_name_snapshot TEXT NOT NULL,
  sku_snapshot TEXT,
  category_snapshot TEXT,
  region TEXT,
  channel TEXT,
  quantity NUMERIC(16,3) NOT NULL CHECK (quantity >= 0),
  returned_quantity NUMERIC(16,3) NOT NULL DEFAULT 0 CHECK (returned_quantity >= 0),
  unit_price NUMERIC(16,4) NOT NULL CHECK (unit_price >= 0),
  unit_cost NUMERIC(16,4) CHECK (unit_cost IS NULL OR unit_cost >= 0),
  discount_amount NUMERIC(16,4) NOT NULL DEFAULT 0 CHECK (discount_amount >= 0),
  tax_amount NUMERIC(16,4) NOT NULL DEFAULT 0 CHECK (tax_amount >= 0),
  shipping_amount NUMERIC(16,4) NOT NULL DEFAULT 0 CHECK (shipping_amount >= 0),
  currency CHAR(3) NOT NULL DEFAULT 'INR',
  source_import_id UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (returned_quantity <= quantity)
);

CREATE INDEX sales_tenant_date_idx ON sales_transactions (tenant_id, transaction_date);
CREATE INDEX sales_tenant_product_idx ON sales_transactions (tenant_id, product_id);
CREATE INDEX sales_tenant_region_idx ON sales_transactions (tenant_id, region);

CREATE TABLE import_jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  uploaded_by UUID REFERENCES users(id) ON DELETE SET NULL,
  original_filename TEXT NOT NULL,
  storage_key TEXT,
  status TEXT NOT NULL CHECK (status IN ('uploaded','validating','preview_ready','committed','failed')),
  total_rows INTEGER NOT NULL DEFAULT 0,
  accepted_rows INTEGER NOT NULL DEFAULT 0,
  rejected_rows INTEGER NOT NULL DEFAULT 0,
  error_summary JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  completed_at TIMESTAMPTZ
);

ALTER TABLE sales_transactions
  ADD CONSTRAINT sales_import_job_fk
  FOREIGN KEY (source_import_id) REFERENCES import_jobs(id) ON DELETE SET NULL;

CREATE TABLE audit_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  actor_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  event_type TEXT NOT NULL,
  entity_type TEXT,
  entity_id UUID,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX audit_tenant_created_idx ON audit_events (tenant_id, created_at DESC);

-- Production recommendation:
-- Enable Row Level Security on all tenant-owned tables and define policies using
-- a trusted, transaction-scoped tenant context set by the authenticated API.
-- Do not rely on a client-supplied tenant_id as authorization.
