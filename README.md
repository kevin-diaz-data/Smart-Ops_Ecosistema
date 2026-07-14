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

## 🛠️ 3. Estado del Proyecto e Hitos en Desarrollo
Actualmente el proyecto se encuentra en la Fase de Modelado e Inteligencia de Negocio:

Fase 1 (SQL y QA): Completada con éxito. Base de datos local activa e integridad referencial auditada.

Fase 2 (ETL en Power Query): Parametrización del servidor mediante DB_Server y DB_Name, traducción automática de las categorías de portugués a inglés mediante combinación de datos (Merge), verticalización de objetivos de venta (Unpivot) y creación de la dimensión de tiempo dinámica Dim_Fecha en DAX.

Fase 3 (DAX y Métricas de Negocio): Implementación de más de 20 medidas de negocio organizadas en carpetas operativas (Ventas y Rentabilidad, Volumen de Operaciones, Inteligencia de Tiempo y Análisis Avanzado de Pareto).
