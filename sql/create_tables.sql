CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password_hash VARCHAR(255),
  salt VARCHAR(255),
  google_id VARCHAR(255),
  is_admin TINYINT(1) NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_name (name),
  INDEX idx_email (email),
  INDEX idx_google_id (google_id)
);

CREATE TABLE IF NOT EXISTS sessions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  session_id VARCHAR(64) UNIQUE NOT NULL,
  user_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP + INTERVAL 7 DAY),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_session_id (session_id)
);

CREATE TABLE IF NOT EXISTS password_resets (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  token VARCHAR(64) UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMP DEFAULT (CURRENT_TIMESTAMP + INTERVAL 1 HOUR),
  consumed BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_token (token)
);

CREATE TABLE IF NOT EXISTS santiere (
  id INT AUTO_INCREMENT PRIMARY KEY,
  titlu VARCHAR(255) NOT NULL,
  judet VARCHAR(100) NOT NULL,
  adresa TEXT,
  valoare VARCHAR(255),
  domeniu VARCHAR(100),
  subdomeniu VARCHAR(100),
  descriere TEXT,
  solicitari TEXT,
  observatii TEXT,
  dimensiune ENUM('Mic', 'Mediu', 'Mare') DEFAULT 'Mediu',
  sector ENUM('Public', 'Privat') DEFAULT 'Public',
  stadiu VARCHAR(100),
  
  -- Date de contact Beneficiar
  beneficiar_nume VARCHAR(255),
  beneficiar_persoana VARCHAR(255),
  beneficiar_contact VARCHAR(255),
  beneficiar_email VARCHAR(255),
  
  -- Date de contact Antreprenor
  antreprenor_nume VARCHAR(255),
  antreprenor_persoana VARCHAR(255),
  antreprenor_contact VARCHAR(255),
  antreprenor_email VARCHAR(255),
  
  -- Date de contact Proiectant
  proiectant_nume VARCHAR(255),
  proiectant_persoana VARCHAR(255),
  proiectant_contact VARCHAR(255),
  proiectant_email VARCHAR(255),
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX idx_judet (judet),
  INDEX idx_domeniu (domeniu),
  INDEX idx_subdomeniu (subdomeniu),
  INDEX idx_dimensiune (dimensiune),
  INDEX idx_stadiu (stadiu),
  INDEX idx_created_at (created_at),
  FULLTEXT idx_search (titlu, descriere, solicitari)
);

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

UPDATE users
SET is_admin = 1
WHERE email = 'dobreavlad@yahoo.com';
