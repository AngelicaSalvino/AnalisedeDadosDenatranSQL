--Retorna os dados do ano de 2021

SELECT * FROM detran_frota_br_uf dfbu 
WHERE ano = 2021;


--Visão geral do volume de veículos registrados em ‘SP’ ao longo do ano de 2014 
--onde percebe-se que os dados são atualizados mês a mês (tendo acréscimo e/ou decréscimo) em cada tipo:

SELECT *  FROM detran_frota_br_uf dfbu  
WHERE sigla_uf = 'SP' AND ano = 2004
ORDER BY mes 


--Variação percentual do aumento/recuo da quantidade total de veículos por região ao longo dos anos:

WITH DadosPorAno AS (
    SELECT
        CASE
            WHEN sigla_uf IN ('AM', 'PA', 'RR', 'RO', 'AC', 'TO', 'AP') THEN 'Região Norte'
            WHEN sigla_uf IN ('MA', 'PI', 'PE', 'RN', 'SE', 'BA', 'PB', 'CE', 'AL') THEN 'Região Nordeste'
            WHEN sigla_uf IN ('MT', 'MS', 'GO', 'DF') THEN 'Região Centro-Oeste'
            WHEN sigla_uf IN ('MG', 'SP', 'RJ', 'ES') THEN 'Região Sudeste'
            WHEN sigla_uf IN ('PR', 'SC', 'RS') THEN 'Região Sul'
            ELSE 'Outro'
        END AS regiao,
        ano,
        SUM(total) AS total_veiculos
    FROM denatran_frota_municipio_tipo
    WHERE ano BETWEEN 2003 AND 2020 AND mes = 12
    GROUP BY regiao, ano
)
SELECT
    regiao,
    ano,
    total_veiculos,
    ROUND(100.0 * (total_veiculos - LAG(total_veiculos) OVER (PARTITION BY regiao ORDER BY ano)) / LAG(total_veiculos) OVER (PARTITION BY regiao ORDER BY ano), 0) AS variacao_percentual
FROM DadosPorAno
ORDER BY regiao, ano;


--Retorna o total de veículos por estado no ano de 2020, 
--considerando a soma do total de veículos registrados no mês 12

WITH DadosAno AS (
    SELECT
        CASE
            WHEN sigla_uf IN ('AM', 'PA', 'RR', 'RO', 'AC', 'TO', 'AP') THEN 'Região Norte'
            WHEN sigla_uf IN ('MA', 'PI', 'PE', 'RN', 'SE', 'BA', 'PB', 'CE', 'AL') THEN 'Região Nordeste'
            WHEN sigla_uf IN ('MT', 'MS', 'GO', 'DF') THEN 'Região Centro-Oeste'
            WHEN sigla_uf IN ('MG', 'SP', 'RJ', 'ES') THEN 'Região Sudeste'
            WHEN sigla_uf IN ('PR', 'SC', 'RS') THEN 'Região Sul'
            ELSE 'Outro'
        END AS regiao,
        sigla_uf AS estado,
        SUM(automovel + caminhao + chassiplataforma + caminhaotrator + caminhonete + camioneta + utilitario + tratoresteira + tratorrodas + onibus + microonibus + reboque + semireboque) AS Total_Veiculos
    FROM denatran_frota_municipio_tipo
    WHERE ano = 2020 AND mes = 12
    GROUP BY regiao, estado
)
SELECT
    regiao,
    estado,
    Total_Veiculos DESC
FROM DadosAno;

--Quais grupos de veículos têm maior representatividade por regiões geográficas e estados?
--Considerando apenas o ano de 2020.

