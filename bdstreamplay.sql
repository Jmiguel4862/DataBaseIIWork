
-- TRABALHO DE BANCO DE DADOS II — STREAMPLAY
-- Estrutura Completa conforme exigido no Tópico 15

-- 1. CRIAÇÃO DAS TABELAS

DROP TABLE IF EXISTS ESTATISTICA_VIDEO CASCADE;
DROP TABLE IF EXISTS AVALIACAO CASCADE;
DROP TABLE IF EXISTS VISUALIZACAO CASCADE;
DROP TABLE IF EXISTS EPISODIO CASCADE;
DROP TABLE IF EXISTS TEMPORADA CASCADE;
DROP TABLE IF EXISTS VIDEO_CATEGORIA CASCADE;
DROP TABLE IF EXISTS CATEGORIA CASCADE;
DROP TABLE IF EXISTS VIDEO CASCADE;
DROP TABLE IF EXISTS ASSINATURA CASCADE;
DROP TABLE IF EXISTS USUARIO CASCADE;
DROP TABLE IF EXISTS PLANO CASCADE;

-- TABELA DE PLANOS
CREATE TABLE PLANO (
ID_PLANO SERIAL PRIMARY KEY,
NOME VARCHAR(50) NOT NULL UNIQUE,
VALOR NUMERIC(10,2) NOT NULL CHECK (VALOR >= 0),
QUALIDADE VARCHAR(20) NOT NULL,
LIMITE_TELAS INTEGER NOT NULL CHECK (LIMITE_TELAS > 0)
);

-- TABELA DE USUÁRIOS
CREATE TABLE USUARIO (
ID_USUARIO SERIAL PRIMARY KEY,
NOME VARCHAR(100) NOT NULL,
EMAIL VARCHAR(150) NOT NULL UNIQUE,
SENHA VARCHAR(100) NOT NULL,
DATA_CADASTRO DATE NOT NULL DEFAULT CURRENT_DATE,
ATIVO BOOLEAN NOT NULL DEFAULT TRUE
);

-- ASSINATURAS
CREATE TABLE ASSINATURA (
ID_ASSINATURA SERIAL PRIMARY KEY,
ID_USUARIO INTEGER NOT NULL,
ID_PLANO INTEGER NOT NULL,
DATA_INICIO DATE NOT NULL,
DATA_FIM DATE,
STATUS VARCHAR(20) NOT NULL DEFAULT 'ATIVA',

CONSTRAINT FK_ASSINATURA_USUARIO
    FOREIGN KEY (ID_USUARIO)
    REFERENCES USUARIO(ID_USUARIO),

CONSTRAINT FK_ASSINATURA_PLANO
    FOREIGN KEY (ID_PLANO)
    REFERENCES PLANO(ID_PLANO),

CONSTRAINT CK_ASSINATURA_DATAS
    CHECK (DATA_FIM IS NULL OR DATA_FIM >= DATA_INICIO)


);

-- VÍDEOS
CREATE TABLE VIDEO (
ID_VIDEO SERIAL PRIMARY KEY,
TITULO VARCHAR(200) NOT NULL,
SINOPSE TEXT,
ANO_LANCAMENTO INTEGER,
DURACAO_MINUTOS INTEGER NOT NULL CHECK (DURACAO_MINUTOS > 0),
TIPO VARCHAR(30) NOT NULL,
CLASSIFICACAO VARCHAR(10),
DISPONIVEL BOOLEAN NOT NULL DEFAULT TRUE,

CONSTRAINT CK_VIDEO_TIPO
    CHECK (
        TIPO IN (
            'FILME',
            'SERIE',
            'DOCUMENTARIO',
            'ANIMACAO',
            'SHOW'
        )
    )
);

-- CATEGORIAS
CREATE TABLE CATEGORIA (
ID_CATEGORIA SERIAL PRIMARY KEY,
NOME VARCHAR(50) NOT NULL UNIQUE
);

