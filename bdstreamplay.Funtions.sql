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
AS $$ BEGIN     RETURN QUERY     
                WITH categorias_usuario AS (
                SELECT DISTINCT vc.id_categoria
                FROM VISUALIZACAO vis
                JOIN VIDEO_CATEGORIA vc ON vis.id_video = vc.id_video
                WHERE vis.id_usuario = p_id_usuario
                UNION
                SELECT DISTINCT vc.id_categoria
                FROM AVALIACAO a
                JOIN VIDEO_CATEGORIA vc ON a.id_video = vc.id_video
                WHERE a.id_usuario = p_id_usuario AND a.nota >= 4), videos_assistidos AS(       SELECT DISTINCT vis.id_video 
                                                                                                FROM VISUALIZACAO vis         
                                                                                                WHERE vis.id_usuario = p_id_usuario)    SELECT  v.id_video, v.titulo, v.tipo, c.nome AS categoria, ROUND(COALESCE(AVG(a.nota), 3.0) * COUNT(DISTINCT cu.id_categoria), 2) AS pontuacao_recomendacao     
                                                                                                                                        FROM VIDEO v     
                                                                                                                                        JOIN VIDEO_CATEGORIA vc ON v.id_video = vc.id_video     
                                                                                                                                        JOIN CATEGORIA c ON vc.id_categoria = c.id_categoria     
                                                                                                                                        JOIN categorias_usuario cu ON vc.id_categoria = cu.id_categoria     
                                                                                                                                        LEFT JOIN AVALIACAO a ON v.id_video = a.id_video     
                                                                                                                                        WHERE v.id_video NOT IN (SELECT va.id_video FROM videos_assistidos va)       
                                                                                                                                        AND v.disponivel = TRUE     GROUP BY v.id_video, v.titulo, v.tipo, c.nome     
                                                                                                                                        ORDER BY pontuacao_recomendacao DESC, v.titulo ASC; 
                                                                                                                                        END; $$;

-- 5. STORED PROCEDURES (PARTE C)

-- Procedure 1 — Cadastro de Usuário
CREATE OR REPLACE PROCEDURE sp_cadastrar_usuario(
p_nome VARCHAR,
p_email VARCHAR,
p_senha VARCHAR
)
LANGUAGE plpgsql
AS $$ BEGIN     
        IF EXISTS (     SELECT 1 
                FROM USUARIO 
                WHERE EMAIL = p_email)  THEN RAISE EXCEPTION 'O e-mail % já está cadastrado no sistema.', p_email;     
                                        END IF;      
                                        INSERT INTO USUARIO (NOME, EMAIL, SENHA) VALUES (p_nome, p_email, p_senha); 
                                        RAISE NOTICE 'Usuário % cadastrado com sucesso!', p_nome; 
                                        END; $$;

-- Procedure 2 — Alteração de Plano do Usuário
CREATE OR REPLACE PROCEDURE sp_alterar_plano_usuario(
p_id_usuario INTEGER,
p_id_novo_plano INTEGER
)
LANGUAGE plpgsql
AS $$ BEGIN     
        IF NOT EXISTS ( SELECT 1 
                        FROM USUARIO 
                        WHERE ID_USUARIO = p_id_usuario)        THEN        RAISE EXCEPTION 'Usuário com ID % não encontrado.', p_id_usuario;     
                                                                END IF;      
                                                                IF NOT EXISTS ( SELECT 1 
                                                                                FROM PLANO 
                                                                                WHERE ID_PLANO = p_id_novo_plano)       THEN         RAISE EXCEPTION 'Plano com ID % não encontrado.', p_id_novo_plano;     
                                                                                                                        END IF;      
                                                                                                                        UPDATE ASSINATURA     SET DATA_FIM = CURRENT_DATE,         STATUS = 'CANCELADA'     
                                                                                                                        WHERE ID_USUARIO = p_id_usuario 
                                                                                                                        AND STATUS = 'ATIVA';      
                                                                                                                        INSERT INTO ASSINATURA (ID_USUARIO, ID_PLANO, DATA_INICIO, STATUS)     VALUES (p_id_usuario, p_id_novo_plano, CURRENT_DATE, 'ATIVA');      
                                                                                                                        RAISE NOTICE 'Plano do usuário % alterado com sucesso!', p_id_usuario; 
                                                                                                                        END; $$;

-- Procedure 3 — Registrar Visualização
CREATE OR REPLACE PROCEDURE sp_registrar_visualizacao(
p_id_usuario INTEGER,
p_id_video INTEGER,
p_data_hora_inicio TIMESTAMP,
p_data_hora_fim TIMESTAMP,
p_segundos_assistidos INTEGER
)
LANGUAGE plpgsql
AS $$ BEGIN     IF NOT EXISTS ( SELECT 1 
                                FROM USUARIO 
                                WHERE ID_USUARIO = p_id_usuario 
                                   AND ATIVO = TRUE)       THEN  RAISE EXCEPTION 'Usuário ID % não existe ou está inativo.', p_id_usuario;     
                                                                                        END IF;      IF NOT EXISTS (    SELECT 1 
                                                                                                                        FROM VIDEO 
                                                                                                                        WHERE ID_VIDEO = p_id_video 
                                                                                                                        AND DISPONIVEL = TRUE) THEN         RAISE EXCEPTION 'Vídeo ID % não existe ou não está disponível.', p_id_video;     
                                                                                                                        END IF;      IF p_segundos_assistidos < 0 THEN         RAISE EXCEPTION 'A quantidade de segundos assistidos não pode ser negativa.';     
                                                                                                                        END IF;      INSERT INTO VISUALIZACAO ( ID_USUARIO, ID_VIDEO, DATA_HORA_INICIO, DATA_HORA_FIM, SEGUNDOS_ASSISTIDOS     ) VALUES (p_id_usuario, p_id_video, p_data_hora_inicio, p_data_hora_fim, p_segundos_assistidos);      
                                                                                                                        RAISE NOTICE 'Visualização registrada com sucesso!'; 
                                                                                                                        END; $$;

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

