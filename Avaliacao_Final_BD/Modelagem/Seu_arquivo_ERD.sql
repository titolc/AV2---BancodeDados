-- schema_completo.sql
-- Script SQL para criação do esquema do banco de dados no MySQL.

-- Desabilita a verificação de chaves estrangeiras temporariamente para permitir
-- a criação de tabelas em qualquer ordem, caso haja dependências circulares
-- ou para facilitar a recriação do esquema.
SET FOREIGN_KEY_CHECKS = 0;

-- ########## Tabelas Relacionadas aos Psicólogos ##########

-- Tabela de Psicólogos
CREATE TABLE psicologos (
    id_psicologo INT PRIMARY KEY AUTO_INCREMENT,
    crp VARCHAR(10) NOT NULL UNIQUE,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    foto VARCHAR(255) NOT NULL,
    bio VARCHAR(300),
    formacao VARCHAR(300),
    contato VARCHAR(50) NOT NULL,
    senha_hash VARCHAR(255) NOT NULL,
    valor_consulta DECIMAL(10,2) NOT NULL,
    aceita_beneficio BOOLEAN DEFAULT FALSE,
    modalidade_atendimento ENUM('REMOTO', 'PRESENCIAL', 'HIBRIDO') NOT NULL DEFAULT 'REMOTO'
);

-- Tabela de Endereços dos Psicólogos
CREATE TABLE enderecos_psicologos (
    id_psicologo INT PRIMARY KEY,
    rua VARCHAR(150) NOT NULL,
    numero VARCHAR(10) NOT NULL,
    complemento VARCHAR(50),
    bairro VARCHAR(100) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    estado VARCHAR(50) NOT NULL,
    cep VARCHAR(10) NOT NULL,
    latitude DOUBLE NOT NULL,
    longitude DOUBLE NOT NULL,
    FOREIGN KEY (id_psicologo) REFERENCES psicologos(id_psicologo) ON DELETE CASCADE
);

-- Tabela de Especialidades
CREATE TABLE especialidades (
    id_especialidade INT PRIMARY KEY AUTO_INCREMENT,
    nome_especialidade VARCHAR(100) NOT NULL UNIQUE
);

-- Tabela de Abordagens Terapêuticas
CREATE TABLE abordagens (
    id_abordagem INT PRIMARY KEY AUTO_INCREMENT,
    nome_abordagem VARCHAR(100) NOT NULL UNIQUE
);

-- Relacionamento entre Psicólogos e Especialidades (N:N)
CREATE TABLE psicologos_especialidades (
    id_psicologo INT NOT NULL,
    id_especialidade INT NOT NULL,
    PRIMARY KEY (id_psicologo, id_especialidade),
    FOREIGN KEY (id_psicologo) REFERENCES psicologos(id_psicologo) ON DELETE CASCADE,
    FOREIGN KEY (id_especialidade) REFERENCES especialidades(id_especialidade) ON DELETE CASCADE
);

-- Relacionamento entre Psicólogos e Abordagens (N:N)
CREATE TABLE psicologos_abordagens (
    id_psicologo INT NOT NULL,
    id_abordagem INT NOT NULL,
    PRIMARY KEY (id_psicologo, id_abordagem),
    FOREIGN KEY (id_psicologo) REFERENCES psicologos(id_psicologo) ON DELETE CASCADE,
    FOREIGN KEY (id_abordagem) REFERENCES abordagens(id_abordagem) ON DELETE CASCADE
);


-- ########## Tabelas Relacionadas aos Pacientes ##########

-- Tabela de Pacientes
CREATE TABLE pacientes (
    id_paciente INT PRIMARY KEY AUTO_INCREMENT,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    foto VARCHAR(255) NOT NULL UNIQUE,
    bio VARCHAR(300),
    contato VARCHAR(50) NOT NULL,
    senha_hash VARCHAR(255) NOT NULL,
    beneficio_social ENUM('NENHUM', 'ESTUDANTE', 'CADUNICO') NOT NULL DEFAULT 'NENHUM'
);