-- RELACIONAMENTO N:N ENTRE VIDEO E CATEGORIA
CREATE TABLE VIDEO_CATEGORIA (
ID_VIDEO INTEGER NOT NULL,
ID_CATEGORIA INTEGER NOT NULL,

PRIMARY KEY (ID_VIDEO, ID_CATEGORIA),

CONSTRAINT FK_VC_VIDEO
    FOREIGN KEY (ID_VIDEO)
    REFERENCES VIDEO(ID_VIDEO)
    ON DELETE CASCADE,

CONSTRAINT FK_VC_CATEGORIA
    FOREIGN KEY (ID_CATEGORIA)
    REFERENCES CATEGORIA(ID_CATEGORIA)
    ON DELETE CASCADE
);

-- TEMPORADAS
CREATE TABLE TEMPORADA (
ID_TEMPORADA SERIAL PRIMARY KEY,
ID_VIDEO INTEGER NOT NULL,
NUMERO INTEGER NOT NULL CHECK (NUMERO > 0),
ANO_LANCAMENTO INTEGER,

CONSTRAINT FK_TEMPORADA_VIDEO
    FOREIGN KEY (ID_VIDEO)
    REFERENCES VIDEO(ID_VIDEO)
    ON DELETE CASCADE,

CONSTRAINT UK_TEMPORADA
    UNIQUE (ID_VIDEO, NUMERO)
);

-- EPISÓDIOS
CREATE TABLE EPISODIO (
ID_EPISODIO SERIAL PRIMARY KEY,
ID_TEMPORADA INTEGER NOT NULL,
NUMERO INTEGER NOT NULL CHECK (NUMERO > 0),
TITULO VARCHAR(200) NOT NULL,
DURACAO_MINUTOS INTEGER NOT NULL CHECK (DURACAO_MINUTOS > 0),

CONSTRAINT FK_EPISODIO_TEMPORADA
    FOREIGN KEY (ID_TEMPORADA)
    REFERENCES TEMPORADA(ID_TEMPORADA)
    ON DELETE CASCADE,

CONSTRAINT UK_EPISODIO
    UNIQUE (ID_TEMPORADA, NUMERO)


);

-- REGISTRO DE VISUALIZAÇÕES
CREATE TABLE VISUALIZACAO (
ID_VISUALIZACAO SERIAL PRIMARY KEY,
ID_USUARIO INTEGER NOT NULL,
ID_VIDEO INTEGER NOT NULL,
DATA_HORA_INICIO TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
DATA_HORA_FIM TIMESTAMP,
SEGUNDOS_ASSISTIDOS INTEGER NOT NULL DEFAULT 0
CHECK (SEGUNDOS_ASSISTIDOS >= 0),

CONSTRAINT FK_VISUALIZACAO_USUARIO
    FOREIGN KEY (ID_USUARIO)
    REFERENCES USUARIO(ID_USUARIO),

CONSTRAINT FK_VISUALIZACAO_VIDEO
    FOREIGN KEY (ID_VIDEO)
    REFERENCES VIDEO(ID_VIDEO)
);

-- AVALIAÇÕES
CREATE TABLE AVALIACAO (
ID_USUARIO INTEGER NOT NULL,
ID_VIDEO INTEGER NOT NULL,
NOTA INTEGER NOT NULL CHECK (NOTA BETWEEN 1 AND 5),
DATA_AVALIACAO TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

PRIMARY KEY (ID_USUARIO, ID_VIDEO),

CONSTRAINT FK_AVALIACAO_USUARIO
    FOREIGN KEY (ID_USUARIO)
    REFERENCES USUARIO(ID_USUARIO)
    ON DELETE CASCADE,

CONSTRAINT FK_AVALIACAO_VIDEO
    FOREIGN KEY (ID_VIDEO)
    REFERENCES VIDEO(ID_VIDEO)
    ON DELETE CASCADE
);