WITH DadosPorRegiaoEstado AS (
    SELECT
        CASE
            WHEN sigla_uf IN ('AM', 'PA', 'RR', 'RO', 'AC', 'TO', 'AP') THEN 'Região Norte'
            WHEN sigla_uf IN ('MA', 'PI', 'PE', 'RN', 'SE', 'BA', 'PB', 'CE', 'AL') THEN 'Região Nordeste'
            WHEN sigla_uf IN ('MT', 'MS', 'GO', 'DF') THEN 'Região Centro-Oeste'
            WHEN sigla_uf IN ('MG', 'SP', 'RJ', 'ES') THEN 'Região Sudeste'
            WHEN sigla_uf IN ('PR', 'SC', 'RS') THEN 'Região Sul'
            ELSE 'Outro'
        END AS regiao,
        sigla_uf AS estado,
        ano,
        SUM(automovel) AS Veiculos_de_Passeio,
        SUM(caminhao + chassiplataforma + caminhaotrator + caminhonete + camioneta + utilitario + tratoresteira + tratorrodas + reboque + semireboque) AS Veiculos_de_Carga,
        SUM(motocicleta + motoneta) AS Motocicletas,
        SUM(onibus + microonibus) AS Veiculos_Passageiros,
        SUM(quadriciclo + triciclo + sidecar) AS Veiculos_Especiais
    FROM denatran_frota_municipio_tipo
   WHERE ano = 2020 AND mes = 12
    GROUP BY regiao, estado, ano
)
SELECT
    regiao,
    estado,
    ano,
    MAX(Veiculos_de_Passeio) AS Veiculos_de_Passeio,
    MAX(Veiculos_de_Carga) AS Veiculos_de_Carga,
    MAX(Motocicletas) AS Motocicletas,
    MAX(Veiculos_Passageiros) AS Veiculos_Passageiros,
    MAX(Veiculos_Especiais) AS Veiculos_Especiais
FROM DadosPorRegiaoEstado
GROUP BY regiao, estado, ano
ORDER BY regiao, estado, ano;

-- Cálculos estatísticos da distribuição de veículos por estado e município, sendo eles: 
--Total de Veículos, Média de Veículos, Mediana de Veículos, Min Veículos e Máximo de Veículos

SELECT
    sigla_uf,
    SUM(DISTINCT id_municipio),
    SUM(total) as total_veiculos,
    ROUND(AVG(total),2) as media_veiculos,
    MEDIAN(total) as mediana_veiculos,
    MIN(total) as min_veiculos,
    MAX(total) as max_veiculos
FROM denatran_frota_municipio_tipo
WHERE sigla_uf = 'SP' AND ano = 2014
GROUP BY sigla_uf, id_municipio
ORDER BY sigla_uf, id_municipio DESC


--Retorna por categoria a média, mediana e o total no ano
--Ano 2020 estado de ‘SP’

SELECT
    'Veículos de Passeio' as categoria,
    ROUND(AVG(automovel),2) as media,
    MEDIAN(automovel) as mediana,
    SUM(automovel) as total
FROM denatran_frota_municipio_tipo
WHERE ano = 2020 AND sigla_uf = 'SP' AND mes = 12

UNION

SELECT
    'Veículos de Carga' as categoria,
    ROUND(AVG(caminhao + chassiplataforma + caminhaotrator + caminhonete + camioneta + utilitario + tratoresteira + tratorrodas + reboque + semireboque),2) as media,
    MEDIAN(caminhao + chassiplataforma + caminhaotrator + caminhonete + camioneta + utilitario + tratoresteira + tratorrodas + reboque + semireboque) as mediana,
    SUM(caminhao + chassiplataforma + caminhaotrator + caminhonete + camioneta + utilitario + tratoresteira + tratorrodas + reboque + semireboque) as total
FROM denatran_frota_municipio_tipo
WHERE ano = 2020 AND sigla_uf = 'SP' AND mes = 12

UNION

SELECT
    'Veículos de Passageiros' as categoria,
    ROUND(AVG(onibus + microonibus),2) as media,
    MEDIAN(onibus + microonibus) as mediana,
    SUM(onibus + microonibus) as total
FROM denatran_frota_municipio_tipo
WHERE ano = 2020 AND sigla_uf = 'SP' AND mes = 12

UNION

SELECT
    'Motocicletas' as categoria,
    ROUND(AVG(motocicleta + motoneta),2) as media,
    MEDIAN(motocicleta + motoneta) as mediana,
    SUM(motocicleta + motoneta) as total
FROM denatran_frota_municipio_tipo
WHERE ano = 2020 AND sigla_uf = 'SP'

UNION

