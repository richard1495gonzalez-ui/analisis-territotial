class ListView:
    @staticmethod
    def display_summary_counts(counts):
        print("\n=== VERIFICACIÓN EN CONSOLA (MÉTRICAS DE BASE DE DATOS) ===")
        print(f"Total Regiones cargadas:      {counts['regiones']}")
        print(f"Total Departamentos cargados: {counts['departamentos']}")
        print(f"Total Municipios cargados:    {counts['municipios']}")
        print("==========================================================")

    @staticmethod
    def display_duplicates(duplicates):
        print("\n=== MUNICIPIOS DUPLICADOS (CON MÁS DE UN DEPARTAMENTO) ===")
        print(f"{'Municipio':<30} | {'Departamentos':<70} | {'Cantidad':<10}")
        print("-" * 118)
        for row in duplicates:
            print(f"{row['municipio']:<30} | {row['departamentos']:<70} | {row['cantidad']:<10}")
        print(f"\nTotal de municipios repetidos encontrados: {len(duplicates)}\n")
