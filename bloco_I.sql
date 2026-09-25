--1
--Mostra o ranking dos vendedores por faturamento dentro de cada estado.
WITH faturamento_vendedor AS (
	SELECT 
		vend.seller_id AS vendedor,
		vend.seller_state AS estado,
		SUM(item.price) AS faturamento
	FROM 
		olist_sellers_dataset AS vend
	INNER JOIN 
		olist_order_items_dataset AS item
		ON 
			vend.seller_id = item.seller_id
	GROUP BY 
		vend.seller_id,
		vend.seller_state
)
SELECT 
	vendedor AS "Código do vendedor",
	estado AS "Estado",
	ROUND(faturamento::NUMERIC, 2) AS "Faturamento",
	RANK() OVER (
		PARTITION BY estado
		ORDER BY faturamento DESC
	) AS "Posição no ranking"
FROM 
	faturamento_vendedor
ORDER BY 
	estado,
	"Posição no ranking";

--2
--Mostra o faturamento mensal de cada vendedor e o total acumulado ao longo dos meses.
WITH faturamento_mensal AS (
	SELECT 
		item.seller_id AS vendedor,
		DATE_TRUNC('month', ped.order_purchase_timestamp::timestamp) AS mes,
		SUM(item.price) AS faturamento
	FROM 
		olist_order_items_dataset AS item
	INNER JOIN 
		olist_orders_dataset AS ped
		ON 
			item.order_id = ped.order_id
	GROUP BY 
		item.seller_id,
		DATE_TRUNC('month', ped.order_purchase_timestamp::timestamp)
)
SELECT 
	vendedor AS "Código do vendedor",
	mes AS "Mês",
	ROUND(faturamento::NUMERIC, 2) AS "Faturamento mensal",
	ROUND(
		SUM(faturamento) OVER (
			PARTITION BY vendedor
			ORDER BY mes
		)::NUMERIC, 2
	) AS "Faturamento acumulado"
FROM 
	faturamento_mensal
ORDER BY 
	vendedor,
	mes;

--3
--Mostra quanto cada vendedor representa em porcentagem do faturamento total do seu estado.
WITH faturamento_vendedor AS (
	SELECT 
		vend.seller_id AS vendedor,
		vend.seller_state AS estado,
		SUM(item.price) AS faturamento
	FROM 
		olist_sellers_dataset AS vend
	INNER JOIN 
		olist_order_items_dataset AS item
		ON 
			vend.seller_id = item.seller_id
	GROUP BY 
		vend.seller_id,
		vend.seller_state
)
SELECT 
	vendedor AS "Código do vendedor",
	estado AS "Estado",
	ROUND(faturamento::NUMERIC, 2) AS "Faturamento",
	ROUND(
		(
			faturamento /
			NULLIF(
				SUM(faturamento) OVER (
					PARTITION BY estado
				), 0
			) * 100
		)::NUMERIC, 2
	) AS "Participação (%)"
FROM 
	faturamento_vendedor
ORDER BY 
	estado,
	"Participação (%)" DESC;

--4
--Mostra a diferença de faturamento de cada vendedor em relação ao mês anterior.
WITH faturamento_mensal AS (
	SELECT 
		item.seller_id AS vendedor,
		DATE_TRUNC('month', ped.order_purchase_timestamp::timestamp) AS mes,
		SUM(item.price) AS faturamento
	FROM 
		olist_order_items_dataset AS item
	INNER JOIN 
		olist_orders_dataset AS ped
		ON 
			item.order_id = ped.order_id
	GROUP BY 
		item.seller_id,
		DATE_TRUNC('month', ped.order_purchase_timestamp::timestamp)
),
comparacao AS (
	SELECT 
		vendedor,
		mes,
		faturamento,
		LAG(faturamento) OVER (
			PARTITION BY vendedor
			ORDER BY mes
		) AS faturamento_anterior
	FROM 
		faturamento_mensal
)
SELECT 
	vendedor AS "Código do vendedor",
	mes AS "Mês",
	ROUND(faturamento::NUMERIC, 2) AS "Faturamento atual",
	ROUND(faturamento_anterior::NUMERIC, 2) AS "Faturamento anterior",
	ROUND(
		(faturamento - faturamento_anterior)::NUMERIC, 2
	) AS "Variação do faturamento"
FROM 
	comparacao
ORDER BY 
	vendedor,
	mes;