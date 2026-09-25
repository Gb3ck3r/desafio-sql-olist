/*
Bloco C — Funções agregadas + GROUP BY + HAVING
1. Faturamento total por estado do cliente.
2. Top 10 vendedores por faturamento.
3. Ticket médio por categoria de produto.
4. Vendedores com nota média de avaliação abaixo de 3 (HAVING AVG(...) < 3).
5. Quantidade de pedidos por forma de pagamento (GROUP BY payment_type).
6. Peso médio dos produtos por categoria.
7. Número médio de parcelas (AVG(payment_installments)) por categoria de produto.
 */

--1
--Faturamento total por estado
SELECT 	
		cli.customer_state AS "Estado",
       SUM
       	(pag.payment_value) AS "Faturamento total"
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
		cli.customer_state
ORDER BY 
		"Faturamento total" 
DESC;

--2
-- melhores 10 vendedores por faturamento
SELECT 
		vend.seller_id AS "Código do vendedor",
       SUM
       (item.price) AS "Faturamento total"
FROM 
		olist_sellers_dataset AS vend
INNER JOIN 
		olist_order_items_dataset AS item
    ON 
    	vend.seller_id = item.seller_id
GROUP BY 
		vend.seller_id
ORDER BY 
		"Faturamento total" 
DESC
LIMIT 10;

-- 3
--Mostra o valor médio dos produtos vendidos em cada categoria.
SELECT 
		trad.product_category_name_english AS "Categoria",
       AVG
       	(item.price) AS "Ticket médio"
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
GROUP BY 
		trad.product_category_name_english
ORDER BY 	
		"Ticket médio" DESC;

-- 4 
-- Mostra os vendedores que possuem uma nota média de avaliação abaixo de 3.

SELECT 
		vend.seller_id AS "Código do vendedor",
       AVG
       	(ava.review_score) AS "Nota média"
FROM 
		olist_sellers_dataset AS vend
INNER JOIN 
		olist_order_items_dataset AS item
    ON 
    	vend.seller_id = item.seller_id
INNER JOIN 
		olist_order_reviews_dataset AS ava
    ON 
    	item.order_id = ava.order_id
GROUP BY 
		vend.seller_id
HAVING 
	AVG
		(ava.review_score) < 3
ORDER BY 
		"Nota média";

--5
--Mostra quantos pedidos foram feitos com cada forma de pagamento.

SELECT 
		pag.payment_type AS "Forma de pagamento",
    COUNT
       	(DISTINCT pag.order_id) AS "Quantidade de pedidos"
FROM 
		olist_order_payments_dataset AS pag
GROUP BY 
		pag.payment_type
ORDER BY 
		"Quantidade de pedidos" DESC;

--6
--Mostra o peso médio dos produtos de cada categoria.

SELECT 
		trad.product_category_name_english AS "Categoria",
    AVG
       	(prod.product_weight_g) AS "Peso médio (g)"
FROM 
		olist_products_dataset AS prod
INNER JOIN 
		product_category_name_translation AS trad
    ON 
    	prod.product_category_name = trad.product_category_name
GROUP BY 
		trad.product_category_name_english
ORDER BY 
		"Peso médio (g)" DESC;

--7
--Mostra a média de parcelas utilizadas nas compras de cada categoria de produto.

SELECT 
		trad.product_category_name_english AS "Categoria",
    AVG
       	(pag.payment_installments) AS "Média de parcelas"
FROM 
		olist_order_payments_dataset AS pag
INNER JOIN 
		olist_order_items_dataset AS item
    ON 
    	pag.order_id = item.order_id
INNER JOIN 
		olist_products_dataset AS prod
    ON 
    	item.product_id = prod.product_id
INNER JOIN 
		product_category_name_translation AS trad
    ON 
    	prod.product_category_name = trad.product_category_name
GROUP BY 
		trad.product_category_name_english
ORDER BY 
		"Média de parcelas" DESC;