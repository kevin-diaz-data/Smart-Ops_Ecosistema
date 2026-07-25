Markdown
# 🛒 Smart-Ops Ecosistema Analítico: Optimización de Operaciones en Olist

Este repositorio contiene un ecosistema analítico de Business Intelligence (BI) de extremo a extremo, diseñado para evaluar el rendimiento comercial de los vendedores, auditar la estructura de costos logísticos y optimizar el catálogo de productos de la plataforma de e-commerce **Olist**.

El proyecto se ha desarrollado bajo una arquitectura robusta, utilizando un motor de base de datos **PostgreSQL** local para la ingesta y calidad de datos, y **Power BI** como plataforma de modelado, analítica avanzada (DAX) y visualización interactiva.

---

## 🏗️ 1. Arquitectura de Datos y Modelo Estrella
Para garantizar un almacenamiento eficiente, se migró la estructura plana original hacia un **Modelo Estrella (Star Schema)** relacional e indexado directamente en PostgreSQL utilizando **pgAdmin**.

La arquitectura consta de las siguientes tablas:
* **`Fact_Ventas` (Tabla de Hechos):** Almacena las transacciones físicas de los pedidos a nivel de ítem (`order_item_id`).
* **`Dim_Sellers` (Dimensión):** Controla los datos geográficos de los vendedores (Estado, Ciudad y Código Postal).
* **`Dim_Productos` (Dimensión):** Almacena las especificaciones físicas, categorías y traducciones del catálogo de productos.

> 📂 **Acceso al código de base de datos:** > Puedes consultar el script de creación y definición de tablas (DDL) en:  
> [Ver `estructura_y_auditoria.sql`](./01_Base_de_Datos/estructura_y_auditoria.sql)

---

## 🔍 2. Auditoría de Calidad y Perfilado de Datos (Data QA)
Antes de conectar los datos a la capa de inteligencia de negocio, se ejecutó una auditoría formal en PostgreSQL para asegurar la consistencia de las métricas. Los hallazgos y consultas de control clave incluyen:

### A. Integridad Referencial (Cero Claves Huérfanas)

Se validó que el 100% de las filas de la tabla de hechos apunten a dimensiones existentes, evitando pérdida de información en las uniones de Power BI:

SELECT COUNT(*) AS total_ventas_sin_vendedor
FROM Fact_Ventas f
LEFT JOIN Dim_Sellers s ON f.seller_id = s.seller_id
WHERE s.seller_id IS NULL; -- Resultado: 0 registros huérfanos.


### B. Perfilado de Datos Nulos en Dimensiones

Se detectaron productos sin categoría registrada para automatizar su tratamiento en la fase de Power Query, reemplazando los nulos por la etiqueta "Sin Categoría":

SELECT 
    COUNT(*) AS total_productos,
    SUM(CASE WHEN product_category_name IS NULL OR product_category_name = '' THEN 1 ELSE 0 END) AS productos_sin_categoria
FROM Dim_Productos;


### C. Cifras de Control de Conciliación (Auditoría Macro)

Las siguientes métricas actúan como un marco de reconciliación estricto para asegurar que la capa analítica de Power BI coincida al 100% con los datos de origen:

Pedidos Únicos Auditados: 98,666

Líneas Transaccionales: 112,650

Facturación de Productos (Price): $13,591,643.70

Flete Total Recaudado (Freight): $2,251,909.54

---

## 📐 3. Capa de Modelado y Cálculo DAX
El modelo cuenta con una arquitectura de calculo centralizada en la tabla _Medidas, estructurada jerárquicamente en cuatro carpetas funcionales para garantizar escalabilidad, legibilidad y un estándar corporativo de mantenimiento:

Carpetas de Medidas DAX (_Medidas):
### 📂 Carpeta 1: Ventas y Rentabilidad (Sales & Profitability)
Métricas financieras fundamentales que evalúan la facturación, estructura de costes e indicadores de rentabilidad del negocio:

**Total Sales (GMV):** Ingresos totales generados por la venta de productos en la plataforma (SUM(Fact_Ventas[price])).

**Total Shipping:** Suma de costes directos y operativos asociados a las transacciones.

**Direct Profit:** Beneficio bruto calculado mediante la diferencia entre ingresos y costes ([Total Sales] - [Total Shipping]).

**Margin %:** Ratio porcentual de rentabilidad sobre las ventas (DIVIDE([Direct Profit], [Total Sales], 0)).

### 📂 Carpeta 2: Volume and Operations
Indicadores de volumen y rendimiento operativo para auditar transacciones, profundidad de cesta y economía unitaria:

**Units Sold:** Conteo total de ítems transaccionados a nivel de línea.

**Total Orders:** Recuento de órdenes únicas procesadas (DISTINCTCOUNT(Fact_Ventas[order_id])).

