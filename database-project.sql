-- =================================================================
-- Database Schema for Stock Trading Platform
-- This script creates and populates tables for a stock trading platform
-- including customers, stocks, orders, transactions, and portfolios
-- =================================================================

-- Clean up existing tables
DROP TABLE customers CASCADE CONSTRAINTS;
DROP TABLE stocks CASCADE CONSTRAINTS;
DROP TABLE orders CASCADE CONSTRAINTS;
DROP TABLE transactions CASCADE CONSTRAINTS;
DROP TABLE portfolio CASCADE CONSTRAINTS;
DROP TABLE currency CASCADE CONSTRAINTS;

-- =================================================================
-- Table Creation Section
-- Creates the core tables with appropriate constraints and relationships
-- =================================================================

-- Customer table stores user information and account details
CREATE TABLE customers (
    customer_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username VARCHAR2(50) UNIQUE NOT NULL,
    email VARCHAR2(100) UNIQUE NOT NULL,
    phone_number NUMBER(10) UNIQUE NOT NULL,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    registration_date DATE DEFAULT SYSDATE,
    account_balance NUMBER(15,2) DEFAULT 0 CHECK (account_balance >= 0),
    status VARCHAR2(20) DEFAULT 'ACTIVE',
    CONSTRAINT check_customer_status CHECK (status IN ('ACTIVE', 'SUSPENDED', 'CLOSED'))
);

-- Stocks table contains information about available stocks and their metrics
CREATE TABLE stocks (
    stock_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    symbol VARCHAR2(10) UNIQUE NOT NULL,
    company_name VARCHAR2(100) NOT NULL,
    sector VARCHAR2(50),
    current_price NUMBER(15,2) NOT NULL CHECK (current_price > 0),
    pe_ratio NUMBER(10,2),
    peg_ratio NUMBER(10,2),
    pbv_ratio NUMBER(10,2),
    debt_equity_ratio NUMBER(10,2),
    dividend_yield NUMBER(5,2),
    dividend_ex_date DATE,
    exchange VARCHAR2(20),
    sentiment_ratio NUMBER(3,2),
    CONSTRAINT check_exchange CHECK (exchange IN ('NYSE', 'NASDAQ', 'BVB'))
);

-- Orders table tracks all buy/sell orders
CREATE TABLE orders (
    order_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id NUMBER REFERENCES customers(customer_id),
    stock_id NUMBER REFERENCES stocks(stock_id),
    order_type VARCHAR2(4) CHECK (order_type IN ('BUY', 'SELL')),
    order_status VARCHAR2(20) DEFAULT 'PENDING',
    quantity NUMBER NOT NULL CHECK (quantity > 0),
    limit_price NUMBER(15,2) CHECK (limit_price > 0),
    order_date TIMESTAMP DEFAULT SYSTIMESTAMP,
    expiration_date TIMESTAMP,
    CONSTRAINT check_order_status CHECK (order_status IN ('PENDING', 'EXECUTED', 'CANCELLED', 'EXPIRED')),
    CONSTRAINT check_expiration CHECK (expiration_date > order_date)
);

-- Transactions table records executed trades
CREATE TABLE transactions (
    transaction_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id NUMBER REFERENCES orders(order_id),
    customer_id NUMBER REFERENCES customers(customer_id),
    stock_id NUMBER REFERENCES stocks(stock_id),
    transaction_type VARCHAR2(4),
    quantity NUMBER NOT NULL CHECK (quantity > 0),
    price NUMBER(15,2) NOT NULL CHECK (price > 0),
    transaction_date TIMESTAMP DEFAULT SYSTIMESTAMP,
    total_amount NUMBER(15,2) GENERATED ALWAYS AS (quantity * price) VIRTUAL,
    CONSTRAINT check_transaction_type CHECK (transaction_type IN ('BUY', 'SELL'))
);

-- Currency table for handling different currencies
CREATE TABLE currency (
    currency_code VARCHAR2(3) PRIMARY KEY,
    currency_name VARCHAR2(50) NOT NULL,
    symbol VARCHAR2(5),
    exchange_rate NUMBER(15, 4) CHECK (exchange_rate > 0)
);

-- Portfolio table tracks customer holdings
CREATE TABLE portfolio (
    portfolio_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id NUMBER REFERENCES customers(customer_id),
    stock_id NUMBER REFERENCES stocks(stock_id),
    quantity NUMBER NOT NULL CHECK (quantity >= 0),
    average_price NUMBER(15,2) NOT NULL CHECK (average_price > 0),
    total_value NUMBER(15,2) GENERATED ALWAYS AS (quantity * average_price) VIRTUAL,
    CONSTRAINT portfolio_unique UNIQUE (customer_id, stock_id)
);