-- TABELA AUXILIAR DE ESTATÍSTICAS (PARA TRIGGER 2)
CREATE TABLE ESTATISTICA_VIDEO (
ID_VIDEO INTEGER PRIMARY KEY,
QUANTIDADE_AVALIACOES INTEGER DEFAULT 0,
SOMA_NOTAS INTEGER DEFAULT 0,
NOTA_MEDIA NUMERIC(5,2) DEFAULT 0,

CONSTRAINT FK_ESTATISTICA_VIDEO
    FOREIGN KEY (ID_VIDEO)
    REFERENCES VIDEO(ID_VIDEO)
    ON DELETE CASCADE
);

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

-- 3. FUNÇÃO SQL (PARTE A)

-- Questão 1 — Histórico de visualização por usuário
CREATE OR REPLACE FUNCTION fn_videos_assistidos_usuario(
p_id_usuario INTEGER,
p_data_inicio TIMESTAMP,
p_data_fim TIMESTAMP
)
RETURNS TABLE (
id_video INTEGER,
titulo VARCHAR,
tipo VARCHAR,
data_hora_inicio TIMESTAMP,
data_hora_fim TIMESTAMP,
segundos_assistidos INTEGER
)
LANGUAGE SQL
AS $$   SELECT v.id_video, v.titulo, v.tipo, vis.data_hora_inicio, vis.data_hora_fim, vis.segundos_assistidos  
        FROM VISUALIZACAO vis  
        JOIN VIDEO v ON vis.id_video = v.id_video  
        WHERE vis.id_usuario = p_id_usuario       
        AND vis.data_hora_inicio >= p_data_inicio       
        AND vis.data_hora_inicio <= p_data_fim; $$;

-- 4. FUNÇÕES PL/PGSQL (PARTE B)

-- Questão 2 — Vídeos mais assistidos
CREATE OR REPLACE FUNCTION fn_videos_mais_assistidos(
p_data_inicio TIMESTAMP,
p_data_fim TIMESTAMP
)
RETURNS TABLE (
id_video INTEGER,
titulo VARCHAR,
tipo VARCHAR,
quantidade_visualizacoes BIGINT,
total_segundos_assistidos BIGINT
)
LANGUAGE plpgsql
AS $$ BEGIN     RETURN QUERY     
                SELECT  v.id_video, v.titulo, v.tipo, COUNT(vis.id_visualizacao) AS quantidade_visualizacoes, SUM(vis.segundos_assistidos)
                ::BIGINT AS total_segundos_assistidos     
                FROM VISUALIZACAO vis     
                JOIN VIDEO v ON vis.id_video = v.id_video     
                WHERE vis.data_hora_inicio >= p_data_inicio       
                AND vis.data_hora_inicio <= p_data_fim     
                GROUP BY v.id_video, v.titulo, v.tipo     
                ORDER BY quantidade_visualizacoes DESC, total_segundos_assistidos DESC; 
                END; $$;

-- Questão 3 — Conteúdos mais assistidos por categoria
CREATE OR REPLACE FUNCTION fn_categorias_mais_assistidas(
p_data_inicio TIMESTAMP,
p_data_fim TIMESTAMP
)
RETURNS TABLE (
categoria VARCHAR,
quantidade_visualizacoes BIGINT
)
LANGUAGE plpgsql
AS $$ BEGIN     RETURN QUERY     
                SELECT  .nome AS categoria, COUNT(vis.id_visualizacao) AS quantidade_visualizacoes
                FROM VISUALIZACAO vis     
                JOIN VIDEO_CATEGORIA vc ON vis.id_video = vc.id_video     
                JOIN CATEGORIA c ON vc.id_categoria = c.id_categoria     
                WHERE vis.data_hora_inicio >= p_data_inicio       
                AND vis.data_hora_inicio <= p_data_fim     
                GROUP BY c.nome     
                ORDER BY quantidade_visualizacoes DESC; 
                END; $$;

