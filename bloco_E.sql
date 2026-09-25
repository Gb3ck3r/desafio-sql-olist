--1
--Mostra se cada pedido foi entregue adiantado, no prazo ou atrasado.
SELECT 
	ped.order_id AS "Código do pedido",
	ped.order_delivered_customer_date AS "Data da entrega",
	ped.order_estimated_delivery_date AS "Data estimada",
	CASE
		WHEN ped.order_delivered_customer_date < ped.order_estimated_delivery_date
			THEN 'adiantado'
		WHEN ped.order_delivered_customer_date = ped.order_estimated_delivery_date
			THEN 'no prazo'
		WHEN ped.order_delivered_customer_date > ped.order_estimated_delivery_date
			THEN 'atrasado'
	END AS "Prazo da entrega"
FROM 
	olist_orders_dataset AS ped
WHERE 
	ped.order_delivered_customer_date IS NOT NULL;

--2
--Classifica os clientes como bronze, prata ou ouro de acordo com o valor total gasto.
SELECT 
	cli.customer_id AS "Código do cliente",
	SUM(pag.payment_value) AS "Gasto total",
	CASE
		WHEN SUM(pag.payment_value) <= 500
			THEN 'bronze'
		WHEN SUM(pag.payment_value) <= 1000
			THEN 'prata'
		ELSE 'ouro'
	END AS "Classificação"
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
ORDER BY 
	"Gasto total" DESC;
--3
--Classifica os produtos como leve, médio ou pesado de acordo com o peso.
SELECT 
	prod.product_id AS "Código do produto",
	prod.product_weight_g AS "Peso (g)",
	CASE
		WHEN prod.product_weight_g <= 1000
			THEN 'leve'
		WHEN prod.product_weight_g <= 5000
			THEN 'médio'
		ELSE 'pesado'
	END AS "Classificação do peso"
FROM 
	olist_products_dataset AS prod
WHERE 
	prod.product_weight_g IS NOT NULL
ORDER BY 
	prod.product_weight_g DESC;

--4
--Mostra se o pagamento foi à vista, parcelado ou um parcelamento longo.
SELECT 
	pag.order_id AS "Código do pedido",
	pag.payment_type AS "Forma de pagamento",
	pag.payment_installments AS "Número de parcelas",
	CASE
		WHEN pag.payment_installments <= 1
			THEN 'à vista'
		WHEN pag.payment_installments > 6
			THEN 'parcelado longo'
		ELSE 'parcelado'
	END AS "Tipo de pagamento"
FROM 
	olist_order_payments_dataset AS pag
ORDER BY 
	pag.payment_installments DESC;