-- =================================================================
-- Schema Modifications Section
-- Alters existing tables to accommodate new requirements
-- =================================================================

-- Modify phone number to accommodate international formats
ALTER TABLE customers
MODIFY phone_number VARCHAR2(15);

-- Remove sentiment ratio as it's not needed
ALTER TABLE stocks
DROP COLUMN sentiment_ratio;

-- Remove currency table as it's not being used
DROP TABLE currency CASCADE CONSTRAINTS;

-- =================================================================
-- Data Population Section
-- Inserts initial data into the tables
-- =================================================================

-- Insert customer data
INSERT INTO customers (username, email, phone_number, first_name, last_name, date_of_birth)
VALUES ('matei.anghel', 'anghelmatei23@stud.ase.ro', '+40721234567', 'Matei-Alexandru', 'Anghel', TO_DATE('2004-06-09', 'YYYY-MM-DD'));

INSERT INTO customers (username, email, phone_number, first_name, last_name, date_of_birth)
VALUES ('ana.maria', 'ana.maria@email.com', '+44781234567', 'Ana', 'Maria', TO_DATE('1995-05-15', 'YYYY-MM-DD'));

INSERT INTO customers (username, email, phone_number, first_name, last_name, date_of_birth)
VALUES ('andrei.mihai', 'andrei.mihai@email.com', '+16171234567', 'Andrei', 'Mihai', TO_DATE('1990-09-22', 'YYYY-MM-DD'));

INSERT INTO customers (username, email, phone_number, first_name, last_name, date_of_birth)
VALUES ('raluca.ioana', 'raluca.ioana@email.com', '+81321234567', 'Raluca', 'Ioana', TO_DATE('1988-03-10', 'YYYY-MM-DD'));

-- Insert stock data
INSERT INTO stocks (symbol, company_name, sector, current_price, pe_ratio, peg_ratio, pbv_ratio, debt_equity_ratio, dividend_yield, dividend_ex_date, exchange)
VALUES ('AAPL', 'Apple Inc.', 'Technology', 175.50, 28.74, 2.89, 40.23, 1.56, 0.58, TO_DATE('2025-02-15', 'YYYY-MM-DD'), 'NASDAQ');

INSERT INTO stocks (symbol, company_name, sector, current_price, pe_ratio, peg_ratio, pbv_ratio, debt_equity_ratio, dividend_yield, dividend_ex_date, exchange)
VALUES ('MSFT', 'Microsoft Corporation', 'Technology', 350.75, 33.25, 2.47, 14.12, 0.92, 0.88, TO_DATE('2025-03-10', 'YYYY-MM-DD'), 'NASDAQ');

INSERT INTO stocks (symbol, company_name, sector, current_price, pe_ratio, peg_ratio, pbv_ratio, debt_equity_ratio, dividend_yield, dividend_ex_date, exchange)
VALUES ('JPM', 'JPMorgan Chase', 'Financials', 145.00, 10.78, 1.35, 1.48, 1.91, 2.95, TO_DATE('2025-02-28', 'YYYY-MM-DD'), 'NYSE');

INSERT INTO stocks (symbol, company_name, sector, current_price, pe_ratio, peg_ratio, pbv_ratio, debt_equity_ratio, dividend_yield, dividend_ex_date, exchange)
VALUES ('SNP', 'OMV Petrom', 'Energy', 0.50, 5.67, 0.84, 0.75, 0.42, 3.50, TO_DATE('2025-01-25', 'YYYY-MM-DD'), 'BVB');

-- Update customer balances
UPDATE customers
SET account_balance = 90000.00
WHERE username = 'matei.anghel';

UPDATE customers
SET account_balance = 140000.00
WHERE username = 'ana.maria';

UPDATE customers
SET account_balance = 57000.00
WHERE username = 'andrei.mihai';

UPDATE customers
SET account_balance = 324000.00
WHERE username = 'raluca.ioana';

-- Insert orders
INSERT INTO orders (customer_id, stock_id, order_type, quantity, limit_price)
SELECT c.customer_id, s.stock_id, 'BUY', 10, 175.50
FROM customers c, stocks s
WHERE c.username = 'matei.anghel' AND s.symbol = 'AAPL';

INSERT INTO orders (customer_id, stock_id, order_type, quantity, limit_price)
SELECT c.customer_id, s.stock_id, 'BUY', 15, 350.75
FROM customers c, stocks s
WHERE c.username = 'ana.maria' AND s.symbol = 'MSFT';

INSERT INTO orders (customer_id, stock_id, order_type, quantity, limit_price)
SELECT c.customer_id, s.stock_id, 'BUY', 100, 0.50
FROM customers c, stocks s
WHERE c.username = 'raluca.ioana' AND s.symbol = 'SNP';