-- Questão 4 — Usuários que menos assistiram
CREATE OR REPLACE FUNCTION fn_usuarios_menos_ativos(
p_data_inicio TIMESTAMP,
p_data_fim TIMESTAMP
)
RETURNS TABLE (
id_usuario INTEGER,
nome VARCHAR,
email VARCHAR,
quantidade_videos_assistidos BIGINT,
total_segundos_assistidos BIGINT
)
LANGUAGE plpgsql
AS $$ BEGIN     RETURN QUERY     
                SELECT u.id_usuario, u.nome, u.email, COUNT(vis.id_visualizacao) AS quantidade_videos_assistidos, COALESCE(SUM(vis.segundos_assistidos), 0)
                ::BIGINT AS total_segundos_assistidos     
                FROM USUARIO u     
                LEFT JOIN VISUALIZACAO vis ON u.id_usuario = vis.id_usuario              
                AND vis.data_hora_inicio >= p_data_inicio                               
                AND vis.data_hora_inicio <= p_data_fim     
                GROUP BY u.id_usuario, u.nome, u.email     
                ORDER BY quantidade_videos_assistidos ASC, total_segundos_assistidos ASC; 
                END; $$;

-- Questão 5 — Sistema de recomendação
CREATE OR REPLACE FUNCTION fn_recomendar_videos(
p_id_usuario INTEGER
)
RETURNS TABLE (
id_video INTEGER,
titulo VARCHAR,
tipo VARCHAR,
categoria VARCHAR,
pontuacao_recomendacao NUMERIC(5,2)
)
LANGUAGE plpgsql
AS $$ BEGIN     RETURN QUERY     WITH categorias_usuario AS (         SELECT DISTINCT vc.id_categoria         FROM VISUALIZACAO vis         JOIN VIDEO_CATEGORIA vc ON vis.id_video = vc.id_video         WHERE vis.id_usuario = p_id_usuario         UNION         SELECT DISTINCT vc.id_categoria         FROM AVALIACAO a         JOIN VIDEO_CATEGORIA vc ON a.id_video = vc.id_video         WHERE a.id_usuario = p_id_usuario AND a.nota >= 4     ),     videos_assistidos AS (         SELECT DISTINCT vis.id_video         FROM VISUALIZACAO vis         WHERE vis.id_usuario = p_id_usuario     )     SELECT          v.id_video,         v.titulo,         v.tipo,         c.nome AS categoria,         ROUND(COALESCE(AVG(a.nota), 3.0) * COUNT(DISTINCT cu.id_categoria), 2) AS pontuacao_recomendacao     FROM VIDEO v     JOIN VIDEO_CATEGORIA vc ON v.id_video = vc.id_video     JOIN CATEGORIA c ON vc.id_categoria = c.id_categoria     JOIN categorias_usuario cu ON vc.id_categoria = cu.id_categoria     LEFT JOIN AVALIACAO a ON v.id_video = a.id_video     WHERE v.id_video NOT IN (SELECT va.id_video FROM videos_assistidos va)       AND v.disponivel = TRUE     GROUP BY v.id_video, v.titulo, v.tipo, c.nome     ORDER BY pontuacao_recomendacao DESC, v.titulo ASC; END; $$;

-- 5. STORED PROCEDURES (PARTE C)

-- Procedure 1 — Cadastro de Usuário
CREATE OR REPLACE PROCEDURE sp_cadastrar_usuario(
p_nome VARCHAR,
p_email VARCHAR,
p_senha VARCHAR
)
LANGUAGE plpgsql
AS $$ BEGIN     IF EXISTS (SELECT 1 FROM USUARIO WHERE EMAIL = p_email) THEN         RAISE EXCEPTION 'O e-mail % já está cadastrado no sistema.', p_email;     END IF;      INSERT INTO USUARIO (NOME, EMAIL, SENHA)     VALUES (p_nome, p_email, p_senha);      RAISE NOTICE 'Usuário % cadastrado com sucesso!', p_nome; END; $$;

