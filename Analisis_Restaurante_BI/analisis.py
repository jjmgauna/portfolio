# ===============================================
# Proyecto: Análisis de Datos de un Restaurante
# Autor: Juan José Martín Gauna
# Fecha: 2 de Septiembre de 2025
# Descripción:
# Este script realiza un análisis de los datos de ventas de un restaurante
# para identificar productos clave, horas pico de actividad y generar insights
# de negocio accionables.
# ===============================================

# Importamos las bibliotecas de Python necesarias
import pandas as pd
import sqlite3
import matplotlib.pyplot as plt
import seaborn as sns

# Configuración para que los gráficos se vean profesionales
sns.set_style("whitegrid")

# ===============================================
# Parte 1: Conexión y Extracción de Datos con SQL
# ===============================================

print("1. Conectando a la base de datos y extrayendo datos con SQL...")
conn = sqlite3.connect('restaurante.db')

# Consulta SQL para obtener los ingresos totales por producto
# - 'SUM(cantidad * precio)' calcula el ingreso total por cada venta.
# - 'AS ingresos_totales' le da un alias claro a la nueva columna.
# - 'GROUP BY producto' agrupa todas las ventas por el nombre del producto.
# - 'ORDER BY' ordena los resultados de mayor a menor ingreso.
query_ingresos = """
SELECT
    producto,
    SUM(cantidad * precio) AS ingresos_totales
FROM
    ventas
GROUP BY
    producto
ORDER BY
    ingresos_totales DESC;
"""

# Consulta SQL para contar las transacciones por hora
# - 'strftime('%H', hora)' extrae solo la hora (en formato de 24h) del campo 'hora'.
# - 'COUNT(id_venta)' cuenta el número de transacciones en cada grupo.
# - 'GROUP BY soloHora' agrupa el conteo por la hora del día.
query_transacciones = """
SELECT
    strftime('%H', hora) AS soloHora,
    COUNT(id_venta) AS numero_de_transacciones
FROM
    ventas
GROUP BY
    soloHora
ORDER BY
    soloHora;
"""

# Leemos las consultas SQL y las convertimos en DataFrames de Pandas
df_ingresos = pd.read_sql_query(query_ingresos, conn)
df_transacciones = pd.read_sql_query(query_transacciones, conn)

# Cerramos la conexión a la base de datos
conn.close()
print("   -> Datos extraídos correctamente.")

# ===============================================
# Parte 2: Análisis y Visualización de Datos (Ambos gráficos en una sola figura)
# ===============================================

print("\n2. Generando visualizaciones y análisis de datos...")

# Creamos una figura con dos subplots (1 fila, 2 columnas)
plt.figure(figsize=(16, 6)) # Aumentamos el tamaño para que ambos gráficos tengan espacio

# Subplot 1: Gráfico de barras para Ingresos Totales por Producto
plt.subplot(1, 2, 1) # Primera posición en la cuadrícula de 1 fila, 2 columnas
sns.barplot(x='producto', y='ingresos_totales', data=df_ingresos, palette='magma')
plt.title('Ingresos Totales por Producto')
plt.xlabel('Producto')
plt.ylabel('Ingresos Totales ($)')
plt.xticks(rotation=45, ha='right')
print("   -> Gráfico de ingresos por producto generado.")

# Subplot 2: Gráfico de líneas para Número de Transacciones por Hora
plt.subplot(1, 2, 2) # Segunda posición en la cuadrícula de 1 fila, 2 columnas
sns.lineplot(x='soloHora', y='numero_de_transacciones', data=df_transacciones, marker='o', color='purple')
plt.title('Número de Transacciones por Hora')
plt.xlabel('Hora del Día')
plt.ylabel('Número de Transacciones')
plt.xticks(rotation=45, ha='right')
plt.grid(True)
print("   -> Gráfico de transacciones por hora generado.")

plt.tight_layout() # Ajusta automáticamente los elementos para evitar superposiciones
plt.show() # Muestra la figura con ambos gráficos

# ===============================================
# Parte 3: Conclusiones y Recomendaciones de Negocio
# ===============================================

print("\n3. Conclusiones clave y recomendaciones:")
print("- El producto con mayores ingresos es la 'pizza_pepperoni', lo que sugiere un alto margen de beneficio. Sin embargo, la 'pizza_margarita' es la más vendida en términos de cantidad (revisar datos iniciales), lo que indica su popularidad.")
print("- Las horas pico de transacciones son entre las 12h y 13h, y 19h y 20h. Esto indica el horario de almuerzo y cena.")
print("\nRecomendaciones:")
print(" - Estrategia de Marketing: Crear 'packs' o combos promocionales (ej. 'pizza_pepperoni + gaseosa') para aumentar el valor promedio del ticket.")
print(" - Optimización de Operaciones: Considerar asignar más personal durante las horas pico para asegurar un servicio rápido y eficiente.")

print("\nAnálisis del restaurante completado. Este script puede ser subido a GitHub como parte del portafolio.")