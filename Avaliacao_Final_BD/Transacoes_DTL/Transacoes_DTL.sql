-- 03_Transacoes_DTL.sql

-- Cenário 01: Agendamento de Nova Consulta (com verificação de paciente e psicólogo)
-- Objetivo: Simular o agendamento de uma nova consulta, incluindo a verificação
--           da existência do paciente e do psicólogo.
-- Fluxo de Negócio:
-- 1. Iniciar transação.
-- 2. Verificar se o paciente e o psicólogo existem. Se não, reverter e sinalizar erro.
-- 3. Inserir a nova consulta na tabela 'consultas'.
-- 4. Confirmar a transação.

DELIMITER $$
CREATE PROCEDURE AgendarNovaConsulta(
    IN p_id_paciente INT,
    IN p_id_psicologo INT,
    IN p_data_consulta TIMESTAMP,
    IN p_modalidade ENUM('REMOTA', 'PRESENCIAL'),
    IN p_tipo ENUM('COMUM', 'SOCIAL'),
    IN p_valor DECIMAL(10,2)
)
BEGIN
    DECLARE paciente_existe INT DEFAULT 0;
    DECLARE psicologo_existe INT DEFAULT 0;

    START TRANSACTION;

    -- Verificar se o paciente existe
    SELECT COUNT(*) INTO paciente_existe FROM pacientes WHERE id_paciente = p_id_paciente;

    -- Verificar se o psicólogo existe
    SELECT COUNT(*) INTO psicologo_existe FROM psicologos WHERE id_psicologo = p_id_psicologo;

    IF paciente_existe = 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Paciente não encontrado.';
    ELSEIF psicologo_existe = 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Psicólogo não encontrado.';
    ELSE
        -- Simula um SAVEPOINT antes da inserção, embora no MySQL, se a inserção falhar
        -- (ex: chave estrangeira), a transação inteira reverterá por padrão, a menos
        -- que haja um handler específico. Aqui, usamos um SAVEPOINT para ilustrar
        -- um ponto de reversão parcial, se houvesse outras operações que pudessem
        -- ser revertidas independentemente.
        SAVEPOINT sp_antes_insercao;

        -- Inserir a nova consulta
        INSERT INTO consultas (id_paciente, id_psicologo, data_consulta, status, modalidade, tipo, valor)
        VALUES (p_id_paciente, p_id_psicologo, p_data_consulta, 'AGENDADA', p_modalidade, p_tipo, p_valor);

        -- Se a inserção for bem-sucedida, o SAVEPOINT pode ser liberado ou a transação commitada.
        -- Se houvesse uma falha após o SAVEPOINT e quiséssemos reverter apenas até ele:
        -- ROLLBACK TO SAVEPOINT sp_antes_insercao;

        COMMIT;
        SELECT 'Consulta agendada com sucesso!' AS Mensagem;
    END IF;
END$$
DELIMITER ;

-- Exemplo de uso e simulação de falha:
-- CALL AgendarNovaConsulta(1, 1, '2025-06-15 14:00:00', 'REMOTE', 'COMMON', 150.00); -- Sucesso
-- CALL AgendarNovaConsulta(999, 1, '2025-06-16 10:00:00', 'REMOTE', 'COMMON', 150.00); -- Falha: Paciente não encontrado
-- CALL AgendarNovaConsulta(1, 999, '2025-06-16 11:00:00', 'REMOTE', 'COMMON', 150.00); -- Falha: Psicólogo não encontrado


-- Cenário 02: Cancelamento de Consulta com Restauração de Status
-- Objetivo: Simular o cancelamento de uma consulta, com tratamento de erro
--           caso a consulta não exista ou já esteja em um status finalizado (CONCLUIDA/CANCELADA).
-- Fluxo de Negócio:
-- 1. Iniciar transação.
-- 2. Verificar o status atual da consulta.
-- 3. Se a consulta já estiver CONCLUIDA ou CANCELADA, reverter e sinalizar erro.
-- 4. Se não, atualizar o status da consulta para 'CANCELADA'.
-- 5. Confirmar a transação.