-- Procedure 2 — Alteração de Plano do Usuário
CREATE OR REPLACE PROCEDURE sp_alterar_plano_usuario(
p_id_usuario INTEGER,
p_id_novo_plano INTEGER
)
LANGUAGE plpgsql
AS $$ BEGIN     IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE ID_USUARIO = p_id_usuario) THEN         RAISE EXCEPTION 'Usuário com ID % não encontrado.', p_id_usuario;     END IF;      IF NOT EXISTS (SELECT 1 FROM PLANO WHERE ID_PLANO = p_id_novo_plano) THEN         RAISE EXCEPTION 'Plano com ID % não encontrado.', p_id_novo_plano;     END IF;      UPDATE ASSINATURA     SET DATA_FIM = CURRENT_DATE,         STATUS = 'CANCELADA'     WHERE ID_USUARIO = p_id_usuario AND STATUS = 'ATIVA';      INSERT INTO ASSINATURA (ID_USUARIO, ID_PLANO, DATA_INICIO, STATUS)     VALUES (p_id_usuario, p_id_novo_plano, CURRENT_DATE, 'ATIVA');      RAISE NOTICE 'Plano do usuário % alterado com sucesso!', p_id_usuario; END; $$;

-- Procedure 3 — Registrar Visualização
CREATE OR REPLACE PROCEDURE sp_registrar_visualizacao(
p_id_usuario INTEGER,
p_id_video INTEGER,
p_data_hora_inicio TIMESTAMP,
p_data_hora_fim TIMESTAMP,
p_segundos_assistidos INTEGER
)
LANGUAGE plpgsql
AS $$ BEGIN     IF NOT EXISTS (SELECT 1 FROM USUARIO WHERE ID_USUARIO = p_id_usuario AND ATIVO = TRUE) THEN         RAISE EXCEPTION 'Usuário ID % não existe ou está inativo.', p_id_usuario;     END IF;      IF NOT EXISTS (SELECT 1 FROM VIDEO WHERE ID_VIDEO = p_id_video AND DISPONIVEL = TRUE) THEN         RAISE EXCEPTION 'Vídeo ID % não existe ou não está disponível.', p_id_video;     END IF;      IF p_segundos_assistidos < 0 THEN         RAISE EXCEPTION 'A quantidade de segundos assistidos não pode ser negativa.';     END IF;      INSERT INTO VISUALIZACAO (         ID_USUARIO,         ID_VIDEO,         DATA_HORA_INICIO,         DATA_HORA_FIM,         SEGUNDOS_ASSISTIDOS     ) VALUES (         p_id_usuario,         p_id_video,         p_data_hora_inicio,         p_data_hora_fim,         p_segundos_assistidos     );      RAISE NOTICE 'Visualização registrada com sucesso!'; END; $$;

-- 6. FUNÇÕES DAS TRIGGERS

-- Função para Trigger 1: Validação de Visualização
CREATE OR REPLACE FUNCTION fn_trg_validar_visualizacao()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$ DECLARE     v_duracao_maxima_segundos INTEGER;     v_usuario_ativo BOOLEAN;     v_video_disponivel BOOLEAN; BEGIN     -- 1. Verificar se usuário está ativo     SELECT ATIVO INTO v_usuario_ativo FROM USUARIO WHERE ID_USUARIO = NEW.ID_USUARIO;     IF v_usuario_ativo IS NOT TRUE THEN         RAISE EXCEPTION 'Operação negada: O usuário está inativo ou não existe.';     END IF;      -- 2. Verificar se vídeo está disponível e pegar duração máxima     SELECT DISPONIVEL, (DURACAO_MINUTOS * 60) INTO v_video_disponivel, v_duracao_maxima_segundos      FROM VIDEO WHERE ID_VIDEO = NEW.ID_VIDEO;      IF v_video_disponivel IS NOT TRUE THEN         RAISE EXCEPTION 'Operação negada: O vídeo selecionado está indisponível.';     END IF;      -- 3. Verificar validade dos tempos     IF NEW.DATA_HORA_FIM IS NOT NULL AND NEW.DATA_HORA_FIM < NEW.DATA_HORA_INICIO THEN         RAISE EXCEPTION 'Operação negada: A data/hora final não pode ser anterior à data/hora inicial.';     END IF;      IF NEW.SEGUNDOS_ASSISTIDOS > v_duracao_maxima_segundos THEN         RAISE EXCEPTION 'Operação negada: Tempo assistido (%) excede a duração total do vídeo (% segundos).',                          NEW.SEGUNDOS_ASSISTIDOS, v_duracao_maxima_segundos;     END IF;      RETURN NEW; END; $$;