-- Insert transactions
INSERT INTO transactions (order_id, customer_id, stock_id, transaction_type, quantity, price)
SELECT o.order_id, o.customer_id, o.stock_id, o.order_type, o.quantity, o.limit_price
FROM orders o
WHERE o.order_id = 1;

INSERT INTO transactions (order_id, customer_id, stock_id, transaction_type, quantity, price)
SELECT o.order_id, o.customer_id, o.stock_id, o.order_type, o.quantity, o.limit_price
FROM orders o
WHERE o.order_id = 2;

-- Update order statuses
UPDATE orders
SET order_status = 'EXECUTED'
WHERE order_id IN (1, 2);

-- Insert portfolio entries
INSERT INTO portfolio (customer_id, stock_id, quantity, average_price)
SELECT t.customer_id, t.stock_id, t.quantity, t.price
FROM transactions t
WHERE t.transaction_id = 1;

INSERT INTO portfolio (customer_id, stock_id, quantity, average_price)
SELECT t.customer_id, t.stock_id, t.quantity, t.price
FROM transactions t
WHERE t.transaction_id = 2;

-- Update customer balances after transactions
UPDATE customers c
SET account_balance = account_balance + (
    SELECT t.total_amount
    FROM transactions t
    WHERE t.customer_id = c.customer_id AND t.transaction_type = 'BUY'
)
WHERE c.customer_id IN (
    SELECT customer_id
    FROM transactions
    WHERE transaction_type = 'BUY'
);

-- =================================================================
-- Account Management Section
-- Handles customer account operations
-- =================================================================

-- Add new customer
INSERT INTO customers (username, email, phone_number, first_name, last_name, date_of_birth)
VALUES ('elena.mihaila', 'elena.mihaila@email.com', '+16171234568', 'Elena', 'Mihai', TO_DATE('1995-06-20', 'YYYY-MM-DD'));

-- Set initial balance
UPDATE customers
SET account_balance = 5000.00
WHERE username = 'elena.mihai';

-- Merge accounts
MERGE INTO customers c1
USING customers c2
ON (c1.username = 'andrei.mihai' AND c2.username = 'elena.mihai')
WHEN MATCHED THEN
    UPDATE SET c1.account_balance = c1.account_balance + c2.account_balance
    WHERE c1.username = 'andrei.mihai';
    
-- Close account
UPDATE customers
SET status = 'CLOSED'
WHERE username = 'elena.mihai';

-- Remove closed accounts
DELETE FROM customers
WHERE status = 'CLOSED';

-- =================================================================
-- Reporting and Analysis Section
-- Various queries for data analysis and reporting
-- =================================================================

-- Portfolio value by customer
SELECT c.first_name || ' ' || c.last_name AS full_name, SUM(p.total_value) AS portfolio_value
FROM customers c
INNER JOIN portfolio p 
ON c.customer_id = p.customer_id
GROUP BY c.first_name, c.last_name;

-- Find student accounts
SELECT username 
FROM customers 
WHERE email LIKE '%@stud.ase.ro';

-- Customers by balance
SELECT first_name, last_name, account_balance
FROM customers
WHERE account_balance <= 91755
ORDER BY first_name;

-- Upcoming dividends
SELECT symbol, company_name, TO_CHAR(dividend_ex_date, 'YYYY-MM-DD') AS ex_date
FROM stocks
WHERE dividend_ex_date BETWEEN SYSDATE AND SYSDATE + 30;

-- Recent registrations
SELECT first_name, last_name, TO_CHAR(registration_date, 'DD-Mon-YYYY') AS reg_date
FROM customers
WHERE registration_date > ADD_MONTHS(SYSDATE, -12);

-- Customers with no orders
SELECT c.username, c.first_name, c.last_name
FROM customers c
LEFT OUTER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- Order statistics by customer
SELECT c.username, COUNT(*) AS total_orders, 
       SUM(CASE WHEN o.order_type = 'BUY' THEN 1 ELSE 0 END) AS buy_orders,
       SUM(CASE WHEN o.order_type = 'SELL' THEN 1 ELSE 0 END) AS sell_orders
FROM customers c
LEFT OUTER JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.username, o.customer_id
HAVING COUNT(o.order_id) != 0;

-- Stocks by exchange
SELECT symbol, company_name, exchange
FROM stocks
WHERE exchange IN ('NASDAQ', 'NYSE');

-- Latest transaction by customer
SELECT t.transaction_id, t.customer_id, t.transaction_date
FROM transactions t
WHERE t.transaction_date = (
    SELECT MAX(t1.transaction_date)
    FROM transactions t1
    WHERE t1.customer_id = t.customer_id
);