SELECT
    'Veículos Especiais' as categoria,
    ROUND(AVG(quadriciclo + triciclo + sidecar),2) as media,
    MEDIAN(quadriciclo + triciclo + sidecar) as mediana,
    SUM(quadriciclo + triciclo + sidecar) as total
FROM denatran_frota_municipio_tipo
WHERE ano = 2020 AND sigla_uf = 'SP' AND mes = 12
ORDER BY categoria;


--Retorna o total de municípios por estado ordenado em ordem decrescente de municípios

SELECT sigla_uf, COUNT(DISTINCT id_municipio) AS total_municipios, SUM(total) AS total_veiculos
FROM denatran_frota_municipio_tipo
WHERE mes = 12 AND ano = 2020
GROUP BY sigla_uf
ORDER BY total_municipios DESC;



--Retorna a contagem de municípios por região e o total de veículos,
--considerando o mês de dezembro do ano de 2020

SELECT
    CASE
        WHEN sigla_uf IN ('AM', 'PA', 'RR', 'RO', 'AC', 'TO', 'AP') THEN 'Região Norte'
        WHEN sigla_uf IN ('MA', 'PI', 'PE', 'RN', 'SE', 'BA', 'PB', 'CE', 'AL') THEN 'Região Nordeste'
        WHEN sigla_uf IN ('MT', 'MS', 'GO', 'DF') THEN 'Região Centro-Oeste'
        WHEN sigla_uf IN ('MG', 'SP', 'RJ', 'ES') THEN 'Região Sudeste'
        WHEN sigla_uf IN ('PR', 'SC', 'RS') THEN 'Região Sul'
        ELSE 'Outro'
    END AS regiao,
    COUNT(DISTINCT id_municipio) AS total_municipios,
    SUM(total) AS total_veiculos
FROM denatran_frota_municipio_tipo
WHERE mes = 12 AND ano = 2020
GROUP BY regiao
ORDER BY total_municipios DESC;



--Categorização dos veículos
--Levando em consideração apenas o ano de 2020 e o mês de dezembro

SELECT
    'Veículos de Passeio' as categoria,
     SUM(automovel) as total
FROM denatran_frota_municipio_tipo
WHERE ano = 2020 AND mes = 12

UNION

SELECT
    'Veículos de Carga' as categoria,
    SUM(caminhao + chassiplataforma + caminhaotrator + caminhonete + camioneta + utilitario + tratoresteira + tratorrodas + reboque + semireboque) as total
FROM denatran_frota_municipio_tipo
WHERE ano = 2020 AND mes = 12

UNION

SELECT
    'Veículos de Passageiros' as categoria,
    SUM(onibus + microonibus) as total
FROM denatran_frota_municipio_tipo
WHERE ano = 2020 AND mes = 12

UNION

SELECT
    'Motocicletas' as categoria,
     SUM(motocicleta + motoneta) as total
FROM denatran_frota_municipio_tipo
WHERE ano = 2020 AND mes = 12

UNION

SELECT
    'Veículos Especiais' as categoria,
     SUM(quadriciclo + triciclo + sidecar) as total
FROM denatran_frota_municipio_tipo
WHERE ano = 2020 AND mes = 12
ORDER BY categoria DESC;


--Agrupamento dos Veículos por Regiões Geográficas
--Do ano de 2013 a 2020 e considerando o último mês do ano (dezembro)

SELECT
    regiao,
    SUM(CASE WHEN ano = 2013 AND mes = 12 THEN total ELSE 0 END) AS total_veiculos_2013,
    SUM(CASE WHEN ano = 2014 AND mes = 12 THEN total ELSE 0 END) AS total_veiculos_2014,
    SUM(CASE WHEN ano = 2015 AND mes = 12 THEN total ELSE 0 END) AS total_veiculos_2015,
    SUM(CASE WHEN ano = 2016 AND mes = 12 THEN total ELSE 0 END) AS total_veiculos_2016,
    SUM(CASE WHEN ano = 2017 AND mes = 12 THEN total ELSE 0 END) AS total_veiculos_2017,
    SUM(CASE WHEN ano = 2018 AND mes = 12 THEN total ELSE 0 END) AS total_veiculos_2018,
    SUM(CASE WHEN ano = 2019 AND mes = 12 THEN total ELSE 0 END) AS total_veiculos_2019,
    SUM(CASE WHEN ano = 2020 AND mes = 12 THEN total ELSE 0 END) AS total_veiculos_2020