-- Tabela de Endereços dos Pacientes
CREATE TABLE enderecos_pacientes (
    id_paciente INT PRIMARY KEY,
    rua VARCHAR(150) NOT NULL,
    numero VARCHAR(10) NOT NULL,
    complemento VARCHAR(50),
    bairro VARCHAR(100) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    estado VARCHAR(50) NOT NULL,
    cep VARCHAR(10) NOT NULL,
    latitude DOUBLE NOT NULL,
    longitude DOUBLE NOT NULL,
    FOREIGN KEY (id_paciente) REFERENCES pacientes(id_paciente) ON DELETE CASCADE
);

-- Tabela de Preferências de Especialidades dos Pacientes
CREATE TABLE preferencia_especialidades (
    id_paciente INT NOT NULL,
    id_especialidade INT NOT NULL,
    PRIMARY KEY (id_paciente, id_especialidade),
    FOREIGN KEY (id_paciente) REFERENCES pacientes(id_paciente) ON DELETE CASCADE,
    FOREIGN KEY (id_especialidade) REFERENCES especialidades(id_especialidade) ON DELETE CASCADE
);

-- Tabela de Preferências de Abordagem dos Pacientes
CREATE TABLE preferencia_abordagens (
    id_paciente INT NOT NULL,
    id_abordagem INT NOT NULL,
    PRIMARY KEY (id_paciente, id_abordagem),
    FOREIGN KEY (id_paciente) REFERENCES pacientes(id_paciente) ON DELETE CASCADE,
    FOREIGN KEY (id_abordagem) REFERENCES abordagens(id_abordagem) ON DELETE CASCADE
);


-- ########## Tabelas de Relacionamento entre os Psicólogos e Pacientes ##########

-- Tabela de Consultas
CREATE TABLE consultas (
    id_consulta INT PRIMARY KEY AUTO_INCREMENT,
    id_psicologo INT NOT NULL,
    id_paciente INT NOT NULL,
    data_consulta TIMESTAMP NOT NULL,
    status ENUM('AGENDADA', 'CONCLUIDA', 'CANCELADA') NOT NULL DEFAULT 'AGENDADA',
    modalidade ENUM('REMOTA', 'PRESENCIAL') NOT NULL,
    tipo ENUM('COMUM', 'SOCIAL') NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_psicologo) REFERENCES psicologos(id_psicologo) ON DELETE CASCADE,
    FOREIGN KEY (id_paciente) REFERENCES pacientes(id_paciente) ON DELETE CASCADE
);


-- Tabela de Avaliações
CREATE TABLE avaliacoes (
    id_avaliacao INT PRIMARY KEY AUTO_INCREMENT,
    id_consulta INT UNIQUE NOT NULL, -- UNIQUE para garantir 1:1 com consultas
    id_paciente INT NOT NULL,
    id_psicologo INT NOT NULL,
    nota INT,
    CHECK (nota BETWEEN 1 AND 5), -- CHECK constraint para a nota
    comentario TEXT,
    data_avaliacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_consulta) REFERENCES consultas(id_consulta) ON DELETE CASCADE,
    FOREIGN KEY (id_paciente) REFERENCES pacientes(id_paciente) ON DELETE CASCADE,
    FOREIGN KEY (id_psicologo) REFERENCES psicologos(id_psicologo) ON DELETE CASCADE
);

-- Reabilita a verificação de chaves estrangeiras
SET FOREIGN_KEY_CHECKS = 1;

-- ########## Procedures e Triggers (Para referência e inclusão manual se necessário) ##########
-- As procedures e triggers foram adaptadas em um arquivo anterior (03_Transacoes_DTL.sql)
-- e podem ser adicionadas separadamente após a criação das tabelas, se você as desejar no mesmo script.
-- Para o propósito de recriação do SCHEMA, apenas as definições de tabelas são incluídas aqui.
-- Se você quiser as triggers e procedures aqui, por favor, me avise para adicioná-las.
