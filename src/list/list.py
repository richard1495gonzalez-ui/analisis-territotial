class ListView:
    @staticmethod
    def display_duplicates(duplicates):
        print("\n=== MUNICIPIOS DUPLICADOS (CON MAS DE UN DEPARTAMENTO) ===")
        print(f"{'Municipio':<30} ^| {'Departamentos':<70} ^| {'Cantidad':<10}")
        print("-" * 118)
        for row in duplicates:
            print(f"{row['municipio']:<30} ^| {row['departamentos']:<70} ^| {row['cantidad']:<10}")
        print(f"\nTotal de municipios repetidos encontrados: {len(duplicates)}\n")
