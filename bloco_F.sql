--1
--Mostra o faturamento mensal de cada estado e a variação em relação ao mês anterior.
WITH faturamento_mensal AS (
	SELECT 
		cli.customer_state AS estado,
		DATE_TRUNC('month', ped.order_purchase_timestamp::timestamp) AS mes,
		SUM(pag.payment_value) AS faturamento
	FROM 
		olist_customers_dataset AS cli
	INNER JOIN 
		olist_orders_dataset AS ped
		ON 
			cli.customer_id = ped.customer_id
	INNER JOIN 
		olist_order_payments_dataset AS pag
		ON 
			ped.order_id = pag.order_id
	GROUP BY 
		cli.customer_state,
		DATE_TRUNC('month', ped.order_purchase_timestamp::timestamp)
),
comparacao AS (
	SELECT 
		estado,
		mes,
		faturamento,
		LAG(faturamento) OVER (
			PARTITION BY estado
			ORDER BY mes
		) AS faturamento_anterior
	FROM 
		faturamento_mensal
)
SELECT 
	estado AS "Estado",
	mes AS "Mês",
	faturamento AS "Faturamento",
	faturamento_anterior AS "Faturamento mês anterior",
	ROUND(
		(
			((faturamento - faturamento_anterior) /
			NULLIF(faturamento_anterior, 0)) * 100
		)::NUMERIC, 2
	) AS "Variação (%)"
FROM 
	comparacao
ORDER BY 
	estado,
	mes;

--2
--Mostra a quantidade de avaliações e a nota média de cada categoria, ajudando a encontrar categorias com avaliações piores.
WITH avaliacoes_categoria AS (
	SELECT 
		trad.product_category_name_english AS categoria,
		COUNT(ava.review_id) AS quantidade_avaliacoes,
		AVG(ava.review_score) AS nota_media
	FROM 
		olist_products_dataset AS prod
	INNER JOIN 
		product_category_name_translation AS trad
		ON 
			prod.product_category_name = trad.product_category_name
	INNER JOIN 
		olist_order_items_dataset AS item
		ON 
			prod.product_id = item.product_id
	INNER JOIN 
		olist_order_reviews_dataset AS ava
		ON 
			item.order_id = ava.order_id
	GROUP BY 
		trad.product_category_name_english
)
SELECT 
	categoria AS "Categoria",
	quantidade_avaliacoes AS "Quantidade de avaliações",
	ROUND(nota_media, 2) AS "Nota média"
FROM 
	avaliacoes_categoria
WHERE 
	quantidade_avaliacoes >= 10
ORDER BY 
	"Nota média",
	"Quantidade de avaliações" DESC;

--3
--Mostra o frete médio de cada estado e compara com a média geral de frete da base.
WITH frete_estado AS (
	SELECT 
		cli.customer_state AS estado,
		AVG(item.freight_value) AS frete_medio
	FROM 
		olist_customers_dataset AS cli
	INNER JOIN 
		olist_orders_dataset AS ped
		ON 
			cli.customer_id = ped.customer_id
	INNER JOIN 
		olist_order_items_dataset AS item
		ON 
			ped.order_id = item.order_id
	GROUP BY 
		cli.customer_state
),
media_geral AS (
	SELECT 
		AVG(freight_value) AS frete_medio_geral
	FROM 
		olist_order_items_dataset
)
SELECT 
	fre.estado AS "Estado",
	ROUND(fre.frete_medio::NUMERIC, 2) AS "Frete médio",
	ROUND(med.frete_medio_geral::NUMERIC, 2) AS "Média geral",
	ROUND(
		(fre.frete_medio - med.frete_medio_geral)::NUMERIC, 2
	) AS "Diferença da média"
FROM 
	frete_estado AS fre
CROSS JOIN 
	media_geral AS med
ORDER BY 
	"Frete médio" DESC;