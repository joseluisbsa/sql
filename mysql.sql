Delimiter ;; 

create procedure atualiza_demissao(
		in vCodFuncionario int,
                in vAttDemissao timestamp
                ) 
language sql
begin 

	update funcionario
	set dt_demissao = vAttDemissao
	where cd_funcionario = vCodFuncionario;

end;; 

call atualiza_demissao(2, '2017-04-11')

-----------------------------------------------------------

Delimiter ;; 

create procedure aumenta_salario(
				in vCodFuncionario int
                ) 
language sql
begin 

	set @vCargo=0;

	select cd_cargo into @vCargo
	from funcionario
	where cd_funcionario = vCodFuncionario;
    
    if @vCargo = 1 
		then update funcionario set vl_salario = vl_salario*1.1 where cd_funcionario = vCodFuncionario;
    else if @vCargo = 2
		then update funcionario set vl_salario = vl_salario*1.15 where cd_funcionario = vCodFuncionario;
	else
		update funcionario set vl_salario = vl_salario*1.05 where cd_funcionario = vCodFuncionario;
    end if;
    end if;

end;; 

call aumenta_salario(4);

---------------------------------------------------------


Delimiter ;; 
create procedure situacao_profissional(
				in vCodProfissional int
                ) 
language sql
begin 
	
    set @vNome = "";
    set @vObito = null;
    -- set @vSituacao = "";
    
	select nm_profissional into @vNome
	from profissional
	where cd_profissional = vCodProfissional;
    
	select dt_obito_profissional into @vObito
	from profissional
	where cd_profissional = vCodProfissional;
    
    if @vObito is null 
		then set @vSituacao = "Vivo";
	else	
		set @vSituacao = "Falecido";
	end if;
        
	select @vNome Profissional, @vSituacao Situacao;

end;; 

call situacao_profissional(20);

---------------------------------------------------------

insert into FUNCAO (cd_funcao,nm_funcao) values(1,'Ator/Atriz');
insert into FUNCAO (cd_funcao,nm_funcao) values(2,'Diretor(a)');

DELIMITER ;;
create procedure sp_add_filme_profissional
				(in vCodProf integer,
                in vCodFilme integer,
                in vCodFuncao integer)
begin
	
    declare v_cod_filme_profissional tinyint default(1);
    
    insert into FILME_PROFISSIONAL (cd_profissional, cd_filme, cd_funcao) values(vCodProf, vCodFilme, vCodFuncao);
    
    select last_insert_id() into v_cod_filme_profissional;
    
    select fil.nm_filme "Nome do Filme",
    prof.nm_profissional "Nome do Profissional",
    func.nm_funcao "Função no Filme"
    from FILME_PROFISSIONAL fpro
    inner join filme fil 
    on fil.cd_filme = fpro.cd_filme
    inner join profissional prof 
    on prof.cd_profissional = fpro.cd_profissional
    inner join funcao func 
    on func.cd_funcao = fpro.cd_funcao
	where cd_filme_profissional = v_cod_filme_profissional;
    
END;;

call sp_add_filme_profissional(27,19,2)
call sp_add_filme_profissional(20,12,1)

-------------------------------------------------------------------------------------------------

DELIMITER;;
create procedure sp_add_sessao(
				in p_dt_inicio timestamp,
				in p_cd_sala smallint,
				in p_cd_programacao integer)
				
