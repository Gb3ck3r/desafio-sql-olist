--1
--Mostra os clientes que gastaram mais do que a média geral de gasto dos clientes.
SELECT 
	cli.customer_id AS "Código do cliente",
	SUM(pag.payment_value) AS "Gasto total"
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
	cli.customer_id
HAVING 
	SUM(pag.payment_value) > (
		SELECT 
			AVG(gasto_cliente)
		FROM (
			SELECT 
				SUM(pag2.payment_value) AS gasto_cliente
			FROM 
				olist_orders_dataset AS ped2
			INNER JOIN 
				olist_order_payments_dataset AS pag2
				ON 
					ped2.order_id = pag2.order_id
			GROUP BY 
				ped2.customer_id
		) AS gastos
	)
ORDER BY 
	"Gasto total" DESC;

--2
--Mostra os produtos que não possuem nenhuma avaliação registrada.
SELECT 
	prod.product_id AS "Código do produto",
	prod.product_category_name AS "Categoria"
FROM 
	olist_products_dataset AS prod
WHERE NOT EXISTS (
	SELECT 
		1
	FROM 
		olist_order_items_dataset AS item
	INNER JOIN 
		olist_order_reviews_dataset AS ava
		ON 
			item.order_id = ava.order_id
	WHERE 
		item.product_id = prod.product_id
);

--3
--Mostra os vendedores que venderam produtos de mais de 5 categorias diferentes.
SELECT 
	vend.seller_id AS "Código do vendedor",
	vend.seller_city AS "Cidade do vendedor",
	vend.seller_state AS "Estado do vendedor"
FROM 
	olist_sellers_dataset AS vend
WHERE 
	vend.seller_id IN (
		SELECT 
			item2.seller_id
		FROM 
			olist_order_items_dataset AS item2
		INNER JOIN 
			olist_products_dataset AS prod2
			ON 
				item2.product_id = prod2.product_id
		GROUP BY 
			item2.seller_id
		HAVING 
			COUNT(DISTINCT prod2.product_category_name) > 5
	);

--4
--Mostra os pedidos onde o valor total do frete é maior que o valor total dos itens.
SELECT 
	ped.order_id AS "Código do pedido"
FROM 
	olist_orders_dataset AS ped
WHERE (
	SELECT 
		SUM(item2.freight_value)
	FROM 
		olist_order_items_dataset AS item2
	WHERE 
		item2.order_id = ped.order_id
) > (
	SELECT 
		SUM(item3.price)
	FROM 
		olist_order_items_dataset AS item3
	WHERE 
		item3.order_id = ped.order_id
);