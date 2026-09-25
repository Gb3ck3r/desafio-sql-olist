/*
 Bloco B — JOINs
1. Relatório com categoria do produto (traduzida), valor do item, cidade do vendedor.
2. Identificar pedidos com atraso na entrega, comparando data estimada com data real
de entrega (join entre orders e customers).
3. Listar pedidos e suas formas de pagamento, incluindo pedidos pagos em mais de
uma parcela (join entre orders e order_payments).
4. Listar produtos junto com a categoria traduzida, incluindo produtos cuja categoria
não possui tradução cadastrada (LEFT JOIN com
product_category_name_translation).
5. Identificar pedidos em que o cliente e o vendedor são do mesmo estado (join entre
customers, orders, order_items e sellers).
*/

--1.
-- Mostra um relatorio do valot do produto e a cidade do vendedos
SELECT 
		trad.product_category_name_english AS "Categoria do produto",
       	item.price AS "Valor do item",
       	vend.seller_city AS "Cidade do vendedor"
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
		olist_sellers_dataset AS vend
    ON 
		item.seller_id = vend.seller_id;

--2.
-- compara as data previstas de entrega com a data da entrega
SELECT 
		ped.order_id AS "Código do pedido",
       cli.customer_city AS "Cidade do cliente",
       ped.order_estimated_delivery_date AS "Data prevista",
       ped.order_delivered_customer_date AS "Data da entrega"
FROM 
		olist_orders_dataset AS ped
INNER JOIN 
		olist_customers_dataset AS cli
    ON 
    	ped.customer_id = cli.customer_id
WHERE 
		ped.order_delivered_customer_date > ped.order_estimated_delivery_date;

--3.
-- Mostra forma de pagamento e pedidos e suas parcelas
SELECT 
		ped.order_id AS "Código do pedido",
       pag.payment_type AS "Forma de pagamento",
       pag.payment_installments AS "Número de parcelas",
       pag.payment_value AS "Valor do pagamento"
FROM 
		olist_orders_dataset AS ped
INNER JOIN 
		olist_order_payments_dataset AS pag
    ON 
		ped.order_id = pag.order_id;

--4
--mostra os produtos com a categoria de tradução incluindo os produtos sem tradução cadastrada
SELECT 
		prod.product_id AS "Código do produto",
       prod.product_category_name AS "Categoria original",
       trad.product_category_name_english AS "Categoria traduzida"
FROM 
		olist_products_dataset AS prod
LEFT JOIN 
		product_category_name_translation AS trad
    ON 
		prod.product_category_name = trad.product_category_name;

--5.
-- Mostra os pedidos que o vendedor e comprador estao no mesmo estado
SELECT 
		ped.order_id AS "Código do pedido",
       cli.customer_state AS "Estado do cliente",
       vend.seller_state AS "Estado do vendedor"
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
INNER JOIN 
		olist_sellers_dataset AS vend
    ON 
    	item.seller_id = vend.seller_id
WHERE 
		cli.customer_state = vend.seller_state;