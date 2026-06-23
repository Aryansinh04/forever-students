-- ============================================================
-- Working With Forever — MySQL Database Schema
-- Run this file in phpMyAdmin or: mysql -u root -p < database.sql
-- ============================================================

CREATE DATABASE IF NOT EXISTS forever_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE forever_db;

-- ────────────────────────────────
-- Users
-- ────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
    id            VARCHAR(36)  NOT NULL,
    name          VARCHAR(255) NOT NULL,
    email         VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role          ENUM('customer','admin') NOT NULL DEFAULT 'customer',
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_users_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ────────────────────────────────
-- Products
-- ────────────────────────────────
CREATE TABLE IF NOT EXISTS products (
    id          VARCHAR(36)    NOT NULL,
    name        VARCHAR(255)   NOT NULL,
    description TEXT,
    price       DECIMAL(12,2)  NOT NULL,
    currency    VARCHAR(10)    NOT NULL DEFAULT 'INR',
    category    VARCHAR(100)   NOT NULL DEFAULT 'General',
    trend       ENUM('up','down','stable') NOT NULL DEFAULT 'stable',
    image       VARCHAR(500)   DEFAULT NULL,
    in_stock    TINYINT(1)     NOT NULL DEFAULT 1,
    created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ────────────────────────────────
-- Carts
-- ────────────────────────────────
CREATE TABLE IF NOT EXISTS carts (
    id         VARCHAR(36) NOT NULL,
    user_id    VARCHAR(36) NOT NULL,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_carts_user (user_id),
    CONSTRAINT fk_carts_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ────────────────────────────────
-- Cart Items
-- ────────────────────────────────
CREATE TABLE IF NOT EXISTS cart_items (
    id         VARCHAR(36) NOT NULL,
    cart_id    VARCHAR(36) NOT NULL,
    product_id VARCHAR(36) NOT NULL,
    quantity   INT NOT NULL DEFAULT 1,
    PRIMARY KEY (id),
    UNIQUE KEY uq_cart_product (cart_id, product_id),
    CONSTRAINT fk_cart_items_cart    FOREIGN KEY (cart_id)    REFERENCES carts(id)    ON DELETE CASCADE,
    CONSTRAINT fk_cart_items_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ────────────────────────────────
-- Orders
-- ────────────────────────────────
CREATE TABLE IF NOT EXISTS orders (
    id               VARCHAR(36)   NOT NULL,
    user_id          VARCHAR(36)   NOT NULL,
    status           ENUM('placed','processing','shipped','delivered','cancelled') NOT NULL DEFAULT 'placed',
    payment_method   VARCHAR(20)   NOT NULL DEFAULT 'COD',
    shipping_address TEXT          NOT NULL,
    subtotal         DECIMAL(12,2) NOT NULL,
    tax              DECIMAL(12,2) NOT NULL,
    shipping         DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    total            DECIMAL(12,2) NOT NULL,
    currency         VARCHAR(10)   NOT NULL DEFAULT 'INR',
    created_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_orders_user FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ────────────────────────────────
-- Order Items (snapshot at purchase)
-- ────────────────────────────────
CREATE TABLE IF NOT EXISTS order_items (
    id         VARCHAR(36)   NOT NULL,
    order_id   VARCHAR(36)   NOT NULL,
    product_id VARCHAR(36)   NOT NULL,
    name       VARCHAR(255)  NOT NULL,
    price      DECIMAL(12,2) NOT NULL,
    currency   VARCHAR(10)   NOT NULL DEFAULT 'INR',
    quantity   INT           NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_order_items_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ────────────────────────────────
-- Careers / Applications
-- ────────────────────────────────
CREATE TABLE IF NOT EXISTS careers (
    id         VARCHAR(36)  NOT NULL,
    user_id    VARCHAR(36)  DEFAULT NULL,
    name       VARCHAR(255) NOT NULL,
    email      VARCHAR(255) NOT NULL,
    phone      VARCHAR(50)  DEFAULT NULL,
    interest   VARCHAR(255) DEFAULT NULL,
    experience TEXT         DEFAULT NULL,
    message    TEXT         DEFAULT NULL,
    status     ENUM('pending','reviewed','accepted','rejected') NOT NULL DEFAULT 'pending',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_careers_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ────────────────────────────────
-- Chat FAQs
-- ────────────────────────────────
CREATE TABLE IF NOT EXISTS chat_faqs (
    id       INT AUTO_INCREMENT NOT NULL,
    question TEXT NOT NULL,
    answer   TEXT NOT NULL,
    keywords VARCHAR(500) DEFAULT NULL,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ────────────────────────────────
-- Seed Data
-- ────────────────────────────────

-- Default Admin User
-- Password: Admin@123
-- IMPORTANT: Generate a fresh hash with: php -r "echo password_hash('Admin@123', PASSWORD_BCRYPT);"
-- Then replace the hash below before importing.
INSERT INTO users (id, name, email, password_hash, role) VALUES
('usr_admin000000001', 'Admin', 'admin@forever.com',
 '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin');
-- Note: above hash = 'password' — CHANGE IT! Run: php -r "echo password_hash('Admin@123', PASSWORD_BCRYPT);"

-- Default FAQs
INSERT INTO chat_faqs (question, answer, keywords) VALUES
('What is your return policy?',  'We accept returns within 30 days of delivery for unused items in original packaging.', 'return,refund,policy'),
('How do I track my order?',     'Log in and visit the Purchase History section to see your order status in real time.', 'track,order,status,shipping'),
('What payment methods do you accept?', 'We accept Cash on Delivery (COD), UPI, and Card payments.', 'payment,pay,COD,UPI,card'),
('How long does shipping take?', 'Standard shipping takes 3–7 business days depending on your location.', 'shipping,delivery,days,time'),
('Can I cancel my order?',       'Orders can be cancelled before they are shipped. Contact us immediately after placing your order.', 'cancel,order');
