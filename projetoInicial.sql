CREATE DATABASE projetoInicial;

/*Criando tabela de Aluno*/
CREATE TABLE if not exists academico.aluno (
    id SERIAL PRIMARY KEY, /*Identificador único*/
	primeiro_nome VARCHAR(255) NOT NULL CHECK (primeiro_nome <> ''),
	ultimo_nome VARCHAR(255) NOT NULL,
	data_nascimento DATE NOT NULL DEFAULT NOW():: DATE
);

/*Criando tabela de categoria*/
CREATE TABLE academico.categoria (
    id SERIAL PRIMARY KEY,
	nome VARCHAR(255) NOT NULL UNIQUE
);

/*Criando tabela de curso*/
CREATE TABLE academico.curso (
    id SERIAL PRIMARY KEY,
	nome VARCHAR(255) NOT NULL,
	categoria_id INTEGER NOT NULL REFERENCES academico.categoria(id)
);

/*Criando tabela de aluno_curso*/
CREATE TABLE academico.aluno_curso (
	aluno_id INTEGER NOT NULL REFERENCES academico.aluno(id),
	curso_id INTEGER NOT NULL REFERENCES academico.curso(id),
	PRIMARY KEY (aluno_id, curso_id)
);

create schema academico;

drop table aluno;
drop table aluno_curso;
drop table categoria cascade;
drop view vw_cursos_por_categoria;
drop table curso cascade;


/*Inserindo valores a tabela de aluno*/
INSERT into aluno(primeiro_nome, ultimo_nome,data_nascimento) 
values ('Vinicius', 'Dias', '1997-10-15'),('Patricia', 'Freitas', '1986-10-25'),
('Diogo', 'Freitas', '1984-08-27'), ('Maria', 'Rosa', '1985-01-01');


/*Inserindo valores a tabela categoria*/
insert into categoria (nome) VALUES ('Front-end'),('Prorgramação'),('Banco de dados'),('Data Science');


/*Inserindo valores a tabela curso*/
INSERT into curso (nome, categoria_id) VALUES
('HTML',1),
('CSS',1),
('JS',1),
('PHP',2),
('JAVA',2),
('C++',2),
('PostgreSQL',3),
('MySQL', 3),
('Oracle', 3),
('SQL Server', 3),
('SQLite',3),
('Pandas', 4),
('Machine Learning', 4),
('Power BI', 4);


/*Inserindo valores a tabela aluno_curso*/
insert into aluno_curso values (1,4), (1,11),(2,1), (2,2), (3,4), (3,3), (4,4), (4,6), (4,5);

select * from aluno_curso;
select * from categoria;

/*Alterando nome de Data Science*/
update categoria set nome = 'Ciência de Dados' where id = 4;


/*Quantidade de curso por aluno (poderá alterar o limit)*/
select aluno.primeiro_nome, aluno.ultimo_nome, 
		count (aluno_curso.curso_id) numero_cursos 
	from aluno
		join aluno_curso ON aluno_curso.aluno_id = aluno.id
group by 1, 2
order by numero_cursos DESC
	limit 1;

/*Seleção de curso com quantidade de aluno*/
select curso.nome,
			count(aluno_curso.aluno_id) numero_alunos
	from curso
		join aluno_curso ON aluno_curso.curso_id = curso.id
group by 1
order by numero_alunos DESC
	limit 1;
	
select * from curso;
select * from categoria;

/*Selecionando com IN*/
select * from curso where categoria_id in (1,2);
select id FROM categoria where nome not like '% %';

/*Querie Aninhadas*/
select curso.nome from curso where categoria_id IN (
	select id from categoria where nome like '% de %');
	

/*Select buscando quantidade de cursos e quantas categorias existentes*/

select *
	FROM aluno
	JOIN aluno_curso ON aluno_curso.aluno_id = aluno.id
	JOIN curso ON curso.id = aluno_curso.curso_id;

select categoria.nome AS categoria,
		Count(curso.id) AS numero_cursos
	FROM categoria
	JOIN curso ON curso.categoria_id = categoria.id
GROUP BY categoria;

	
select categoria
		FROM (
				select categoria.nome AS categoria,
						Count(curso.id) AS numero_cursos
					FROM categoria
					JOIN curso ON curso.categoria_id = categoria.id
			GROUP BY categoria
		) AS categoria_cursos
	WHERE numero_cursos >= 3;
	
select * from categoria;

select curso.nome,
		count(aluno_curso.aluno_id) numero_alunos
	from curso
	join aluno_curso ON aluno_curso.curso_id = curso.id
