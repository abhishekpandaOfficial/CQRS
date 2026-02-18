📘 PART III — CQRS Pattern
Chapter 4 — Phase 0 — Local Infrastructure Setup
    Kafka + Postgres for CQRS (.NET 10)
    🎯 Objective of Phase 0

    Before implementing CQRS logic, we must prepare:

    ✅ Kafka broker (event streaming backbone)

    ✅ PostgreSQL (Write DB + Read DB)

    ✅ Kafka UI (debugging & monitoring)

    ✅ Outbox-ready schema

    ✅ Idempotency-ready schema

    By the end of this phase, you will have:

    Running infrastructure

    Separate Write & Read databases

    Kafka topic: catalog.events

    Ready environment for Phase 1

    ```mermaid
        flowchart TB
            KafkaUI["Kafka UI | localhost:8080"] --> Kafka[("Kafka Broker")]
            Postgres[("PostgreSQL")]

            Kafka:::broker
            Postgres:::db
            KafkaUI:::ui
            classDef broker fill:#FCE4EC,stroke:#C2185B,stroke-width:2px,color:#880E4F
            classDef db fill:#FFF3E0,stroke:#EF6C00,stroke-width:2px,color:#E65100
            classDef ui fill:#E3F2FD,stroke:#1E88E5,stroke-width:2px,color:#0D47A1

    ``` 
🛠 Prerequisites

Install:

.NET 10 SDK

Docker Desktop

Git

Verify installations:

dotnet --version
docker --version
git --version

📁 Step 1 — Create Project Structure

From your workspace:

mkdir cqrs-catalog
cd cqrs-catalog

mkdir -p infra/sql
mkdir docs
mkdir src


Final structure:

cqrs-catalog/
  infra/
    docker-compose.yml
    sql/
  docs/
  src/

🐳 Step 2 — Create docker-compose.yml

Create:

infra/docker-compose.yml

🗄 Step 3 — Create Database Initialization Scripts
3.1 Create DBs

Create:

infra/sql/00-create-dbs.sql

CREATE DATABASE catalog_write;
CREATE DATABASE catalog_read;

3.2 Write DB Schema

Create:

infra/sql/10-write-schema.sql


(Write-side normalized + Outbox)

\c catalog_write;

CREATE TABLE products (
  id UUID PRIMARY KEY,
  sku TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  description TEXT,
  price NUMERIC(18,2) NOT NULL,
  currency CHAR(3) NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  version INT NOT NULL DEFAULT 0
);

CREATE TABLE outbox_messages (
  id UUID PRIMARY KEY,
  aggregate_id UUID NOT NULL,
  event_type TEXT NOT NULL,
  occurred_at TIMESTAMPTZ NOT NULL,
  correlation_id UUID,
  payload JSONB NOT NULL,
  status TEXT NOT NULL DEFAULT 'Pending',
  attempts INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  published_at TIMESTAMPTZ
);

3.3 Read DB Schema

Create:

infra/sql/20-read-schema.sql

\c catalog_read;

CREATE TABLE catalog_product_read (
  product_id UUID PRIMARY KEY,
  sku TEXT NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  price NUMERIC(18,2) NOT NULL,
  currency CHAR(3) NOT NULL,
  is_active BOOLEAN NOT NULL,
  search_text TEXT NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE processed_events (
  event_id UUID PRIMARY KEY,
  event_type TEXT NOT NULL,
  processed_at TIMESTAMPTZ DEFAULT now()
);

▶ Step 4 — Start Infrastructure

From project root:

docker compose -f infra/docker-compose.yml up -d


Check running containers:

docker ps


You should see:

cqrs_postgres

cqrs_kafka

cqrs_zookeeper

cqrs_kafka_ui

📡 Step 5 — Create Kafka Topic

Create topic explicitly:

docker exec -it cqrs_kafka kafka-topics \
  --bootstrap-server localhost:9092 \
  --create \
  --topic catalog.events \
  --partitions 3 \
  --replication-factor 1


Verify:

docker exec -it cqrs_kafka kafka-topics \
  --bootstrap-server localhost:9092 \
  --list


Expected:

catalog.events

🔎 Step 6 — Verify Setup
Kafka UI

Open:

http://localhost:8080


You should see:

Cluster: local

Topic: catalog.events

Postgres Verification

List databases:

docker exec -it cqrs_postgres psql -U postgres -c "\l"


Check tables:

docker exec -it cqrs_postgres psql -U postgres -d catalog_write -c "\dt"
docker exec -it cqrs_postgres psql -U postgres -d catalog_read -c "\dt"

✅ What We Achieved in Phase 0
Component	Status
Kafka running	✅
Kafka topic created	✅
Postgres running	✅
Write DB created	✅
Read DB created	✅
Outbox table ready	✅
Idempotency table ready	✅
Kafka UI ready	✅
🧠 Why Phase 0 Matters Architecturally

We separated read & write databases

We introduced event backbone (Kafka)

We prepared reliability mechanism (Outbox)

We prepared idempotency mechanism (processed_events)

We established infrastructure parity with production patterns

This is real CQRS, not tutorial-level CRUD separation.