FROM (
    SELECT
        CASE
            WHEN sigla_uf IN ('AM', 'PA', 'RR', 'RO', 'AC', 'TO', 'AP') THEN 'Região Norte'
            WHEN sigla_uf IN ('MA', 'PI', 'PE', 'RN', 'SE', 'BA', 'PB', 'CE', 'AL') THEN 'Região Nordeste'
            WHEN sigla_uf IN ('MT', 'MS', 'GO', 'DF') THEN 'Região Centro-Oeste'
            WHEN sigla_uf IN ('MG', 'SP', 'RJ', 'ES') THEN 'Região Sudeste'
            WHEN sigla_uf IN ('PR', 'SC', 'RS') THEN 'Região Sul'
            ELSE 'Outro'
        END AS regiao,
        ano,
        mes,
        total
    FROM denatran_frota_municipio_tipo dfmt 
    WHERE ano BETWEEN 2013 AND 2021
) AS dados
GROUP BY regiao

UNION ALL

SELECT
    'Total Geral',
    SUM(CASE WHEN ano = 2013 AND mes = 12 THEN total ELSE 0 END),
    SUM(CASE WHEN ano = 2014 AND mes = 12 THEN total ELSE 0 END),
    SUM(CASE WHEN ano = 2015 AND mes = 12 THEN total ELSE 0 END),
    SUM(CASE WHEN ano = 2016 AND mes = 12 THEN total ELSE 0 END),
    SUM(CASE WHEN ano = 2017 AND mes = 12 THEN total ELSE 0 END),
    SUM(CASE WHEN ano = 2018 AND mes = 12 THEN total ELSE 0 END),
    SUM(CASE WHEN ano = 2019 AND mes = 12 THEN total ELSE 0 END),
    SUM(CASE WHEN ano = 2020 AND mes = 12 THEN total ELSE 0 END)
FROM (
    SELECT
        CASE
            WHEN sigla_uf IN ('AM', 'PA', 'RR', 'RO', 'AC', 'TO', 'AP') THEN 'Região Norte'
            WHEN sigla_uf IN ('MA', 'PI', 'PE', 'RN', 'SE', 'BA', 'PB', 'CE', 'AL') THEN 'Região Nordeste'
            WHEN sigla_uf IN ('MT', 'MS', 'GO', 'DF') THEN 'Região Centro-Oeste'
            WHEN sigla_uf IN ('MG', 'SP', 'RJ', 'ES') THEN 'Região Sudeste'
            WHEN sigla_uf IN ('PR', 'SC', 'RS') THEN 'Região Sul'
            ELSE 'Outro'
        END AS regiao,
        ano,
        mes,
        total
    FROM denatran_frota_municipio_tipo dfmt 
    WHERE ano BETWEEN 2013 AND 2021
) AS dados;


--Retorna o total de veículos por região ao longo dos anos
--considerando o mês de dezembro para cada ano(coluna total de veículos)

SELECT
    regiao,
    SUM(CASE WHEN ano = 2013 THEN total ELSE 0 END) AS total_veiculos_2013,
    SUM(CASE WHEN ano = 2014 THEN total ELSE 0 END) AS total_veiculos_2014,
    SUM(CASE WHEN ano = 2015 THEN total ELSE 0 END) AS total_veiculos_2015,
    SUM(CASE WHEN ano = 2016 THEN total ELSE 0 END) AS total_veiculos_2016,
    SUM(CASE WHEN ano = 2017 THEN total ELSE 0 END) AS total_veiculos_2017,
    SUM(CASE WHEN ano = 2018 THEN total ELSE 0 END) AS total_veiculos_2018,
    SUM(CASE WHEN ano = 2019 THEN total ELSE 0 END) AS total_veiculos_2019,
    SUM(CASE WHEN ano = 2020 THEN total ELSE 0 END) AS total_veiculos_2020,
    SUM(CASE WHEN ano = 2021 THEN total ELSE 0 END) AS total_veiculos_2021