group by 1
	having count(aluno_curso.aluno_id) > 2
order by numero_alunos DESC;

/*Corrigindo nome do curso*/
update categoria set nome = 'Programação' where id = 2;


/*Funcoes, concatenacao*/
select (primeiro_nome || ' ' || ultimo_nome) as nome_completo from aluno;

select concat('Vinicius', ' ', 'Dias');

/*UPPER (caixa alta) / TRIM (excluir os espacos do meio e fim)*/
select UPPER(concat('Vinicius', ' ', 'Dias'));
select TRIM(upper(concat('Vinicius', ' ', 'Dias')) || ' ');


/*Select extraindo o idade dos alunos*/
select (primeiro_nome || ' ' || ultimo_nome) as nome_completo, 
	EXTRACT (YEAR FROM AGE(data_nascimento)) AS idade 
from aluno;

/*Conversão para string*/
select TO_CHAR(NOW(), 'DD/MM/YYYY');
select TO_CHAR(NOW(), 'DD, MOUNT, YYYY');

/*Criando View*/

select categoria.id AS categoria_id, vw_cursos_por_categoria.*
		from vw_cursos_por_categoria
		JOIN categoria ON categoria.nome = vw_cursos_por_categoria.categoria;

create view vw_cursos_por_categoria AS
	select categoria.nome AS categoria,
						Count(curso.id) AS numero_cursos
					FROM categoria
					JOIN curso ON curso.categoria_id = categoria.id
			GROUP BY categoria;

create view vw_cursos_programacao as select nome from curso where categoria_id = 2;

select * from vw_cursos_programacao where nome = 'PHP';


--Função para tables de curso e categoria do curso

create function cria_curso(nome_curso VARCHAR, nome_categoria VARCHAR) returns void AS $$
	DECLARE
		id_categoria INTEGER;
	BEGIN
		select id INTO id_categoria from categoria where nome = nome_categoria;
		
		IF NOT FOUND THEN
			insert into categoria (nome) values (nome_categoria) returning id into id_categoria;
		END IF;
		
		INSERT INTO curso (nome,categoria_id) VALUES (nome_curso, id_categoria);
	END;
$$ language plpgsql;

select cria_curso('Java','Programação');
select * from curso;
select * from categoria;


/*Criando tabela de instrutores*/
create table instrutor (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(255) NOT NULL,
	salario DECIMAL (10, 2)
);

/*Inserindo dados de instrutores*/
insert into instrutor (nome,salario) values ('Vinicius Dias',100);
insert into instrutor (nome,salario) values ('Diogo Mascarenhas',200);
insert into instrutor (nome,salario) values ('Nico Steppat',300);
insert into instrutor (nome,salario) values ('Juliana',400);
insert into instrutor (nome,salario) values ('Priscila',500);

/*Criando função em programação SQL para dobrar o salario do instrutor*/
CREATE FUNCTION dobro_do_salario(instrutor) RETURNS DECIMAL AS $$ 
	SELECT $1.salario * 2 AS dobro;
$$ LANGUAGE SQL;

select nome, dobro_do_salario(instrutor.*) AS desejo FROM instrutor;

CREATE OR REPLACE FUNCTION cria_instrutor_falso() RETURNS instrutor AS $$
	SELECT 22, 'Nome falso', 200::DECIMAL;
$$ LANGUAGE SQL;

SELECT id, salario FROM cria_instrutor_falso();
select * from instrutor;

/*Criando função para conjunto de instrutores bem pagos*/
CREATE FUNCTION instrutores_bem_pagos(valor_salario DECIMAL) RETURNS SETOF instrutor AS $$
	SELECT * FROM instrutor where salario > valor_salario;
$$ LANGUAGE SQL;

select * from instrutores_bem_pagos(300);


/*Programando em PLpgSQL Função para verificação de aumento ou não para o instrutor*/

drop function salario_ok;
create function salario_ok(id_instrutor INTEGER) returns VARCHAR as $$
	DECLARE
		instrutor instrutor;
	BEGIN
		select * from instrutor where id = id_instrutor into instrutor;
		
		-- se o salário do instrutor for maior do que 300, está ok.Se for 300 reais, então pode aumentar. Caso contrário, o salário está defasado.
		/*IF instrutor.salario > 300 THEN
			return 'Salário está ok!';
		ELSEIF instrutor.salario = 300 THEN
			return 'Salário pode aumentar.';
		ELSE
			return 'Salário está defasado.';
		END IF;*/
		CASE instrutor.salario
			WHEN 100 THEN
				return 'Salário muito baixo';
			WHEN 200 THEN
				return 'Salário baixo';
			WHEN 300 THEN
				return 'Salário ok';
			ELSE
				return 'Salário ótimo';
		END CASE;
	END;
