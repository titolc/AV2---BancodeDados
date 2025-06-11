-- 02_Consultas_DQL.sql

-- Consulta 01: Total de Consultas por Psicólogo e Valor Total Arrecadado (Agregação)
-- Objetivo: Mostrar quantos atendimentos cada psicólogo realizou e o valor total faturado,
--           ordenado pelo total faturado decrescentemente.
-- Tabelas envolvidas: psicologos, consultas
SELECT
    p.nome AS NomePsicologo,
    COUNT(c.id_consulta) AS TotalConsultas,
    SUM(c.valor) AS ValorTotalArrecadado
FROM
    psicologos p
JOIN
    consultas c ON p.id_psicologo = c.id_psicologo
GROUP BY
    p.id_psicologo, p.nome
ORDER BY
    ValorTotalArrecadado DESC;

-- Consulta 02: Pacientes que agendaram mais consultas do que a média geral de agendamentos (Subconsulta Correlacionada)
-- Objetivo: Identificar pacientes com alta demanda de consultas, comparando seu número de agendamentos
--           com a média de agendamentos de todos os pacientes.
-- Tabelas envolvidas: pacientes, consultas
SELECT
    pa.nome AS NomePaciente,
    COUNT(c.id_consulta) AS NumeroDeConsultasAgendadas
FROM
    pacientes pa
JOIN
    consultas c ON pa.id_paciente = c.id_paciente
GROUP BY
    pa.id_paciente, pa.nome
HAVING
    COUNT(c.id_consulta) > (SELECT AVG(ContagemConsultas) FROM (SELECT COUNT(id_consulta) AS ContagemConsultas FROM consultas GROUP BY id_paciente) AS SubConsultaMedia);


-- Consulta 03: Detalhes Completos das Consultas para Psicólogos com Valor de Consulta Acima da Média e Pacientes Estudantes (JOIN Múltiplo)
-- Objetivo: Exibir informações detalhadas de consultas, incluindo dados do psicólogo, paciente e especialidades/abordagens,
--           focando em psicólogos que cobram acima da média e pacientes que são estudantes.
-- Tabelas envolvidas: consultas, psicologos, pacientes, psicologos_especialidades, especialidades, psicologos_abordagens, abordagens
SELECT
    c.id_consulta,
    p.nome AS NomePsicologo,
    p.valor_consulta AS ValorConsultaPsicologo,
    pa.nome AS NomePaciente,
    pa.beneficio_social AS BeneficioPaciente,
    c.data_consulta,
    c.status AS StatusConsulta,
    c.modalidade AS ModalidadeConsulta,
    c.tipo AS TipoConsulta,
    c.valor AS ValorCobrado,
    GROUP_CONCAT(DISTINCT e.nome_especialidade SEPARATOR ', ') AS EspecialidadesPsicologo,
    GROUP_CONCAT(DISTINCT a.nome_abordagem SEPARATOR ', ') AS AbordagensPsicologo
FROM
    consultas c
JOIN
    psicologos p ON c.id_psicologo = p.id_psicologo
JOIN
    pacientes pa ON c.id_paciente = pa.id_paciente
LEFT JOIN
    psicologos_especialidades pse ON p.id_psicologo = pse.id_psicologo
LEFT JOIN
    especialidades e ON pse.id_especialidade = e.id_especialidade
LEFT JOIN
    psicologos_abordagens psa ON p.id_psicologo = psa.id_psicologo
LEFT JOIN
    abordagens a ON psa.id_abordagem = a.id_abordagem
WHERE
    p.valor_consulta > (SELECT AVG(valor_consulta) FROM psicologos)
    AND pa.beneficio_social = 'ESTUDANTE'
GROUP BY
    c.id_consulta, p.id_psicologo, pa.id_paciente
ORDER BY
    c.data_consulta DESC;

-- Consulta 04: Psicólogos com Especialidades e Abordagens preferidas por Pacientes (JOIN Múltiplo)
-- Objetivo: Listar psicólogos que oferecem especialidades e abordagens que são preferências de pelo menos um paciente.
--           Isso pode ajudar a identificar psicólogos alinhados com as demandas dos pacientes.
-- Tabelas envolvidas: psicologos, psicologos_especialidades, especialidades, preferencia_especialidades,
--                      psicologos_abordagens, abordagens, preferencia_abordagens
SELECT DISTINCT
    p.nome AS NomePsicologo,
    GROUP_CONCAT(DISTINCT e.nome_especialidade SEPARATOR ', ') AS EspecialidadesOferecidas,
    GROUP_CONCAT(DISTINCT a.nome_abordagem SEPARATOR ', ') AS AbordagensOferecidas
FROM
    psicologos p
JOIN
    psicologos_especialidades pse ON p.id_psicologo = pse.id_psicologo
JOIN
    especialidades e ON pse.id_especialidade = e.id_especialidade
JOIN
    preferencia_especialidades pref_e ON e.id_especialidade = pref_e.id_especialidade
JOIN
    psicologos_abordagens psa ON p.id_psicologo = psa.id_psicologo
JOIN
    abordagens a ON psa.id_abordagem = a.id_abordagem
JOIN
    preferencia_abordagens pref_a ON a.id_abordagem = pref_a.id_abordagem
GROUP BY
    p.id_psicologo, p.nome
ORDER BY
    p.nome;

-- Consulta 05: Pacientes que nunca agendaram uma consulta (LEFT JOIN e IS NULL)
-- Objetivo: Identificar pacientes que estão cadastrados mas ainda não realizaram nenhuma consulta.
-- Tabelas envolvidas: pacientes, consultas
SELECT
    pa.id_paciente,
    pa.nome AS NomePaciente,
    pa.email
FROM
    pacientes pa
LEFT JOIN
    consultas c ON pa.id_paciente = c.id_paciente
WHERE
    c.id_consulta IS NULL
ORDER BY
    pa.nome;
