/*
 Bloco A — SELECT básico
1. Listar os 20 pedidos com status delivered mais recentes, ordenados pela data de entrega.
2. Listar todos os produtos de uma categoria específica (usando a tabela de tradução para filtrar pelo nome em português).
3. Listar os métodos de pagamento distintos utilizados na base (SELECT DISTINCT payment_type).
4. Listar os produtos com peso (product_weight_g) acima de 10kg, ordenados do mais pesado para o mais leve.
 */

-- 1.
-- Mostra as ultimas entregas
SELECT *
	FROM 
		olist_orders_dataset
	WHERE 
		order_status = 'delivered'
	ORDER BY 
		order_delivered_customer_date DESC
LIMIT 20;

select * from

--2.
-- Utiliza a tabela de tradução para o filtro
SELECT *FROM product_category_name_translation

SELECT prod.*
	FROM 
		olist_products_dataset as prod
	JOIN 
		product_category_name_translation as trad
    ON 
    	prod.product_category_name = trad.product_category_name
	WHERE 
		trad.product_category_name = 'beleza_saude';

--3.
-- Mostra formas de pagamento sem repetir nenhum deles que foram usadas mais de uma vez
SELECT DISTINCT payment_type
FROM olist_order_payments_dataset;

--4.
-- Ordena os produtos por peso do mais pesado ao mais leve
SELECT * 
	FROM 
		olist_products_dataset
	WHERE 
		product_weight_g > 10000
	ORDER BY 
		product_weight_g DESC;