BEGIN
	declare v_cont_programacao integer;
	declare v_cont_salas integer;
	declare v_cd_sessao integer;
	
	-- sala
	select count(cd_sala) into v_cont_salas
	from sala
	where cd_sala = p_cd_sala;
	
	-- programacao
	select count(cd_programacao) into v_cont_programacao
	from programacao
	where cd_programacao = p_cd_programacao;
	
	if v_cont_salas = 0 then
		SIGNAL SQLSTATE 45100 
		SET MESSAGE_TEXT = "Sala não encontrada";
	end if;
	
	if v_cont_programacao = 0 then
		SIGNAL SQLSTATE '45100' 
		SET MESSAGE_TEXT = 'Programacao não encontrada';
	end if;
	
	select count(cd_programacao) into v_cont_programacao
	from programacao
	where dt_inicio <= p_dt_inicio
	and dt_fim >= p_dt_inicio;
	
	if v_cont_programacao = 0 then
		SIGNAL SQLSTATE '45100'
		SET MESSAGE_TEXT = 'Sessão fora do intervalo';
	end if;
	
	insert into sessao(
				cd_sala,
				cd_programacao,
				dt_sessao_inicio,
				dt_sessao_fim
				)
			values(
				p_cd_sala,
				p_cd_programacao,
				p_dt_inicio,
				DATE_ADD(p_dt_inicio,INTERVAL 2 HOUR)
				);
	
	select last_insert_id() into v_cd_sessao
	
	select fil.nm_filme "Nome do filme",
			sal.nm_sala "Nome da sala",
			com.nm_complexo "Nome do complexo",
			ses.dt_sessao_inicio "Inicio da sessao",
			ses.dt_sessao_fim "Final da sessao"
	from programacao pog
	inner join filme fil on pog.cd_filme = fil.cd_filme
	inner join complexo com on pog.cd_complexo = com.cd_complexo
	inner join sessao ses on pog.cd_programacao = ses.cd_programacao
	inner join sala sal on sal.cd_sala = ses.cd_sala
	where ses.cd_sessao = v_cd_sessao;

END;;

call sp_add_sessao('2017-04-10 21:00:00', 10, 3); -- deu erro
call sp_add_sessao('2017-04-25 21:00:00', 2, 3); -- deu erro 
call sp_add_sessao('2017-04-13 21:00:00', 2, 3); -- deu certo 

--------------------------------------------------------------------------------------

-- tabela que faremos a carga
select * from funcionario;

-- como sortear um numero de 1 até 10 (inclui-se 1 e 10);
select floor(1 + RAND() * 10);

-- criar uma tabela temporaria chamada priNomes
create table priNomes(
	codigo integer not null AUTO_INCREMENT,
	nome varchar(30) not null,
	genero char(1) not null,
	primary key (codigo)
) ENGINE = MyISAM;

set @@AUTO_INCREMENT_INCREMENT = 1;
insert into priNomes (nome, genero) values ('Dilma', 'F'); -- criar varios

create table sobreNomes(
	codigo integer not null AUTO_INCREMENT,
	nome varchar(30) not null,
	genero char(1) not null,
	primary key (codigo)
) ENGINE = MyISAM;

set @@AUTO_INCREMENT_INCREMENT = 1;
insert into sobreNomes (nome) values ('Silva');

DELIMITER ;;
create procedure sp_generate()
begin
	set @i = 1;
	set @@AUTO_INCREMENT_INCREMENT = 1;
	while @i <= 1000 do
		select floor(1 + RAND() * 38) into @numero1;
		select floor(1 + RAND() * 42) into @numero2;
		select nome into @priNome from priNomes where codigo = @numero1;
		select nome into @sobreNome from sobreNomes where codigo = @numero2;
		
		insert into funcionario
			(nm_funcionario,
			 nu_rg_funcionario,
			 nu_cpf_funcionario,
			 cd_cargo,
			 vl_salario,
			 dt_admissao,
			 dt_demissao,
			 cd_gerente)
		values
		 (CONCAT(@priNome, ' ', @sobreNome)
		    from priNomes 
		    where codigo = FLOOR(1 + RAND() * 38) 
		 )
		 
		
		set i = i + 1;
	end while;
end ;;
DELIMITER ;		  

-------------------------------------------------------------------------------

                        -- DROP PROCEDURE sp_ingressos;
