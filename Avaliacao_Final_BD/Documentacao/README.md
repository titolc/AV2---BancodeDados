Sistema de Conexão Psicólogo-Paciente

Identificação da Equipe

Nome do Projeto: Psiconnect

Integrantes da Equipe:
Augusto Junior - augusto.junior@edu.pe.senac.br
Cesar Kauan - [Matrícula/Email]
Christopher Lindoso - christopher.carvalho@edu.pe.senac.br
Diogo Florentino - diogo.barbosa@edu.pe.senac.br
Guilherme Pereira - [Matrícula/Email]
Lívia Vergete - [Matrícula/Email]

Visão Geral do Banco de Dados

Este repositório contém o projeto de banco de dados para um sistema de conexão entre psicólogos e pacientes. O banco de dados armazena informações cruciais para a plataforma, incluindo perfis de psicólogos (dados pessoais, formação, especialidades, abordagens, valores de consulta), perfis de pacientes (dados pessoais, benefícios sociais, preferências), dados de agendamento de consultas, avaliações e endereços associados a ambos os tipos de usuários. Ele é a espinha dorsal que sustenta as funcionalidades de busca, agendamento e feedback da aplicação.

Instruções de Restauração/Importação

Para configurar e popular o banco de dados MySQL em seu ambiente local, siga os passos abaixo:

Crie um Banco de Dados:

Abra seu cliente MySQL (ex: MySQL Workbench, DBeaver, terminal) e crie um novo banco de dados. Sugerimos o nome psicologia_db.

CREATE DATABASE psicologia_db;
USE psicologia_db;

Importe o Esquema do Banco de Dados:

Execute o script schema_completo.sql (localizado na pasta raiz deste projeto ou conforme a sua organização) para criar todas as tabelas e suas respectivas restrições.

SOURCE caminho/para/seu/projeto/schema_completo.sql;

(Substitua caminho/para/seu/projeto/ pelo caminho real do arquivo.)

Insira os Dados de Exemplo:

Após a criação do esquema, execute o script insert_data.sql (também localizado na pasta raiz ou conforme sua organização) para popular as tabelas com dados de exemplo.

SOURCE caminho/para/seu/projeto/insert_data.sql;

Explore Consultas DQL e Cenários DTL:

Os scripts 02_Consultas_DQL.sql (com consultas de demonstração) e 03_Transacoes_DTL.sql (com cenários de transação e stored procedures/triggers) podem ser explorados e executados para entender a lógica de negócio e as operações transacionais.

Para as consultas: Abra 02_Consultas_DQL.sql e execute as SELECT statements.

Para as transações: Abra 03_Transacoes_DTL.sql. As STORED PROCEDURES (AgendarNovaConsulta, CancelarConsulta, AvaliarConsulta) devem ser criadas primeiro (executando o bloco DELIMITER $$ ... DELIMITER ; de cada uma) e então podem ser chamadas usando CALL NomeDaProcedure(...).

Lista de Arquivos Entregues

A estrutura do projeto e a descrição dos arquivos são as seguintes:

Avaliacao_Final_BD/
├── 01_Modelagem/
│   ├── seu_arquivo_ERD.txt         # Diagrama Entidade-Relacionamento em formato textual.
│   └── 01_Modelagem.txt            # Comentários sobre escolhas de design e modelagem.
├── 02_Consultas_DQL/
│   ├── 02_Consultas_DQL.sql        # Scripts SQL com pelo menos 5 consultas avançadas (DQL).
│   └── 02_Consultas_DQL.txt        # Explicações detalhadas de cada consulta (objetivo, tabelas, resultado esperado).
├── 03_Transacoes_DTL/
│   ├── 03_Transacoes_DTL.sql       # Scripts SQL com cenários de transação (DTL), START TRANSACTION, SAVEPOINT, ROLLBACK, COMMIT.
│   └── 03_Transacoes_DTL.txt       # Descrição dos cenários de negócio das transações e tratamento de erros.
├── 04_Documentacao/
│   └── README.md                   # Visão geral do projeto, instruções de restauração e lista de arquivos (este arquivo).
├── 05_Apresentacao/
    └─ slides_apresentacao.pptx (ou PDF, PPT, etc.)


Dependências de Versão

Este projeto de banco de dados foi desenvolvido e testado com MySQL 8.0 ou superior. A utilização de CHECK constraints para validação de nota e a sintaxe de ENUM para tipos restritos de valores são totalmente suportadas e impostas a partir desta versão.

Observações Finais

Tipos ENUM: Utilizamos ENUM em várias colunas (ex: modalidade_atendimento, beneficio_social, status, modalidade, tipo) no lugar de CHECK constraints (comuns no PostgreSQL). Essa escolha é mais performática e idiomática no MySQL para garantir que os valores de uma coluna estejam restritos a um conjunto predefinido.

Gerenciamento de Erros em Triggers/Procedures: No MySQL, o tratamento de erros dentro de stored procedures e triggers é feito principalmente através de SIGNAL SQLSTATE, que simula o RAISE EXCEPTION do PostgreSQL. Isso garante que as validações de negócio, como a aplicação de valor social ou a verificação de status de consulta, resultem em erros claros e revertam a transação quando necessário.

ON DELETE CASCADE: A decisão de usar ON DELETE CASCADE em todas as chaves estrangeiras visa simplificar a gestão da integridade em casos de exclusão de registros pai. No entanto, em um ambiente de produção, uma análise mais profunda pode ser necessária para determinar se outras estratégias (ex: ON DELETE RESTRICT ou ON DELETE SET NULL) seriam mais adequadas para cenários específicos, a fim de evitar perdas acauteladas de dados.
