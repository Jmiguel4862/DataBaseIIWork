-- 2. CARGA INICIAL DE DADOS

-- 2.1 Planos
INSERT INTO PLANO (NOME, VALOR, QUALIDADE, LIMITE_TELAS) VALUES
('Básico', 19.90, 'HD', 1),
('Padrão', 29.90, 'FULL HD', 2),
('Premium', 49.90, '4K', 4);

-- 2.2 Usuários
INSERT INTO USUARIO (NOME, EMAIL, SENHA, DATA_CADASTRO) VALUES
('Ana Silva', 'ana@email.com', '123', '2026-01-10'),
('Bruno Souza', 'bruno@email.com', '123', '2026-01-15'),
('Carlos Oliveira', 'carlos@email.com', '123', '2026-02-02'),
('Daniela Costa', 'daniela@email.com', '123', '2026-02-10'),
('Eduardo Santos', 'eduardo@email.com', '123', '2026-02-20'),
('Fernanda Lima', 'fernanda@email.com', '123', '2026-03-01'),
('Gabriel Alves', 'gabriel@email.com', '123', '2026-03-10'),
('Helena Martins', 'helena@email.com', '123', '2026-03-15'),
('Igor Rocha', 'igor@email.com', '123', '2026-04-01'),
('Juliana Mendes', 'juliana@email.com', '123', '2026-04-05');

-- 2.3 Assinaturas
INSERT INTO ASSINATURA (ID_USUARIO, ID_PLANO, DATA_INICIO, STATUS) VALUES
(1, 3, '2026-01-10', 'ATIVA'),
(2, 2, '2026-01-15', 'ATIVA'),
(3, 1, '2026-02-02', 'ATIVA'),
(4, 3, '2026-02-10', 'ATIVA'),
(5, 2, '2026-02-20', 'ATIVA'),
(6, 1, '2026-03-01', 'ATIVA'),
(7, 3, '2026-03-10', 'ATIVA'),
(8, 2, '2026-03-15', 'ATIVA'),
(9, 1, '2026-04-01', 'ATIVA'),
(10, 2, '2026-04-05', 'ATIVA');

-- 2.4 Categorias
INSERT INTO CATEGORIA (NOME) VALUES
('Ação'),
('Comédia'),
('Drama'),
('Ficção Científica'),
('Terror'),
('Documentário'),
('Infantil'),
('Animação'),
('Musical'),
('Aventura');

-- 2.5 Vídeos
INSERT INTO VIDEO (TITULO, SINOPSE, ANO_LANCAMENTO, DURACAO_MINUTOS, TIPO, CLASSIFICACAO) VALUES
('O Último Horizonte', 'Um grupo de astronautas parte em uma missão para explorar um planeta distante.', 2024, 125, 'FILME', '14'),
('Cidade Sombria', 'Um detetive investiga acontecimentos misteriosos em uma cidade aparentemente tranquila.', 2023, 110, 'FILME', '16'),
('A Grande Viagem', 'Uma família embarca em uma divertida viagem através do país.', 2025, 98, 'FILME', 'L'),
('Código Zero', 'Uma equipe de especialistas tenta impedir um ataque cibernético internacional.', 2024, 115, 'FILME', '14'),
('Planeta Azul', 'Documentário sobre os oceanos e a vida marinha.', 2022, 90, 'DOCUMENTARIO', 'L'),
('Universo Desconhecido', 'Documentário sobre galáxias, estrelas e os mistérios do universo.', 2025, 105, 'DOCUMENTARIO', 'L'),
('Mundo Animal', 'Série documental sobre a vida selvagem.', 2024, 50, 'SERIE', 'L'),
('Investigação Criminal', 'Série policial acompanhando diferentes investigações.', 2023, 48, 'SERIE', '16'),
('Família Feliz', 'Animação sobre as aventuras de uma família muito divertida.', 2025, 85, 'ANIMACAO', 'L'),
('Heróis do Espaço', 'Uma equipe de jovens enfrenta perigos em diferentes planetas.', 2024, 100, 'SERIE', '10'),
('Festival ao Vivo', 'Show musical realizado em um grande festival.', 2025, 130, 'SHOW', 'L'),
('Mistérios do Passado', 'Documentário sobre civilizações antigas.', 2023, 88, 'DOCUMENTARIO', 'L'),
('Operação Resgate', 'Uma equipe especial realiza uma perigosa missão de resgate.', 2024, 120, 'FILME', '16'),
('Aventuras na Floresta', 'Uma animação sobre animais que vivem em uma floresta encantada.', 2025, 92, 'ANIMACAO', 'L'),
('O Poder da Música', 'Documentário sobre a influência da música na sociedade.', 2024, 95, 'DOCUMENTARIO', 'L');

