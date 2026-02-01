-- Delete all existing santiere and insert realistic sample data
-- Based on datesantiere.ro format
-- DELETE THIS FILE after deploy to prevent re-inserting data

TRUNCATE TABLE santiere;

INSERT INTO santiere (titlu, judet, adresa, valoare, domeniu, subdomeniu, descriere, solicitari, observatii, dimensiune, sector, stadiu) VALUES
('Reabilitare retea apa', 'Timis', 'Zona Plopis, Timisoara', '6.925.317 RON', 'Infrastructura', 'Utilitati', 'Reabilitare retea de apa, lungime 8.5 km', 'materiale pentru bransamente, tevi, conducte, prefabricate din beton, piatra sparta', 'Proiect finantat prin PNRR', 'Mare', 'Public', 'In proiectare'),

('Ansamblu rezidential XCity Towers', 'Timis', 'Calea Sagului nr. 127, Timisoara', '45 milioane RON', 'Rezidential', 'Cladiri', 'Complex rezidential cu 2 turnuri: S+P+10E si S+P+15E, 320 apartamente', 'beton, fier beton, caramida, finisaje, instalatii termice, instalatii sanitare, instalatii electrice', 'Dezvoltator: Impact Developer & Contractor', 'Mare', 'Privat', 'In executie'),

('Ansamblul rezidential Sisesti Site', 'Ilfov', 'Sisesti, comuna Tunari', '180 milioane RON', 'Rezidential', 'Ansamblu rezidential', 'Ansamblu rezidential pe 480.000 mp, 1200 unitati', 'antreprenoriat general, materiale pentru constructii, infrastructura', 'Etapizare: 5 faze pe 8 ani', 'Mare', 'Privat', 'In proiectare'),

('Ansamblul Timpuri Noi Offices', 'Bucuresti', 'Bulevardul Unirii nr. 45, Sector 3', '65 milioane RON', 'Comercial', 'Birouri', 'Complex de birouri clasa A, 50.000 mp, S+P+13E', 'fier beton, caramida, tamplarie, finisaje interioare si exterioare, fatada sticla', 'Certificare LEED Gold', 'Mare', 'Privat', 'In executie'),

('Locuinta unifamiliala', 'Alba', 'Str. Libertatii nr. 23, Alba Iulia', '450.000 RON', 'Rezidential', 'Case', 'Casa D+P, 180 mp construiti', 'beton, fier beton, caramida, tamplarie PVC, termosisteme, sapa, finisaje interioare si exterioare', 'Teren 600 mp', 'Mic', 'Privat', 'In executie'),

('Locuinta P+1E', 'Suceava', 'Str. Caisului nr. 8, Suceava', '380.000 RON', 'Rezidential', 'Case', 'Casa P+1E, suprafata utila 240 mp', 'executie, beton, fier beton, caramida, termosisteme, tamplarie PVC, finisaje, sapa', 'Fundatie executata', 'Mic', 'Privat', 'In proiectare'),

('Clinica stomatologica', 'Dambovita', 'Bulevardul Unirii nr. 156, Targoviste', '2.8 milioane RON', 'Sanatate', 'Clinici', 'Clinica stomatologica cu 15 cabinete, P+2E', 'beton, fier, caramida, tamplarie, fatada ventilata, hidroizolatii, instalatii medicale', 'Aviz DSP in curs de obtinere', 'Mediu', 'Privat', 'In proiectare'),

('Construire centru de recuperare', 'Valcea', 'Str. Traian nr. 67, Ramnicu Valcea', '2.529.804 RON', 'Sanatate', 'Centre recuperare', 'Centru de recuperare si reabilitare, P+1E, 800 mp', 'beton, fier beton, caramida, termosisteme, tamplarie PVC, finisaje, sapa, lavabile, gleturi, vopsitorie', 'Finantare europeana', 'Mediu', 'Public', 'In proiectare'),

('Scoala de soferi', 'Teleorman', 'Str. Mihai Viteazu nr. 12, Alexandria', '680.000 RON', 'Educatie', 'Amenajari', 'Amenajare scoala soferi in cladire P+1E existenta', 'finisaje interioare, pardoseli, corpuri de iluminat, vopsele, dotari didactice', 'Cladire preluata prin licitatie', 'Mic', 'Privat', 'In amenajare'),