DELIMITER $$
CREATE PROCEDURE CancelarConsulta(
    IN p_id_consulta INT
)
BEGIN
    DECLARE current_status ENUM('AGENDADA', 'CONCLUIDA', 'CANCELADA');
    DECLARE consulta_existe INT DEFAULT 0;

    START TRANSACTION;

    SELECT COUNT(*) INTO consulta_existe FROM consultas WHERE id_consulta = p_id_consulta;

    IF consulta_existe = 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Consulta não encontrada.';
    END IF;

    SELECT status INTO current_status FROM consultas WHERE id_consulta = p_id_consulta;

    IF current_status IN ('CONCLUIDA', 'CANCELADA') THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Não é possível cancelar uma consulta já concluída ou cancelada.';
    ELSE
        SAVEPOINT sp_antes_cancelamento;

        UPDATE consultas
        SET status = 'CANCELADA'
        WHERE id_consulta = p_id_consulta;

        -- Simular uma falha após o SAVEPOINT, por exemplo, se houvesse uma operação
        -- de log de cancelamento que falhasse, poderíamos usar ROLLBACK TO SAVEPOINT.
        -- Por simplicidade, assumimos que a atualização é a principal operação aqui.

        COMMIT;
        SELECT 'Consulta cancelada com sucesso!' AS Mensagem;
    END IF;
END$$
DELIMITER ;

-- Exemplo de uso e simulação de falha:
-- CALL CancelarConsulta(4); -- Sucesso (Consulta 4 está CANCELADA, mas a lógica permite o cancelamento, idealmente deveria ser AGENDADA)
-- CALL CancelarConsulta(1); -- Falha (Consulta 1 está CONCLUIDA)
-- CALL CancelarConsulta(999); -- Falha: Consulta não encontrada


-- Cenário 03: Avaliação de Consulta (com tratamento de erro para consulta já avaliada)
-- Objetivo: Registrar uma avaliação para uma consulta, garantindo que uma consulta
--           não seja avaliada mais de uma vez.
-- Fluxo de Negócio:
-- 1. Iniciar transação.
-- 2. Verificar se a consulta já possui uma avaliação. Se sim, reverter e sinalizar erro.
-- 3. Inserir a nova avaliação na tabela 'avaliacoes'.
-- 4. Confirmar a transação.

DELIMITER $$
CREATE PROCEDURE AvaliarConsulta(
    IN p_id_consulta INT,
    IN p_id_paciente INT,
    IN p_id_psicologo INT,
    IN p_nota INT,
    IN p_comentario TEXT
)
BEGIN
    DECLARE avaliacao_existente INT DEFAULT 0;
    DECLARE consulta_concluida INT DEFAULT 0;

    START TRANSACTION;

    -- Verificar se a consulta já foi avaliada
    SELECT COUNT(*) INTO avaliacao_existente FROM avaliacoes WHERE id_consulta = p_id_consulta;

    IF avaliacao_existente > 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: Esta consulta já foi avaliada.';
    END IF;

    -- Opcional: Verificar se a consulta foi concluída antes de permitir a avaliação
    SELECT COUNT(*) INTO consulta_concluida FROM consultas WHERE id_consulta = p_id_consulta AND status = 'CONCLUIDA';

    IF consulta_concluida = 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro: A consulta deve estar CONCLUIDA para ser avaliada.';
    END IF;

    SAVEPOINT sp_antes_avaliacao;

    INSERT INTO avaliacoes (id_consulta, id_paciente, id_psicologo, nota, comentario)
    VALUES (p_id_consulta, p_id_paciente, p_id_psicologo, p_nota, p_comentario);

    COMMIT;
    SELECT 'Avaliação registrada com sucesso!' AS Mensagem;
END$$
DELIMITER ;

-- Exemplo de uso e simulação de falha:
-- CALL AvaliarConsulta(2, 2, 2, 5, 'Atendimento excelente!'); -- Sucesso (se a consulta 2 não tiver avaliação)
-- CALL AvaliarConsulta(1, 1, 1, 4, 'Avaliação atualizada.'); -- Falha (Consulta 1 já avaliada pelos dados de exemplo)
-- CALL AvaliarConsulta(6, 6, 6, 3, 'Consulta pendente.'); -- Falha: Consulta não CONCLUIDA
