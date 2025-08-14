-- schema.sql
-- Relational schema for transactions analytics

-- PostgreSQL: drop tables if exist
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS merchants;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    id INT PRIMARY KEY,
    name VARCHAR(80) NOT NULL,
    signup_date DATE NOT NULL,
    city VARCHAR(50),
    state VARCHAR(50)
);

CREATE TABLE merchants (
    id INT PRIMARY KEY,
    name VARCHAR(80) NOT NULL,
    category VARCHAR(50) NOT NULL,
    city VARCHAR(50)
);

CREATE TABLE transactions (
    id INT PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id),
    merchant_id INT NOT NULL REFERENCES merchants(id),
    amount NUMERIC(10,2) NOT NULL CHECK (amount >= 0),
    payment_method VARCHAR(20) NOT NULL,
    txn_date DATE NOT NULL
);