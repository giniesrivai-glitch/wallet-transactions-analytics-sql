# wallet-transactions-analytics-sql
This project simulates wallet/UPI transactions in an Indian fintech context, using synthetic self-generated data.  
It demonstrates relational schema design, realistic seed data, and SQL analytics queries for common business insights.

## Features
- **Schema Design**: Users, Merchants, Transactions tables
- **Seed Data**: 40+ users, 12 merchants, 260+ transactions
- **Analytics Queries**:
  - GMV calculation
  - Monthly transaction trends
  - Top merchants by sales
  - Repeat customer detection
  - State-wise performance

## Tech
- PostgreSQL (recommended) / MySQL
- Pure SQL — no external libraries
- Fully synthetic data, authored from scratch

## How to Run
```bash
psql -d wallet_demo -f schema.sql
psql -d wallet_demo -f inserts.sql
psql -d wallet_demo -f analysis_queries.sql
