from src.model.model import Model
from src.list.list import ListView

class Controller:
    def __init__(self):
        self.model = Model()
        self.view = ListView()

    def run(self):
        try:
            # 1. Obtener y mostrar estadísticas globales de base de datos
            counts = self.model.get_overall_counts()
            self.view.display_summary_counts(counts)
            
            # 2. Obtener y mostrar listado de duplicados
            results = self.model.get_duplicate_municipalities()
            self.view.display_duplicates(results)
        except Exception as e:
            print(f"Error al ejecutar el controlador: {e}")