**Products per Order ratio:** Ticket medio generado por cada orden de compra (DIVIDE([Total Sales], [Total Orders], 0)).

**Average Sales per Seller:** Promedio de ingresos generados por vendedor (DIVIDE([Total Sales], [Active Sellers], 0)).

### 📂 Carpeta 3: Time Intelligence
Cálculos de análisis temporal para evaluar la evolución del negocio, comportamientos acumulados y variaciones interanuales:

**Sales YTD:** Crecimiento acumulado de ventas en el año en curso (Year-to-Date).

**Sales LY:** Ventas totales registradas en el mismo periodo del año anterior (Last Year) para servir como base comparativa.

**YoY Variance value:** Variación absoluta del volumen de negocio año contra año ([Total Sales] - [Sales LY]).

**YoY Growth %:** Crecimiento porcentual relativo frente al año anterior (DIVIDE([YoY variance value], [Sales LY], 0)).

### 📂 Carpeta 4: Advanced Analysis and Ranking
Lógica analítica avanzada para segmentación dinámica de entidades, evaluaciones de impacto acumulado y clasificación de rendimiento:

**Sellers Rank:** Ranking dinámico que posiciona ordenadamente a vendedores según su nivel de facturación.

**Top N Sales:** Cálculo dinámico que aísla e identifica las ventas exclusivamente atribuibles a los principales actores seleccionados.

**Pareto Cumulative State Sales:** Porcentaje acumulado de facturación que soporta la regla del 80/20 para identificar al núcleo estratégico de vendedores o categorías.

---

## 🎨 4. Estructura e Interacción del Dashboard (Power BI)
El cuadro de mando fue diseñado bajo un enfoque de User Experience (UX/UI) ejecutivo, con paletas de colores neutras y contrastes de acento para la toma de decisiones:

### 📄 Página 1: Visión General de Operaciones y Ventas (Executive Overview)

**Header / Banner:** KPIs clave (Total Sales, Direct Profit y Margin %).

**Visual Top 1:** Evolución temporal de facturación por mes/año (Línea de tendencia).

**Visual Top 2:** Distribución geográfica de ventas por Estado (Mapa).

**Visual Top 3:** Top 10 Categorías de productos más vendidas.

### 📄 Página 2: Análisis de Eficiencia de Vendedores y Logística (Sellers & Performance Analytics)

**KPIs Específicos:** Active Sellers y Average Sales per Seller.

**Segmentación de datos por año.**

**Gráfico de Pareto:** Análisis 80/20 combinado (Barras de facturación por ciudad con línea de % acumulado).

**Tabla de ciudades:** Matriz detallada con formato condicional para identificar las ciudades con mayor impacto en ventas y vendedores activos.

**Gráfico de áreas:** Indica por año/mes la cantidad de vendedores activos.

**Página de Tooltip Personalizado:** Al pasar el cursor sobre cualquier vendedor del gráfico de Pareto o el gráfico de áreas, se despliega una tarjeta dinámica flotante con el detalle de rendimiento, estado de origen y mix de categorías principales.

### 📄 Página 3: Portfolio de Productos y Eficiencia Logística (Product Portfolio)

**Análisis de Dispersión (Logistics Cost vs. Sales Performance):** Gráfico cuadrante de burbujas que evalúa la relación entre los costes de transporte (Shipping Cost) e ingresos totales (Total Sales) con líneas de referencia promedio para detectar discrepancias logísticas por categoría.

**Matriz de Detalle Comercial (Commercial Performance Details):** Tabla interactiva por categoría de producto que audita métricas clave como Total Sales, Units Sold, Margin Percentage y Average Order Value.

**Mapa de Árbol / Treemap (Share and Margin by Category):** Representación visual de peso relativo de catálogo por volumen e intensidad de margen, destacando categorías clave como Health Beauty, Watches Gifts, Bed Bath Table y Computers Accessories.

---

## 🚀 5. Estado Actual y Próximos Pasos
**[x] Fase 1:** Configuración de PostgreSQL, creación de DDL y auditoría de datos (SQL QA).

**[x] Fase 2:** Transformación y carga parametrizada en Power Query.

**[x] Fase 3:** Modelado dimensional, desarrollo DAX y análisis 80/20 (Pareto).

**[x] Fase 4:** Diseño completo e interactivo del Dashboard en Power BI Desktop (UX/UI y Tooltips).

**[ ] Fase 5 (Próximo Hito):** Migración a Tableau Desktop / Public.

Réplica del modelo relacional en Tableau Data Source.

Recreación de cálculos LOD (Level of Detail) equivalentes a las medidas DAX.

Diseño de dashboards equivalentes optimizados para la plataforma de Tableau.