('Imobil rezidential', 'Ilfov', 'Str. Pacii nr. 34, Voluntari', '4.5 milioane RON', 'Rezidential', 'Cladiri', 'Bloc 2S+P+3E, 24 apartamente', 'executie, caramida, tamplarie, hidroizolatii, finisaje, termoizolatie', 'Garaj subteran 30 locuri', 'Mediu', 'Privat', 'In executie'),

('Modernizare strada principala', 'Cluj', 'Strada Observatorului, Cluj-Napoca', '3.8 milioane RON', 'Infrastructura', 'Drumuri', 'Reabilitare strada 2.4 km, asfalt, borduri, trotuare, iluminat', 'asfalt, piatra sparta, borduri, pavele, iluminat public', 'Contract semnat cu Primaria Cluj', 'Mare', 'Public', 'In executie'),

('Hala industriala', 'Brasov', 'Zona Industriala Bartolomeu, Brasov', '5.2 milioane RON', 'Industrial', 'Hale', 'Hala productie 4500 mp, inaltime 10m, pod rulant', 'structura metalica, panouri sandwich, fundatii speciale, instalatii industriale', 'Pod rulant 20 tone', 'Mare', 'Privat', 'In executie'),

('Extindere spital judetean', 'Iasi', 'Str. Independentei nr. 1, Iasi', '28 milioane RON', 'Sanatate', 'Spitale', 'Corp nou S+P+4E, sectii chirurgie si ATI', 'beton, fier beton, caramida, tamplarie, instalatii medicale, lift, finisaje speciale', 'Finantare Ministerul Sanatatii', 'Mare', 'Public', 'In licitatie'),

('Parcare supraterana', 'Constanta', 'Strada Soveja, Constanta', '6.5 milioane RON', 'Infrastructura', 'Parcari', 'Parcare 4 niveluri, 380 locuri', 'beton armat, rampe acces, sistem plata, supraveghere video, iluminat', 'Acces strada Soveja si Traian', 'Mare', 'Public', 'In proiectare'),

('Vila duplex', 'Bucuresti', 'Str. Aviatorilor nr. 78, Sector 1', '1.8 milioane RON', 'Rezidential', 'Case', 'Vila duplex P+1+M, 2 unitati locative', 'beton, fier beton, caramida, tamplarie lemn stratificat, termosistem, finisaje premium', 'Teren 450 mp, arhitectura moderna', 'Mediu', 'Privat', 'In executie'),

('Modernizare retea canalizare', 'Sibiu', 'Cartier Terezian, Sibiu', '4.2 milioane RON', 'Infrastructura', 'Canalizare', 'Inlocuire retea canalizare 6.8 km, statii pompare', 'tevi PVC, statii pompare, capace carosabile, excavatii', 'Proiect finalizat 70%', 'Mare', 'Public', 'In executie'),

('Hotel 3 stele', 'Brasov', 'Strada Republicii nr. 45, Brasov', '8.5 milioane RON', 'Turism', 'Hoteluri', 'Hotel 80 camere, restaurant, sala conferinte', 'beton, fier beton, caramida, tamplarie, finisaje, instalatii HVAC, lift', 'Clasificare turistica in curs', 'Mare', 'Privat', 'In executie'),

('Gradinita 4 grupe', 'Cluj', 'Str. Florilor nr. 23, Floresti', '2.9 milioane RON', 'Educatie', 'Gradinite', 'Gradinita P+1, 120 copii, curte 800 mp', 'beton, fier beton, caramida, tamplarie, termosistem, finisaje, dotari', 'Finantare buget local', 'Mediu', 'Public', 'In proiectare'),

('Showroom auto', 'Bucuresti', 'Soseaua Pipera nr. 234, Sector 2', '3.5 milioane RON', 'Comercial', 'Showroom', 'Showroom cu service, P+1E, 1200 mp', 'structura metalica, fatada sticla, pardoseli industriale, instalatii', 'Brand premium auto', 'Mediu', 'Privat', 'In executie'),

('Modernizare pod peste Olt', 'Valcea', 'DN7, km 189, Ramnicu Valcea', '15.8 milioane RON', 'Infrastructura', 'Poduri', 'Consolidare si reabilitare pod, lungime 280m', 'beton special, sisteme protectie anticoroziva, hidroizolatii pod, asfalt', 'Finantare CNAIR, trafic deviat', 'Mare', 'Public', 'In executie');
