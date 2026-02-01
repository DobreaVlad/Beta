# Ghid de Deployment în Producție

## Pregătire înainte de deployment

### 1. Backup Bază de Date
**OBLIGATORIU** - Creează backup complet al bazei de date de producție:

```bash
# Pe serverul de producție
mysqldump -u root -p datesantiere > backup_$(date +%Y%m%d_%H%M%S).sql

# Sau prin Docker
docker exec mysql_container mysqldump -u root -p datesantiere > backup_$(date +%Y%m%d_%H%M%S).sql
```

### 2. Verificare fișiere necesare
Asigură-te că ai următoarele fișiere actualizate:
- `sql/migrate_to_production.sql` - script de migrare
- `sql/create_tables.sql` - schema completă (pentru instalări noi)
- `docker-compose.yml`
- `Dockerfile`
- Toate fișierele Mason actualizate

## Procedura de Deployment

### Opțiunea A: Migrare pe server existent (RECOMANDAT)

#### 1. Upload fișiere pe server
```bash
# Transferă fișierele actualizate
scp -r ./mason user@server:/var/www/html/
scp -r ./public user@server:/var/www/html/
scp -r ./lib user@server:/var/www/html/
scp ./sql/migrate_to_production.sql user@server:/tmp/
```

#### 2. Rulează migrarea bazei de date
```bash
# Conectează-te la server
ssh user@server

# Rulează scriptul de migrare
mysql -u root -p datesantiere < /tmp/migrate_to_production.sql
```

#### 3. Restart servicii
```bash
# Restart Apache/mod_perl
sudo systemctl restart apache2

# Sau dacă folosești Docker
docker-compose restart web
```

#### 4. Verificare
```bash
# Testează conexiunea la baza de date
mysql -u root -p -e "USE datesantiere; SHOW TABLES; DESCRIBE santiere;"

# Verifică site-ul în browser
curl http://your-domain.com
```

### Opțiunea B: Deployment Docker complet

#### 1. Pe serverul de producție
```bash
# Clone sau pull ultimele modificări
git pull origin main

# Sau upload manual toate fișierele
scp -r ./Beta user@server:/path/to/project/
```

#### 2. Oprește containerele existente (dacă există)
```bash
docker-compose down
```

#### 3. Backup volumele Docker
```bash
docker run --rm -v beta_db_data:/data -v $(pwd):/backup ubuntu tar czf /backup/db_backup_$(date +%Y%m%d).tar.gz /data
```

#### 4. Rulează migrarea
```bash
# Pornește doar MySQL
docker-compose up -d db

# Așteaptă 10 secunde pentru inițializare
sleep 10

# Rulează migrarea
docker exec -i beta_db mysql -u root -proot datesantiere < sql/migrate_to_production.sql
```

#### 5. Pornește toate serviciile
```bash
docker-compose up -d
```

#### 6. Verifică logs
```bash
docker-compose logs -f
```

## Verificări Post-Deployment

### 1. Verificare Bază de Date
```sql
-- Conectează-te la MySQL
mysql -u root -p datesantiere

-- Verifică structura tabelelor
SHOW TABLES;
DESCRIBE santiere;
DESCRIBE subscriptions;
DESCRIBE payments;

-- Verifică datele existente
SELECT COUNT(*) FROM santiere;
SELECT COUNT(*) FROM users;
```

### 2. Verificare Funcționalitate Site

- [ ] Pagina principală se încarcă: `http://your-domain.com`
- [ ] Pagina santiere: `http://your-domain.com/projects/`
- [ ] Funcționează filtrele și căutarea
- [ ] Sortarea funcționează corect
- [ ] Tag-urile pentru filtre apar când sunt active
- [ ] Login/Register funcționează
- [ ] Panoul admin funcționează: `http://your-domain.com/admin/`
- [ ] Adăugare/editare santiere funcționează

### 3. Test Filtre și Sortare
```
1. Accesează /projects/
2. Aplică un filtru (județ, domeniu, etc.)
3. Verifică că tag-urile apar sub numărul de rezultate
4. Click pe X pentru a șterge un filtru
5. Click pe headerele tabelului pentru sortare (în admin)
6. Verifică că sortarea funcționează corect
```

## Rollback în caz de probleme

### 1. Rollback Bază de Date
```bash
# Restaurează backup-ul
mysql -u root -p datesantiere < backup_YYYYMMDD_HHMMSS.sql
```

### 2. Rollback Fișiere
```bash
# Restaurează versiunea anterioară din Git
git checkout HEAD~1
docker-compose restart
```

### 3. Rollback Docker complet
```bash
# Oprește containerele
docker-compose down

# Restaurează volumul bazei de date
docker run --rm -v beta_db_data:/data -v $(pwd):/backup ubuntu tar xzf /backup/db_backup_YYYYMMDD.tar.gz -C /

# Repornește cu versiunea veche
docker-compose up -d
```

## Configurare Variabile de Mediu (Producție)

### 1. Actualizează docker-compose.yml pentru producție
```yaml
version: '3.8'
services:
  db:
    environment:
      - MYSQL_ROOT_PASSWORD=${DB_ROOT_PASSWORD}
      - MYSQL_DATABASE=${DB_NAME}
  
  web:
    environment:
      - DB_HOST=db
      - DB_NAME=${DB_NAME}
      - DB_USER=${DB_USER}
      - DB_PASS=${DB_PASSWORD}
      - STRIPE_SECRET_KEY=${STRIPE_SECRET_KEY}
      - STRIPE_WEBHOOK_SECRET=${STRIPE_WEBHOOK_SECRET}
```

### 2. Creează fișier .env
```bash
cat > .env << EOF
DB_ROOT_PASSWORD=your_secure_password
DB_NAME=datesantiere
DB_USER=root
DB_PASSWORD=your_secure_password
STRIPE_SECRET_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...
EOF
```

## Monitorizare Post-Deployment

### 1. Monitorizează Logs
```bash
# Docker logs
docker-compose logs -f web

# Apache logs (dacă nu folosești Docker)
tail -f /var/log/apache2/error.log
tail -f /var/log/apache2/access.log
```

### 2. Monitorizează Performance
```bash
# Check MySQL queries
docker exec -it beta_db mysql -u root -p -e "SHOW PROCESSLIST;"

# Check disk space
df -h

# Check memory
free -h
```

## Checklist Final

- [ ] Backup bază de date creat și verificat
- [ ] Migrare rulată cu succes
- [ ] Toate tabelele au structura corectă
- [ ] Datele existente sunt intacte
- [ ] Site-ul se încarcă corect
- [ ] Toate funcționalitățile sunt testate
- [ ] Logs arată fără erori
- [ ] Performance este acceptabil
- [ ] Backup stocat în loc sigur
- [ ] Documentația actualizată

## Suport

În caz de probleme:
1. Verifică logs: `docker-compose logs -f`
2. Verifică baza de date: `docker exec -it beta_db mysql`
3. Verifică permisiuni fișiere
4. Rollback la versiunea anterioară dacă e necesar

## Note Importante

- **ÎNTOTDEAUNA** creează backup înainte de deployment
- Testează mai întâi pe un environment de staging
- Monitorizează logs după deployment
- Păstrează backup-urile pentru minim 30 de zile
- Documentează orice modificări specifice serverului tău