FROM (
    SELECT
        CASE
            WHEN sigla_uf IN ('AM', 'PA', 'RR', 'RO', 'AC', 'TO', 'AP') THEN 'Região Norte'
            WHEN sigla_uf IN ('MA', 'PI', 'PE', 'RN', 'SE', 'BA', 'PB', 'CE', 'AL') THEN 'Região Nordeste'
            WHEN sigla_uf IN ('MT', 'MS', 'GO', 'DF') THEN 'Região Centro-Oeste'
            WHEN sigla_uf IN ('MG', 'SP', 'RJ', 'ES') THEN 'Região Sudeste'
            WHEN sigla_uf IN ('PR', 'SC', 'RS') THEN 'Região Sul'
            ELSE 'Outro'
        END AS regiao,
        ano,
        mes,
        total
    FROM detran_frota_br_uf
    WHERE ano BETWEEN 2013 AND 2021 AND mes = 12
) AS dados
GROUP BY regiao
ORDER BY regiao;


--Retorna o crescimento de veículos por região e classifica do menor para o maior (região)
--Quantidade máxima / quantidade mínima de veículos e a variação percentual

WITH DadosPorAno AS (
    SELECT
        CASE
            WHEN sigla_uf IN ('AM', 'PA', 'RR', 'RO', 'AC', 'TO', 'AP') THEN 'Região Norte'
            WHEN sigla_uf IN ('MA', 'PI', 'PE', 'RN', 'SE', 'BA', 'PB', 'CE', 'AL') THEN 'Região Nordeste'
            WHEN sigla_uf IN ('MT', 'MS', 'GO', 'DF') THEN 'Região Centro-Oeste'
            WHEN sigla_uf IN ('MG', 'SP', 'RJ', 'ES') THEN 'Região Sudeste'
            WHEN sigla_uf IN ('PR', 'SC', 'RS') THEN 'Região Sul'
            ELSE 'Outro'
        END AS regiao,
        ano,
        SUM(total) AS total_veiculos
    FROM denatran_frota_municipio_tipo dfmt
    WHERE ano BETWEEN 2003 AND 2020 AND mes = 12
    GROUP BY regiao, ano
)
SELECT
    regiao,
    MAX(total_veiculos) AS max_veiculos,
    MIN(total_veiculos) AS min_veiculos,
    ROUND(100.0 * (MAX(total_veiculos) - MIN(total_veiculos)) / MIN(total_veiculos), 2) AS crescimento_percentual
FROM DadosPorAno
GROUP BY regiao
ORDER BY crescimento_percentual DESC;



--Cálculo da variação percentual da frota de veículos em relação ao ano anterior para cada região
--ao longo dos anos de 2003 a 2020

WITH DadosPorAno AS (
    SELECT
        CASE
            WHEN sigla_uf IN ('AM', 'PA', 'RR', 'RO', 'AC', 'TO', 'AP') THEN 'Região Norte'
            WHEN sigla_uf IN ('MA', 'PI', 'PE', 'RN', 'SE', 'BA', 'PB', 'CE', 'AL') THEN 'Região Nordeste'
            WHEN sigla_uf IN ('MT', 'MS', 'GO', 'DF') THEN 'Região Centro-Oeste'
            WHEN sigla_uf IN ('MG', 'SP', 'RJ', 'ES') THEN 'Região Sudeste'
            WHEN sigla_uf IN ('PR', 'SC', 'RS') THEN 'Região Sul'
            ELSE 'Outro'
        END AS regiao,
        ano,
        SUM(total) AS total_veiculos
    FROM detran_frota_br_uf
    WHERE ano BETWEEN 2003 AND 2020 AND mes = 12
    GROUP BY regiao, ano
)
SELECT
    regiao,
    ano,
    total_veiculos,
    LAG(total_veiculos) OVER (PARTITION BY regiao ORDER BY ano) AS total_veiculos_anterior,
    ROUND(100.0 * (total_veiculos - LAG(total_veiculos) OVER (PARTITION BY regiao ORDER BY ano)) / LAG(total_veiculos) OVER (PARTITION BY regiao ORDER BY ano), 2) AS variacao_percentual
