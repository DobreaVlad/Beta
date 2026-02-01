# DateSantiere - Platforma de Santiere

## Structura Site-ului

Site-ul a fost restructurat pentru a se concentra pe santiere de constructii. Structura principala:

### Pagini Principale

1. **Homepage** (`/mason/index.html`)
   - Hero section cu statistici
   - Formular de cautare
   - CTA pentru inregistrare
   - Actiune: `/projects/` pentru cautare

2. **Pagina Santiere** (`/mason/projects/index.html`)
   - Lista santiere cu filtre
   - Sidebar cu filtre: judet, domeniu, subdomeniu, dimensiune, stadiu, sector
   - Grid de carduri santiere
   - Link catre pagina de detalii

3. **Detalii Santier** (`/mason/projects/view.html`)
   - Informatii complete despre santier
   - Contact beneficiar, antreprenor, proiectant (doar pentru utilizatori autentificati)
   - Badges pentru dimensiune si sector

### Structura Baza de Date

**Tabelul `santiere`:**

```sql
CREATE TABLE santiere (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titlu VARCHAR(500) NOT NULL,
    judet VARCHAR(100),
    adresa TEXT,
    valoare VARCHAR(200),
    domeniu VARCHAR(100),
    subdomeniu VARCHAR(100),
    descriere TEXT,
    solicitari TEXT,
    observatii TEXT,
    dimensiune ENUM('Mic','Mediu','Mare') DEFAULT 'Mediu',
    sector ENUM('Public','Privat') DEFAULT 'Public',
    stadiu VARCHAR(100),
    
    -- Beneficiar
    beneficiar_nume VARCHAR(300),
    beneficiar_persoana VARCHAR(200),
    beneficiar_contact VARCHAR(100),
    beneficiar_email VARCHAR(200),
    
    -- Antreprenor
    antreprenor_nume VARCHAR(300),
    antreprenor_persoana VARCHAR(200),
    antreprenor_contact VARCHAR(100),
    antreprenor_email VARCHAR(200),
    
    -- Proiectant
    proiectant_nume VARCHAR(300),
    proiectant_persoana VARCHAR(200),
    proiectant_contact VARCHAR(100),
    proiectant_email VARCHAR(200),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

**Indexuri:**
- Judet, domeniu, subdomeniu, dimensiune, stadiu
- FULLTEXT pe titlu, descriere, solicitari (pentru cautare rapida)

### Filtrare si Cautare

Parametri GET disponibili in `/projects/`:
- `search` - cautare text liber (titlu, descriere, solicitari)
- `judet` - filtru judet
- `domeniu` - filtru domeniu (Infrastructura, Cladiri, etc.)
- `subdomeniu` - filtru subdomeniu (Rutier, Civile, Comerciale, etc.)
- `dimensiune` - filtru dimensiune (Mic, Mediu, Mare)
- `stadiu` - filtru stadiu (Licitatie, Amenajare, Executie)
- `sector` - filtru sector (Public, Privat)

### Date de Test

Pentru a popula baza de date cu date de test:
```bash
mysql -u root -p datesantiere < sql/sample_santiere.sql
```

Fisierul contine 8 santiere exemplu din diverse judete, domenii si dimensiuni.

### Mobile Responsive

- Sidebar filtre devine mobile slide-in
- Layout grid se transforma in coloana singura
- Header devine hamburger menu pe mobile
- Toate formularele si cardurile sunt responsive

### Autentificare

- Informatiile de contact (beneficiar, antreprenor, proiectant) sunt vizibile DOAR pentru utilizatori autentificati
- Utilizatorii neautentificati vad un card "Login Required" cu buton de autentificare
- Autentificare prin modal popup (email/parola sau Google OAuth)

### Modificari Fata de Versiunea Anterioara

**Sterse:**
- Directorul `/properties/` - functionalitatile de proprietati imobiliare
- Directorul `/search/` - vechea pagina de cautare
- Link "Proprietati" din header/navigatie

**Adaugate:**
- Pagina santiere cu filtre complexe
- Pagina detalii santier
- Date de test pentru santiere
- Stiluri pentru carduri santiere
- Stiluri pentru pagina de detalii
- Responsive design pentru toate paginile noi

### Structura Fisiere

```
mason/
  ├── index.html                 # Homepage
  ├── projects/
  │   ├── index.html            # Lista santiere cu filtre
  │   └── view.html             # Detalii santier
  ├── includes/
  │   ├── header.html           # Header cu navigatie
  │   └── footer.html           # Footer cu scripturi
  ├── about/
  ├── contact/
  ├── pricing/
  ├── auth/                     # Autentificare (folosita pentru backend, frontend e modal)
  └── profile/

public/
  ├── css/
  │   └── styles.css           # Toate stilurile site-ului
  └── js/
      ├── auth-modal.js        # Modal autentificare
      └── mobile-menu.js       # Hamburger menu mobile

sql/
  ├── create_tables.sql        # Schema baza de date
  └── sample_santiere.sql      # Date de test
```

### Next Steps

1. Populati baza de date cu santiere reale
2. Implementati sistem de scraping pentru datesantiere.ro
3. Adaugati paginare pentru lista santiere
4. Adaugati sorting (dupa data, valoare, etc.)
5. Implementati salvare santiere favorite (pentru utilizatori autentificati)
6. Adaugati notificari pentru santiere noi

### API Endpoints (pentru viitor)

Potentiale endpoints pentru API:
- `GET /api/santiere` - lista santiere cu filtre
- `GET /api/santiere/:id` - detalii santier
- `GET /api/judete` - lista judete cu santiere
- `GET /api/domenii` - lista domenii
- `POST /api/santiere/favorite` - salveaza santier favorit
