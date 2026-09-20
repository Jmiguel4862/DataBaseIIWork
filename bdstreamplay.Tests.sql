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