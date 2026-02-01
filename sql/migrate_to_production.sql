-- Migration script for production database
-- This script safely updates the database schema without losing data

-- 1. Backup reminder
-- IMPORTANT: Always backup your database before running migrations!
-- mysqldump -u root -p datesantiere > backup_$(date +%Y%m%d_%H%M%S).sql

-- 2. Add new columns to santiere table if they don't exist
ALTER TABLE santiere 
ADD COLUMN IF NOT EXISTS subdomeniu VARCHAR(100) AFTER domeniu,
ADD COLUMN IF NOT EXISTS solicitari TEXT AFTER descriere,
ADD COLUMN IF NOT EXISTS observatii TEXT AFTER solicitari,
ADD COLUMN IF NOT EXISTS dimensiune ENUM('Mic', 'Mediu', 'Mare') DEFAULT 'Mediu' AFTER observatii,
ADD COLUMN IF NOT EXISTS sector ENUM('Public', 'Privat') DEFAULT 'Public' AFTER dimensiune,
ADD COLUMN IF NOT EXISTS stadiu VARCHAR(100) AFTER sector;

-- 3. Add contact fields for Beneficiar
ALTER TABLE santiere
ADD COLUMN IF NOT EXISTS beneficiar_nume VARCHAR(255) AFTER stadiu,
ADD COLUMN IF NOT EXISTS beneficiar_persoana VARCHAR(255) AFTER beneficiar_nume,
ADD COLUMN IF NOT EXISTS beneficiar_contact VARCHAR(255) AFTER beneficiar_persoana,
ADD COLUMN IF NOT EXISTS beneficiar_email VARCHAR(255) AFTER beneficiar_contact;

-- 4. Add contact fields for Antreprenor
ALTER TABLE santiere
ADD COLUMN IF NOT EXISTS antreprenor_nume VARCHAR(255) AFTER beneficiar_email,
ADD COLUMN IF NOT EXISTS antreprenor_persoana VARCHAR(255) AFTER antreprenor_nume,
ADD COLUMN IF NOT EXISTS antreprenor_contact VARCHAR(255) AFTER antreprenor_persoana,
ADD COLUMN IF NOT EXISTS antreprenor_email VARCHAR(255) AFTER antreprenor_contact;

-- 5. Add contact fields for Proiectant
ALTER TABLE santiere
ADD COLUMN IF NOT EXISTS proiectant_nume VARCHAR(255) AFTER antreprenor_email,
ADD COLUMN IF NOT EXISTS proiectant_persoana VARCHAR(255) AFTER proiectant_nume,
ADD COLUMN IF NOT EXISTS proiectant_contact VARCHAR(255) AFTER proiectant_persoana,
ADD COLUMN IF NOT EXISTS proiectant_email VARCHAR(255) AFTER proiectant_contact;

-- 6. Add updated_at timestamp if not exists
ALTER TABLE santiere
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER created_at;

-- 7. Add indexes for better performance
ALTER TABLE santiere
ADD INDEX IF NOT EXISTS idx_subdomeniu (subdomeniu),
ADD INDEX IF NOT EXISTS idx_dimensiune (dimensiune),
ADD INDEX IF NOT EXISTS idx_stadiu (stadiu);

-- 8. Add fulltext index for search functionality
ALTER TABLE santiere
ADD FULLTEXT INDEX IF NOT EXISTS idx_search (titlu, descriere, solicitari);

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