$$ language plpgsql;

/*Seleção de nome e salário do instrutor*/
select nome,salario_ok(instrutor.id) from instrutor;


/*Programando em PLpgSQL com função de tabuada com LOOP/WHILE/FOR*/

drop function tabuada;
create or replace function tabuada(numero INTEGER) returns setof VARCHAR as $$
	DECLARE
		multiplicador INTEGER DEFAULT 1;
	BEGIN
		--Multiplicador que começa com 1, e vai até < 10
		--numero * multiplicador
		--multiplicador := multiplicador + 1		
		LOOP
			-- 9 x 1 = 9
			RETURN NEXT numero || ' x ' || multiplicador || ' = ' || numero * multiplicador;
			multiplicador := multiplicador + 1;	
			EXIT WHEN multiplicador = 10;
		END LOOP;
	END;
$$ language plpgsql;

select tabuada(9);

/*Laco de repeticao WHILE*/
create or replace function tabuada(numero INTEGER) returns setof VARCHAR as $$
	DECLARE
		multiplicador INTEGER DEFAULT 1;
	BEGIN	
		WHILE multiplicador < 10 LOOP
			RETURN NEXT numero || ' x ' || multiplicador || ' = ' || numero * multiplicador;
			multiplicador := multiplicador + 1;	
		END LOOP;
	END;
$$ language plpgsql;


select tabuada(6);

drop function tabuada;

/*Laco de repeticao FOR*/
create or replace function tabuada(numero INTEGER) returns setof VARCHAR as $$
	declare
		multiplicador INTEGER default 1;
	begin
		FOR multiplicador IN 1..9 LOOP
			RETURN NEXT numero || ' x ' || multiplicador || ' = ' || numero * multiplicador;
		END LOOP;
	end;
$$language plpgsql;


drop function instrutor_com_salario;
create function instrutor_com_salario(out nome VARCHAR, out salario_ok VARCHAR) returns setof record AS $$
	declare
		instrutor instrutor;
	begin
		for instrutor in select * from instrutor loop
			nome := instrutor.nome;
			salario_ok = salario_ok(instrutor.id);
			
			return next;
		end loop;
	end;
$$language plpgsql;

select * from instrutor_com_salario();

/**
	*Inserir instrutores (com salários).
	*Se o salário for maior do que a média, salvar um log.
	*Salvar outro log dizendo que fulano recebe mais do que X% da grade de instrutores
*/

drop table log_instrutores;
drop function cria_instrutor;

CREATE TABLE log_instrutores (
	id SERIAL PRIMARY KEY,
	informacao VARCHAR(255),
	momento_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION cria_instrutor () RETURNS TRIGGER AS $$
	DECLARE
		media_salarial DECIMAL;
		instrutores_recebem_menos INTEGER DEFAULT 0;
		total_instrutores INTEGER DEFAULT 0;
		salario DECIMAL;
		percentual DECIMAL;
	BEGIN
		SELECT AVG(instrutor.salario) INTO media_salarial FROM instrutor WHERE id <> NEW.id;
		
		IF NEW.salario salario_instrutor > media_salarial THEN
			INSERT INTO log_instrutores (informacao) VALUES (NEW.nome || ' recebe acima da média');
		END IF;
		
		FOR salario IN SELECT instrutor.salario FROM instrutor WHERE id <> NEW.id LOOP
			total_instrutores := total_instrutores + 1;
			
			IF NEW.salario > salario THEN
				instrutores_recebem_menos := instrutores_recebem_menos + 1;
			END IF;
		END LOOP;
		
		percentual = instrutores_recebem_menos::DECIMAL / total_instrutores::DECIMAL * 100;
		
		INSERT INTO log_instrutores(informacao)
			VALUES(NEW.nome || ' recebe mais do que ' || percentual || '% da grade de instrutores.');
	END;
$$ LANGUAGE plpgsql;

/*Para terminar a funcao criar_instrutor*/
INSERT INTO instrutor (nome, salario) VALUES (nome_instrutor, salario_instrutor) RETURNING id INTO id_instrutor_inserido;


select * from instrutor;
select cria_instrutor('Luciana Vieira', 1000);
select cria_instrutor('Brendon Rodrigo',700);
select cria_instrutor('João',2000);
select cria_instrutor('Cleusa',5000);
select cria_instrutor('Juninho',1500);
select * from log_instrutores;

delete from instrutor where id = 9









