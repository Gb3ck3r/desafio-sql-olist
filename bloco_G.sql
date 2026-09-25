--1
--Cria uma view juntando as principais informações dos pedidos, clientes, itens, pagamentos e vendedores.
CREATE OR REPLACE VIEW vw_pedidos_completos AS

SELECT 
	ped.order_id AS "Código do pedido",
	ped.order_status AS "Status do pedido",
	ped.order_purchase_timestamp AS "Data da compra",
	cli.customer_id AS "Código do cliente",
	cli.customer_city AS "Cidade do cliente",
	cli.customer_state AS "Estado do cliente",
	item.product_id AS "Código do produto",
	item.price AS "Valor do item",
	item.freight_value AS "Valor do frete",
	pag.payment_type AS "Forma de pagamento",
	pag.payment_installments AS "Número de parcelas",
	pag.payment_value AS "Valor do pagamento",
	vend.seller_id AS "Código do vendedor",
	vend.seller_city AS "Cidade do vendedor",
	vend.seller_state AS "Estado do vendedor"
FROM 
	olist_orders_dataset AS ped
INNER JOIN 
	olist_customers_dataset AS cli
	ON 
		ped.customer_id = cli.customer_id
INNER JOIN 
	olist_order_items_dataset AS item
	ON 
		ped.order_id = item.order_id
INNER JOIN 
	olist_order_payments_dataset AS pag
	ON 
		ped.order_id = pag.order_id
INNER JOIN 
	olist_sellers_dataset AS vend
	ON 
		item.seller_id = vend.seller_id;

--2
--Cria uma view mostrando a nota média e a quantidade de avaliações de cada categoria de produto.
CREATE OR REPLACE VIEW vw_avaliacoes_categoria AS

SELECT 
	trad.product_category_name_english AS "Categoria",
	ROUND(AVG(ava.review_score)::NUMERIC, 2) AS "Nota média",
	COUNT(ava.review_id) AS "Quantidade de avaliações"
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
	trad.product_category_name_english;