-- 2.6 Relacionamento vídeo/categoria
INSERT INTO VIDEO_CATEGORIA VALUES
(1,4),(1,10),(2,5),(2,3),(3,2),(3,10),(4,1),(4,4),(5,6),(6,6),
(6,4),(7,6),(8,3),(8,5),(9,7),(9,8),(10,4),(10,10),(11,9),(12,6),
(12,10),(13,1),(13,10),(14,7),(14,8),(15,6),(15,9);

-- 2.7 Temporadas
INSERT INTO TEMPORADA (ID_VIDEO, NUMERO, ANO_LANCAMENTO) VALUES
(7, 1, 2024),
(7, 2, 2025),
(8, 1, 2023),
(8, 2, 2024),
(10, 1, 2024),
(10, 2, 2025);

-- 2.8 Episódios
INSERT INTO EPISODIO (ID_TEMPORADA, NUMERO, TITULO, DURACAO_MINUTOS) VALUES
(1, 1, 'O Começo', 48),
(1, 2, 'A Floresta', 51),
(1, 3, 'O Predador', 49),
(2, 1, 'Novos Horizontes', 52),
(2, 2, 'Vida Selvagem', 50),
(3, 1, 'O Caso', 47),
(3, 2, 'A Investigação', 49),
(3, 3, 'O Suspeito', 50),
(4, 1, 'Novas Evidências', 48),
(4, 2, 'O Mistério', 51),
(5, 1, 'O Planeta', 50),
(5, 2, 'A Missão', 52),
(6, 1, 'O Inimigo', 49),
(6, 2, 'O Confronto', 51);

-- 2.9 Visualizações
INSERT INTO VISUALIZACAO (ID_USUARIO, ID_VIDEO, DATA_HORA_INICIO, DATA_HORA_FIM, SEGUNDOS_ASSISTIDOS) VALUES
(1, 1, '2026-05-01 20:00', '2026-05-01 22:05', 7500),
(1, 4, '2026-05-03 20:00', '2026-05-03 21:55', 6900),
(1, 5, '2026-05-05 19:00', '2026-05-05 20:30', 5400),
(1, 7, '2026-05-10 20:00', '2026-05-10 20:50', 3000),
(1, 8, '2026-05-15 21:00', '2026-05-15 21:48', 2880),
(2, 1, '2026-05-02 20:00', '2026-05-02 22:05', 7500),
(2, 3, '2026-05-04 20:00', '2026-05-04 21:38', 5880),
(2, 10, '2026-05-07 19:00', '2026-05-07 19:50', 3000),
(2, 11, '2026-05-10 21:00', '2026-05-10 23:10', 7800),
(3, 5, '2026-05-03 18:00', '2026-05-03 19:30', 5400),
(3, 6, '2026-05-08 20:00', '2026-05-08 21:45', 6300),
(4, 2, '2026-05-01 21:00', '2026-05-01 22:50', 6600),
(4, 4, '2026-05-06 20:00', '2026-05-06 21:55', 6900),
(4, 8, '2026-05-09 20:00', '2026-05-09 20:48', 2880),
(4, 13, '2026-05-12 21:00', '2026-05-12 23:00', 7200),
(5, 3, '2026-05-02 15:00', '2026-05-02 16:38', 5880),
(5, 9, '2026-05-05 17:00', '2026-05-05 18:25', 5100),
(6, 7, '2026-05-04 20:00', '2026-05-04 20:50', 3000),
(6, 10, '2026-05-11 20:00', '2026-05-11 20:50', 3000),
(7, 1, '2026-05-01 18:00', '2026-05-01 20:05', 7500),
(7, 4, '2026-05-03 20:00', '2026-05-03 21:55', 6900),
(7, 13, '2026-05-05 20:00', '2026-05-05 22:00', 7200),
(7, 15, '2026-05-10 18:00', '2026-05-10 19:35', 5700),
(8, 6, '2026-05-02 20:00', '2026-05-02 21:45', 6300),
(8, 12, '2026-05-06 20:00', '2026-05-06 21:28', 5280),
(9, 2, '2026-05-07 20:00', '2026-05-07 21:50', 6600),
(10, 3, '2026-05-03 19:00', '2026-05-03 20:38', 5880),
(10, 9, '2026-05-05 19:00', '2026-05-05 20:25', 5100),
(10, 14, '2026-05-08 19:00', '2026-05-08 20:32', 5520);

-- 2.10 Avaliações
INSERT INTO AVALIACAO (ID_USUARIO, ID_VIDEO, NOTA) VALUES
(1, 1, 5), (1, 4, 5), (1, 5, 4), (1, 7, 3),
(2, 1, 4), (2, 3, 5), (2, 10, 5), (2, 11, 4),
(3, 5, 5), (3, 6, 5),
(4, 2, 5), (4, 4, 4), (4, 8, 5), (4, 13, 5),
(5, 3, 4), (5, 9, 5),
(6, 7, 4), (6, 10, 5),
(7, 1, 5), (7, 4, 5), (7, 13, 5), (7, 15, 4),
(8, 6, 5), (8, 12, 4),
(9, 2, 4),
(10, 3, 5), (10, 9, 5), (10, 14, 4);