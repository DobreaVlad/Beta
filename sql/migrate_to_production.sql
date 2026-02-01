-- Database Migration Script
-- This file is deprecated for Railway deployment
-- For new Railway deployments, use create_tables.sql instead
-- 
-- This file is kept only for reference or manual migrations
-- from old production environments

-- For Railway: Simply run create_tables.sql on your Railway MySQL instance
-- mysql -h <DB_HOST> -u root -p<DB_PASS> railway < sql/create_tables.sql


-- 9. Create subscriptions table if not exists
CREATE TABLE IF NOT EXISTS subscriptions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  plan_type ENUM('basic', 'professional', 'enterprise') NOT NULL,
  status ENUM('active', 'pending', 'cancelled', 'expired') NOT NULL DEFAULT 'pending',
  price DECIMAL(10,2) NOT NULL,
  currency VARCHAR(3) DEFAULT 'usd',
  start_date TIMESTAMP NULL,
  end_date TIMESTAMP NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id),
  INDEX idx_status (status)
);

-- 10. Create payments table if not exists
CREATE TABLE IF NOT EXISTS payments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  subscription_id INT NULL,
  payment_method VARCHAR(50) DEFAULT 'stripe',
  stripe_session_id VARCHAR(255) UNIQUE,
  amount DECIMAL(10,2) NOT NULL,
  currency VARCHAR(3) DEFAULT 'usd',
  status ENUM('pending', 'completed', 'failed', 'refunded') NOT NULL DEFAULT 'pending',
  payment_data TEXT,
  error_message TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (subscription_id) REFERENCES subscriptions(id) ON DELETE SET NULL,
  INDEX idx_user_id (user_id),
  INDEX idx_stripe_session_id (stripe_session_id),
  INDEX idx_status (status)
);

-- 11. Verification queries (optional - comment out before running)
-- SELECT COUNT(*) as total_santiere FROM santiere;
-- SELECT COUNT(*) as total_users FROM users;
-- SELECT COUNT(*) as total_subscriptions FROM subscriptions;
-- SHOW COLUMNS FROM santiere;

-- Migration completed successfully!