FROM DadosPorAno
ORDER BY regiao, ano;


--Quais as categorias com maior volume de veículos comparando de 2016 a 2020?
--Retorna o valor por categoria ao longo de 2016 a 2020

SELECT
    categoria,
    SUM(CASE WHEN ano = 2016 AND mes = 12 THEN total ELSE 0 END) as total_2016,
    SUM(CASE WHEN ano = 2017 AND mes = 12 THEN total ELSE 0 END) as total_2017,
    SUM(CASE WHEN ano = 2018 AND mes = 12 THEN total ELSE 0 END) as total_2018,
    SUM(CASE WHEN ano = 2019 AND mes = 12 THEN total ELSE 0 END) as total_2019,
    SUM(CASE WHEN ano = 2020 AND mes = 12 THEN total ELSE 0 END) as total_2020
FROM (
    SELECT
        'Veículos de Passeio' as categoria,
        ano,
        mes,
        SUM(automovel) as total
    FROM denatran_frota_municipio_tipo dfmt 
    GROUP BY categoria, ano, mes

    UNION

    SELECT
        'Veículos de Carga' as categoria,
        ano,
        mes,
        SUM(caminhao + chassiplataforma + caminhaotrator + caminhonete + camioneta + utilitario + tratoresteira + tratorrodas + onibus + microonibus + reboque + semireboque) as total
    FROM denatran_frota_municipio_tipo
    GROUP BY categoria, ano, mes

    UNION

    SELECT
        'Motocicletas' as categoria,
        ano,
        mes,
        SUM(motocicleta + motoneta) as total
    FROM denatran_frota_municipio_tipo
    GROUP BY categoria, ano, mes 

    UNION

    SELECT
        'Veículos Especiais' as categoria,
        ano,
        mes,
        SUM(quadriciclo + triciclo + sidecar) as total
    FROM denatran_frota_municipio_tipo
    GROUP BY categoria, ano, mes
) AS subquery
GROUP BY categoria

UNION ALL

SELECT
    'Total_Geral' as categoria,
    SUM(CASE WHEN ano = 2016 AND mes = 12 THEN total ELSE 0 END) as total_2016,
    SUM(CASE WHEN ano = 2017 AND mes = 12 THEN total ELSE 0 END) as total_2017,
    SUM(CASE WHEN ano = 2018 AND mes = 12 THEN total ELSE 0 END) as total_2018,
    SUM(CASE WHEN ano = 2019 AND mes = 12 THEN total ELSE 0 END) as total_2019,
    SUM(CASE WHEN ano = 2020 AND mes = 12 THEN total ELSE 0 END) as total_2020
FROM (
    SELECT
        'Veículos de Passeio' as categoria,
        ano,
        mes,
        SUM(automovel) as total
    FROM denatran_frota_municipio_tipo
    GROUP BY ano, mes

    UNION

    SELECT
        'Veículos de Carga' as categoria,
        ano,
        mes,
        SUM(caminhao + chassiplataforma + caminhaotrator + caminhonete + camioneta + utilitario + tratoresteira + tratorrodas + onibus + microonibus + reboque + semireboque) as total
    FROM denatran_frota_municipio_tipo
    GROUP BY ano, mes

    UNION

    SELECT
        'Motocicletas' as categoria,
        ano,
        mes,
        SUM(motocicleta + motoneta) as total
    FROM denatran_frota_municipio_tipo
    GROUP BY ano, mes 

    UNION

    SELECT
        'Veículos Especiais' as categoria,
        ano,
        mes,
        SUM(quadriciclo + triciclo + sidecar) as total
    FROM denatran_frota_municipio_tipo
    GROUP BY ano, mes
) AS subquery;



-- Criação de uma tabela permanente para os anos desejados (caso não exista)
CREATE TABLE IF NOT EXISTS AnosDesejados (ano INTEGER);
INSERT INTO AnosDesejados (ano) VALUES (2021), (2022), (2023);

--Uso da tabela permanente para calculo do crescimento dos veículos ao longo dos anos
--para a região norte (considerando de um ano para o outro o total dos veículos registrados em dezembro)

