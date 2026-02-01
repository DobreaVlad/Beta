-- Sample construction sites (santiere) for testing
-- This file will be run automatically on next deploy
-- DELETE THIS FILE after deploy to prevent re-inserting data

INSERT INTO santiere (titlu, judet, adresa, valoare, domeniu, subdomeniu, descriere, solicitari, dimensiune, sector, stadiu) VALUES
('Modernizare Strada Principala', 'Cluj', 'Strada Principala nr. 45, Cluj-Napoca', '2.5 milioane RON', 'Infrastructura', 'Drumuri', 'Modernizare complet strada cu asfaltare noua si trotuare', 'Autorizatie constructie, Aviz mediu', 'Mare', 'Public', 'In proiectare'),
('Constructie Bloc Rezidential', 'Bucuresti', 'Bulevardul Unirii nr. 123, Sector 3', '15 milioane RON', 'Rezidential', 'Cladiri', 'Bloc cu 120 apartamente, 10 etaje, 2 scari', 'Autorizatie constructie, Studiu geotehnic', 'Mare', 'Privat', 'In executie'),
('Reabilitare Scoala Generala', 'Timis', 'Str. Scolii nr. 5, Timisoara', '3.2 milioane RON', 'Educatie', 'Reabilitari', 'Reabilitare termica si modernizare instalatii', 'Expertiza tehnica, Aviz ISU', 'Mediu', 'Public', 'Finalizat'),
('Parc Industrial Vest', 'Arad', 'DN7, km 534, Arad', '45 milioane RON', 'Industrial', 'Dezvoltare', 'Parc industrial cu 15 hale si infrastructura completa', 'PUZ, Racorduri utilitati', 'Mare', 'Privat', 'In proiectare'),
('Centru Medical Policlinica', 'Iasi', 'Strada Pacurari nr. 78, Iasi', '8.5 milioane RON', 'Sanatate', 'Cladiri medicale', 'Policlinica cu 40 cabinete si laborator', 'Autorizatie sanitara, Aviz DSP', 'Mare', 'Privat', 'In executie'),
('Pod peste Raul Mures', 'Mures', 'DN15, km 23, Targu Mures', '12 milioane RON', 'Infrastructura', 'Poduri', 'Pod nou cu 3 benzi pe sens, lungime 450m', 'Studiu hidrotehnic, Aviz ANAR', 'Mare', 'Public', 'In licitatie'),
('Complex Comercial Plaza', 'Constanta', 'Bulevardul Mamaia nr. 267, Constanta', '22 milioane RON', 'Comercial', 'Mall-uri', 'Centru comercial cu 80 magazine si cinematograf', 'PUZ, Autorizatie ISU', 'Mare', 'Privat', 'In executie'),
('Canalizare Cartier Nou', 'Brasov', 'Cartier Tractorul, Brasov', '4.8 milioane RON', 'Utilitati', 'Canalizare', 'Retea canalizare menajera si pluviala 12 km', 'Aviz Apa Nova, Studiu impact', 'Mediu', 'Public', 'In proiectare'),
('Vila Unifamiliala Premium', 'Sibiu', 'Strada Florilor nr. 12, Cisnadie', '850.000 RON', 'Rezidential', 'Case', 'Vila P+1, 320 mp utili, arhitectura contemporana', 'Autorizatie constructie', 'Mic', 'Privat', 'In executie'),
('Modernizare Spital Judetean', 'Bihor', 'Str. Republicii nr. 35, Oradea', '18 milioane RON', 'Sanatate', 'Reabilitari', 'Reabilitare sectii chirurgie si ATI, dotari noi', 'Expertiza, Aviz Ministerul Sanatatii', 'Mare', 'Public', 'In licitatie'),
('Depozit Logistic', 'Prahova', 'DN1, km 87, Ploiesti', '6.5 milioane RON', 'Industrial', 'Depozite', 'Hala depozitare 8000 mp, inaltime 12m', 'Autorizatie constructie, Aviz mediu', 'Mare', 'Privat', 'Finalizat'),
('Parcari Subterane Centru', 'Cluj', 'Piata Unirii, Cluj-Napoca', '9.8 milioane RON', 'Infrastructura', 'Parcari', 'Parcare subterana 3 niveluri, 450 locuri', 'Studiu geotehnic, PUZ', 'Mare', 'Public', 'In proiectare'),
('Hotel 4 Stele Business', 'Bucuresti', 'Calea Victoriei nr. 156, Sector 1', '25 milioane RON', 'Turism', 'Hoteluri', 'Hotel 150 camere, restaurant, sala conferinte', 'Clasificare turistica, Aviz ISU', 'Mare', 'Privat', 'In executie'),
('Gradinita cu 6 Sali', 'Sibiu', 'Strada Mihai Viteazu nr. 34, Sibiu', '3.8 milioane RON', 'Educatie', 'Gradinite', 'Gradinita P+1, 180 copii, curte amenajata', 'Autorizatie constructie, Aviz ISU', 'Mediu', 'Public', 'In executie'),
('Retea Gaze Naturale', 'Valcea', 'Comuna Horezu, Valcea', '2.2 milioane RON', 'Utilitati', 'Gaze', 'Retea distributie gaze 18 km, 340 bransamente', 'Aviz ANRE, Proiect tehnic', 'Mediu', 'Public', 'In proiectare'),
('Fabrica Componente Auto', 'Arges', 'Zona Industriala Mioveni', '35 milioane RON', 'Industrial', 'Fabrici', 'Fabrica 12.000 mp, 3 linii productie', 'Aviz mediu, Racorduri industriale', 'Mare', 'Privat', 'In executie'),
('Renovare Casa Monument', 'Brasov', 'Piata Sfatului nr. 8, Brasov', '1.5 milioane RON', 'Cultural', 'Monumente', 'Restaurare fatada si structura, secolul XVII', 'Aviz Ministerul Culturii, Expertiza', 'Mediu', 'Public', 'In executie'),
('Statie Epurare Apa', 'Galati', 'Zona Industriala, Galati', '42 milioane RON', 'Utilitati', 'Apa', 'Statie epurare apa uzata 150.000 mc/zi', 'Aviz mediu, Studiu impact', 'Mare', 'Public', 'In licitatie'),
('Complex Sportiv', 'Timis', 'Str. Stadionului nr. 12, Timisoara', '11 milioane RON', 'Sport', 'Sali sport', 'Sala polivalenta 2000 locuri, teren sintetic', 'Autorizatie constructie, PUZ', 'Mare', 'Public', 'In proiectare'),
('Magazin Alimentar Lanț', 'Dolj', 'Bulevardul Decebal nr. 89, Craiova', '1.8 milioane RON', 'Comercial', 'Magazine', 'Supermarket 1200 mp, parcare 50 locuri', 'Autorizatie functionare, Aviz sanitar', 'Mediu', 'Privat', 'Finalizat');