-- =================================================================
-- Views and Synonyms Section
-- Creates database views and synonyms for simplified access
-- =================================================================

-- Create view for active customers
CREATE VIEW active_customers_view AS
SELECT customer_id, first_name, last_name, account_balance
FROM customers
WHERE status = 'ACTIVE';

-- Test view
SELECT * FROM active_customers_view;

-- Create synonym
CREATE SYNONYM active_c FOR active_customers_view;

-- =================================================================
-- Advanced Queries Section
-- Complex queries for specific business requirements
-- =================================================================

-- Check balance sufficiency for stock purchase
SELECT c.username, s.symbol, 
       CASE WHEN c.account_balance >= s.current_price * 10 THEN 'Sufficient Balance'
            ELSE 'Insufficient Balance'
       END AS balance_status
FROM customers c
JOIN stocks s ON s.symbol = 'AAPL'
WHERE c.username = 'matei.anghel';

-- Portfolios above average value
SELECT c.username, p.total_value
FROM customers c
JOIN portfolio p ON c.customer_id = p.customer_id
WHERE p.total_value > ANY (
    SELECT AVG(total_value)
    FROM portfolio
    GROUP BY customer_id
);

-- Calculate customer ages
SELECT username,
       EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM date_of_birth) as age
FROM customers;

-- Monthly transaction count
SELECT SUBSTR(TO_CHAR(transaction_date, 'MONTH'), 1, 3) as month,
       COUNT(*) as transaction_count
FROM transactions
GROUP BY SUBSTR(TO_CHAR(transaction_date, 'MONTH'), 1, 3);

-- Dividend dates in first half of 2025
SELECT symbol, company_name, TO_CHAR(dividend_ex_date, 'YYYY-MM-DD') AS dividend_date
FROM stocks
WHERE TO_DATE(TO_CHAR(dividend_ex_date, 'YYYY-MM-DD'), 'YYYY-MM-DD') 
BETWEEN TO_DATE('2025-01-01', 'YYYY-MM-DD') AND TO_DATE('2025-6-01', 'YYYY-MM-DD');

-- Classify stocks by price
SELECT symbol, company_name, current_price,
       DECODE(SIGN(current_price - 150), 1, 'Expensive', -1, 'Affordable') AS price_status
FROM stocks;

-- Stocks with lowest PE ratio in technology sector
SELECT symbol, company_name, pe_ratio
FROM stocks
WHERE pe_ratio < ALL (
    SELECT pe_ratio
    FROM stocks
    WHERE sector = 'Technology'
);

-- Combined customer activity report
SELECT c.first_name || ' ' || c.last_name AS customer_name, s.symbol
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN stocks s ON o.stock_id = s.stock_id
UNION
SELECT c.first_name || ' ' || c.last_name AS customer_name, s.symbol
FROM customers c
JOIN transactions t ON c.customer_id = t.customer_id
JOIN stocks s ON t.stock_id = s.stock_id;

-- Customers with orders but no transactions
SELECT c.first_name || ' ' || c.last_name as customer_name
FROM customers c
WHERE c.customer_id IN (
    SELECT o.customer_id
    FROM orders o
)
MINUS
SELECT c.first_name || ' ' || c.last_name as customer_name
FROM customers c
JOIN transactions t ON c.customer_id = t.customer_id;

-- Technology stocks with significant dividend yield
SELECT s.symbol, s.company_name
FROM stocks s
WHERE s.sector = 'Technology'
INTERSECT
SELECT s.symbol, s.company_name
FROM stocks s
WHERE s.dividend_yield > 0.6;

-- =================================================================
-- Performance Optimization Section
-- Creates indexes and sequences for improved performance
-- =================================================================

-- Create index for transaction dates
CREATE INDEX idx_transactions_date
ON transactions (transaction_date);

-- Create sequence for customer IDs
CREATE SEQUENCE seq_customer_id
START WITH 1000
INCREMENT BY 1;

-- =================================================================
-- Hierarchical Query Section
-- Implements manager-employee relationship structure
-- =================================================================

-- Add manager relationship
ALTER TABLE customers ADD (
    manager_id NUMBER REFERENCES customers(customer_id)
);

-- Set initial manager relationships
UPDATE customers
SET manager_id = 1
WHERE username IN ('ana.maria', 'andrei.mihai');

-- Query hierarchical path
SELECT customer_id, username, SYS_CONNECT_BY_PATH(username, ' -> ') AS path
FROM customers
START WITH manager_id IS NULL
CONNECT BY PRIOR customer_id = manager_id;

-- Show hierarchical level
SELECT customer_id, username, first_name || ' ' || last_name as customer_name, LEVEL, manager_id
FROM customers
START WITH manager_id IS NULL
CONNECT BY PRIOR customer_id = manager_id;