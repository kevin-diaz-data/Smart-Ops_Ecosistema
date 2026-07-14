/*******************************************************************************
   PROYECTO: SMART-OPS ECOSISTEMA ANALÍTICO
   FASE 1: AUDITORÍA DE CALIDAD DE DATOS (DATA QUALITY & QA)
   OBJETIVO: Validar la integridad del modelo estrella antes de la fase DAX.
*******************************************************************************/

-- =============================================================================
-- 1. CONTROL DE INTEGRIDAD REFERENCIAL (Claves Huérfanas)
-- =============================================================================
-- Objetivo: Asegurar que no existan registros en Fact_Ventas con IDs de 
-- productos o vendedores que no estén dados de alta en nuestras dimensiones.

-- 1.1. Verificación de Vendedores Huérfanos
SELECT COUNT(*) AS total_ventas_sin_vendedor
FROM Fact_Ventas f
LEFT JOIN Dim_Sellers s ON f.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

-- 1.2. Verificación de Productos Huérfanos
SELECT COUNT(*) AS total_ventas_sin_producto
FROM Fact_Ventas f
LEFT JOIN Dim_Productos p ON f.product_id = p.product_id
WHERE p.product_id IS NULL;


-- =============================================================================
-- 2. PERFILADO DE VALORES NULOS O INCOMPLETOS
-- =============================================================================
-- Objetivo: Identificar qué porcentaje de datos analíticos clave viene vacío
-- de origen para prever transformaciones o imputaciones en Power Query.

SELECT 
    COUNT(*) AS total_registros,
    SUM(CASE WHEN product_category_name IS NULL OR product_category_name = '' THEN 1 ELSE 0 END) AS productos_sin_categoria,
    ROUND(
        (SUM(CASE WHEN product_category_name IS NULL OR product_category_name = '' THEN 1 ELSE 0 END)::NUMERIC / COUNT(*)) * 100, 
        2
    ) AS porcentaje_nulos_categoria
FROM Dim_Productos;


-- =============================================================================
-- 3. VALIDACIÓN DE LÍMITES Y NEGOCIO (KPIs de Control Rápido)
-- =============================================================================
-- Objetivo: Obtener cifras de control en base de datos para contrastar 
-- y conciliar con los resultados que calculemos posteriormente en Power BI.

-- 3.1. Totales de Control (Cifras Macro)
SELECT 
    COUNT(DISTINCT order_id) AS total_pedidos_unicos,
    COUNT(*) AS total_lineas_transaccionales,
    SUM(price) AS facturacion_total_price,
    SUM(freight_value) AS flete_total_shipping
FROM Fact_Ventas;

-- 3.2. Top 5 Estados con Vendedores más Activos (Volumen de Negocio)
SELECT 
    s.seller_state,
    COUNT(DISTINCT s.seller_id) AS total_vendedores,
    ROUND(SUM(f.price), 2) AS total_ingresos_ventas
FROM Fact_Ventas f
JOIN Dim_Sellers s ON f.seller_id = s.seller_id
GROUP BY s.seller_state
ORDER BY total_ingresos_ventas DESC
LIMIT 5;