DELIMITER $$
CREATE PROCEDURE sp_ingressos()
BEGIN
	SET @i = 1;
	SET @@AUTO_INCREMENT_INCREMENT = 1;
	
	SELECT COUNT(cd_sessao) INTO @quant_sessao
	FROM sessao;
	
	SELECT COUNT(cd_venda) INTO @quant_venda
	FROM venda;

	SELECT COUNT(DISTINCT cd_numero_assento) INTO @quant_assento
	FROM assento;
	
	WHILE @i <= 100 DO
		SELECT FLOOR(1 + RAND()* @quant_sessao) INTO @randon_sessao;
		SELECT FLOOR(1 + RAND()* @quant_venda) INTO @randon_venda;
		SELECT FLOOR(1 + RAND()* @quant_assento) INTO @randon_assento;
		
		SELECT cd_venda INTO @cd_venda_v 
		FROM venda WHERE cd_venda = @randon_venda;
		
		SELECT cd_sessao, cd_sala INTO @cd_sessao_v, @cd_sala_v
		FROM sessao WHERE cd_sessao = @randon_sessao;
		
		SELECT cd_tipo_sala INTO @cd_tipo_sala_v
		FROM sala WHERE cd_sala = @cd_sala_v;
		
		SELECT vl_tipo_sala INTO @vl_ingresso_v
		FROM tipo_sala WHERE cd_tipo_sala = @cd_tipo_sala_v;
		
		SELECT cd_numero_assento, cd_letra_assento 
		INTO @cd_numero_assento_v, @cd_letra_assento_v
		FROM assento WHERE cd_numero_assento = @randon_assento
		AND cd_sala = @cd_sala_v;
		
		INSERT INTO ingresso
			(cd_numero_assento, cd_letra_assento,
			cd_sessao, cd_venda, vl_ingresso)
		VALUES	
			(@cd_numero_assento_v,
			@cd_letra_assento_v,
			@cd_sessao_v,
			@cd_venda_v,
			@vl_ingresso_v);
		
		SET @i = @i + 1;
	END WHILE;
END $$
DELIMITER;

CALL sp_ingressos;
SELECT * FROM ingresso;

--------------------------------------------------------------------------------------

DROP PROCEDURE sp_add_sessao;

DELIMITER $$
CREATE PROCEDURE sp_add_sessao
(IN p_dt_inicio TIMESTAMP,
 IN p_cd_sala SMALLINT,
 IN p_cd_programacao INTEGER)
BEGIN
	DECLARE v_count_salas INTEGER;
    DECLARE v_count_programacao INTEGER;
    DECLARE v_cd_sessao INTEGER;

	-- SALA
    SELECT count(cd_sala) INTO v_count_salas
    FROM sala
    WHERE cd_sala = p_cd_sala;
    
    SELECT count(cd_programacao) INTO v_count_programacao
    FROM programacao
    WHERE cd_programacao = p_cd_programacao;
    
    IF v_count_salas = 0 THEN
		SIGNAL SQLSTATE '45100'
        SET MESSAGE_TEXT = 'Sala inexistente';
    END IF;
    
    IF v_count_programacao = 0 THEN
		SIGNAL SQLSTATE '45100' 
        SET MESSAGE_TEXT = 'Programação inexistente';
    END IF;
    
	SELECT count(cd_programacao) INTO v_count_programacao
    FROM programacao
    WHERE dt_inicio <= p_dt_inicio
    AND dt_fim >= p_dt_inicio;
    
    IF v_count_programacao = 0 THEN
		SIGNAL SQLSTATE '45100'
        SET MESSAGE_TEXT = 'Sessão fora do intervalo';
    END IF;
    
    INSERT INTO sessao
    (cd_sala,
     cd_programacao,
     dt_sessao_inicio,
     dt_sessao_fim)
     VALUES
     (
		p_cd_sala,
        p_cd_programacao,
        p_dt_inicio,
        DATE_ADD(p_dt_inicio,INTERVAL 2 HOUR)
	 );
     SELECT last_insert_id() INTO v_cd_sessao; 
     
     SELECT fil.nm_filme "Nome do Filme", 
			sal.nm_sala "Nome da Sala",
            com.nm_complexo "Nome do Complexo", 
            ses.dt_sessao_inicio "Início da Sessão",
            ses.dt_sessao_fim "Fim da Sessão"
	FROM programacao pog
    INNER JOIN filme fil
    ON pog.cd_filme = fil.cd_filme
    INNER JOIN complexo com
    ON pog.cd_complexo = com.cd_complexo
    INNER JOIN sessao ses
    ON pog.cd_programacao = ses.cd_programacao
    INNER JOIN sala sal
    ON sal.cd_sala = ses.cd_sala
    WHERE ses.cd_sessao = v_cd_sessao;
END$$
DELIMITER ;

CALL sp_add_sessao('2017-04-10 21:00:00',10,3); --deu erro
CALL sp_add_sessao('2017-04-25 21:00:00',2,3); --deu erro
CALL sp_add_sessao('2017-04-13 21:00:00',2,3);
                    
SELECT * FROM sala;