WITH DadosPorAno AS (
    SELECT
        ano,
        SUM(total) AS total_veiculos
    FROM denatran_frota_municipio_tipo dfmt
    WHERE sigla_uf IN ('AM', 'PA', 'RR', 'RO', 'AC', 'TO', 'AP') AND mes = 12
    GROUP BY ano
),
Crescimento AS (
    SELECT
        ano,
        total_veiculos,
        LAG(total_veiculos, 1) OVER (ORDER BY ano) AS total_anterior
    FROM DadosPorAno
)
SELECT
    c.ano,
    COALESCE(c.total_veiculos, 0) AS total_veiculos,
    COALESCE(
        ROUND(c.total_veiculos - c.total_anterior, 2),
        0
    ) AS crescimento
FROM Crescimento c
LEFT JOIN AnosDesejados a ON c.ano = a.ano;


--Separa por região, ao longo dos anos, por categoria de veículo e informa 
--a variação em cada categoria de um ano para outro.

WITH DadosPorAno AS (
    SELECT
        CASE
            WHEN sigla_uf IN ('AM', 'PA', 'RR', 'RO', 'AC', 'TO', 'AP') THEN 'Região Norte'
            WHEN sigla_uf IN ('MA', 'PI', 'PE', 'RN', 'SE', 'BA', 'PB', 'CE', 'AL') THEN 'Região Nordeste'
            WHEN sigla_uf IN ('MT', 'MS', 'GO', 'DF') THEN 'Região Centro-Oeste'
            WHEN sigla_uf IN ('MG', 'SP', 'RJ', 'ES') THEN 'Região Sudeste'
            WHEN sigla_uf IN ('PR', 'SC', 'RS') THEN 'Região Sul'
            ELSE 'Outro'
        END AS regiao,
        ano,
        SUM(automovel) AS Veiculos_de_Passeio,
        SUM(caminhao + chassiplataforma + caminhaotrator + caminhonete + camioneta + utilitario + tratoresteira + tratorrodas + onibus + microonibus + reboque + semireboque) AS Veiculos_de_Carga,
        SUM(motocicleta + motoneta) AS Motocicletas,
        SUM(quadriciclo + triciclo + sidecar) AS Veiculos_Especiais
    FROM denatran_frota_municipio_tipo
    WHERE ano BETWEEN 2003 AND 2021 AND mes = 12
    GROUP BY regiao, ano
)
SELECT
    regiao,
    ano,
    MAX(Veiculos_de_Passeio) AS Veiculos_de_Passeio,
    MAX(Veiculos_de_Carga) AS Veiculos_de_Carga,
    MAX(Motocicletas) AS Motocicletas,
    MAX(Veiculos_Especiais) AS Veiculos_Especiais,
    ROUND(100.0 * (MAX(Veiculos_de_Passeio) - LAG(MAX(Veiculos_de_Passeio)) OVER (PARTITION BY regiao ORDER BY ano)) / LAG(MAX(Veiculos_de_Passeio)) OVER (PARTITION BY regiao ORDER BY ano),2) AS Variacao_Passeio,
    ROUND(100.0 * (MAX(Veiculos_de_Carga) - LAG(MAX(Veiculos_de_Carga)) OVER (PARTITION BY regiao ORDER BY ano)) / LAG(MAX(Veiculos_de_Carga)) OVER (PARTITION BY regiao ORDER BY ano),2) AS Variacao_Carga,
    ROUND(100.0 * (MAX(Motocicletas) - LAG(MAX(Motocicletas)) OVER (PARTITION BY regiao ORDER BY ano)) / LAG(MAX(Motocicletas)) OVER (PARTITION BY regiao ORDER BY ano),2) AS Variacao_Motocicletas,
    ROUND(100.0 * (MAX(Veiculos_Especiais) - LAG(MAX(Veiculos_Especiais)) OVER (PARTITION BY regiao ORDER BY ano)) / LAG(MAX(Veiculos_Especiais)) OVER (PARTITION BY regiao ORDER BY ano),2) AS Variacao_Especiais
FROM DadosPorAno
GROUP BY regiao, ano
ORDER BY regiao, ano;






