from src.model.model import Model
from src.list.list import ListView

class Controller:
    def __init__(self):
        self.model = Model()
        self.view = ListView()

    def run(self):
        try:
            results = self.model.get_duplicate_municipalities()
            self.view.display_duplicates(results)
        except Exception as e:
            print(f"Error al ejecutar el controlador: {e}")
