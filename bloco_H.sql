--1
--Cria um relatório mostrando o faturamento, ticket médio e nota média de um vendedor dentro do período informado.

CREATE OR REPLACE FUNCTION sp_relatorio_vendedor(
	id_vendedor TEXT,
	data_inicio DATE,
	data_fim DATE
)
RETURNS TABLE (
	"Faturamento" NUMERIC,
	"Ticket médio" NUMERIC,
	"Nota média" NUMERIC
)
AS $$
BEGIN

	RETURN QUERY

	SELECT 
		ROUND(SUM(item.price)::NUMERIC, 2) AS "Faturamento",
		ROUND(AVG(item.price)::NUMERIC, 2) AS "Ticket médio",
		ROUND(AVG(ava.review_score)::NUMERIC, 2) AS "Nota média"
	FROM 
		olist_order_items_dataset AS item
	INNER JOIN 
		olist_orders_dataset AS ped
		ON 
			item.order_id = ped.order_id
	LEFT JOIN 
		olist_order_reviews_dataset AS ava
		ON 
			ped.order_id = ava.order_id
	WHERE 
		item.seller_id = id_vendedor
		AND ped.order_purchase_timestamp::timestamp::date 
			BETWEEN data_inicio AND data_fim;

END;
$$ LANGUAGE plpgsql;

--2
--Cria um relatório mostrando o faturamento total e o ticket médio de uma categoria dentro do período informado.

CREATE OR REPLACE FUNCTION sp_relatorio_categoria(
	categoria TEXT,
	data_inicio DATE,
	data_fim DATE
)
RETURNS TABLE (
	"Faturamento total" NUMERIC,
	"Ticket médio" NUMERIC
)
AS $$
BEGIN

	RETURN QUERY

	SELECT 
		ROUND(SUM(item.price)::NUMERIC, 2) AS "Faturamento total",
		ROUND(AVG(item.price)::NUMERIC, 2) AS "Ticket médio"
	FROM 
		olist_order_items_dataset AS item
	INNER JOIN 
		olist_products_dataset AS prod
		ON 
			item.product_id = prod.product_id
	INNER JOIN 
		product_category_name_translation AS trad
		ON 
			prod.product_category_name = trad.product_category_name
	INNER JOIN 
		olist_orders_dataset AS ped
		ON 
			item.order_id = ped.order_id
	WHERE 
		trad.product_category_name_english = categoria
		AND ped.order_purchase_timestamp::timestamp::date 
			BETWEEN data_inicio AND data_fim;

END;
$$ LANGUAGE plpgsql;