-- Função para Trigger 2: Controle Automático de Avaliações / Estatísticas
CREATE OR REPLACE FUNCTION fn_trg_atualizar_estatisticas_avaliacao()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$ DECLARE     v_target_video INTEGER; B  EGIN     IF TG_OP = 'DELETE' THEN         v_target_video := OLD.ID_VIDEO;     ELSE         v_target_video := NEW.ID_VIDEO;     END IF;      -- Atualiza ou Insere o registro na tabela de estatísticas     INSERT INTO ESTATISTICA_VIDEO (ID_VIDEO, QUANTIDADE_AVALIACOES, SOMA_NOTAS, NOTA_MEDIA)     SELECT          v_target_video,         COUNT(*),         COALESCE(SUM(NOTA), 0),         ROUND(COALESCE(AVG(NOTA), 0), 2)     FROM AVALIACAO     WHERE ID_VIDEO = v_target_video     ON CONFLICT (ID_VIDEO)      DO UPDATE SET         QUANTIDADE_AVALIACOES = EXCLUDED.QUANTIDADE_AVALIACOES,         SOMA_NOTAS = EXCLUDED.SOMA_NOTAS,         NOTA_MEDIA = EXCLUDED.NOTA_MEDIA;      RETURN NULL; END; $$;

-- 7. TRIGGERS

-- Trigger 1: Validação antes de inserir visualização
CREATE TRIGGER trg_validar_visualizacao
BEFORE INSERT OR UPDATE ON VISUALIZACAO
FOR EACH ROW
EXECUTE FUNCTION fn_trg_validar_visualizacao();

-- Trigger 2: Recálculo de estatísticas após manipulação de avaliações
CREATE TRIGGER trg_atualizar_estatisticas_avaliacao
AFTER INSERT OR UPDATE OR DELETE ON AVALIACAO
FOR EACH ROW
EXECUTE FUNCTION fn_trg_atualizar_estatisticas_avaliacao();

-- 8. TESTES OBRIGATÓRIOS

-- 8.1 Teste Função SQL: Questão 1
SELECT * FROM fn_videos_assistidos_usuario(1, '2026-05-01', '2026-05-31');

-- 8.2 Teste Função PL/pgSQL: Questão 2
SELECT * FROM fn_videos_mais_assistidos('2026-05-01', '2026-05-31');

-- 8.3 Teste Função PL/pgSQL: Questão 3
SELECT * FROM fn_categorias_mais_assistidas('2026-05-01', '2026-05-31');

-- 8.4 Teste Função PL/pgSQL: Questão 4
SELECT * FROM fn_usuarios_menos_ativos('2026-05-01', '2026-05-31');

-- 8.5 Teste Função PL/pgSQL: Questão 5
SELECT * FROM fn_recomendar_videos(1);

-- 8.6 Testes de Stored Procedures
CALL sp_cadastrar_usuario('Novo Cliente Teste', 'cliente.teste@email.com', 'senha123');
CALL sp_alterar_plano_usuario(1, 2);
CALL sp_registrar_visualizacao(1, 2, '2026-06-01 20:00:00', '2026-06-01 21:50:00', 6600);

-- 8.7 Teste Trigger 2
INSERT INTO AVALIACAO (ID_USUARIO, ID_VIDEO, NOTA) VALUES (3, 1, 5);
SELECT * FROM ESTATISTICA_VIDEO WHERE ID_VIDEO = 1;

-- 8.8 Teste Trigger 1 (Deverá FALHAR e lançar exceção por excesso de tempo assistido)
-- Descomente a linha abaixo para executar o teste de falha:
-- INSERT INTO VISUALIZACAO (ID_USUARIO, ID_VIDEO, DATA_HORA_INICIO, DATA_HORA_FIM, SEGUNDOS_ASSISTIDOS) VALUES (1, 1, '2026-06-01 20:00', '2026-06-01 22:00', 999999);