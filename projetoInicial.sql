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









