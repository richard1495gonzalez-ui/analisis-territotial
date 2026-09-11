import mysql.connector

class Model:
    def __init__(self, host="127.0.0.1", user="root", password="", database="analisis_territorial"):
        self.host = host
        self.user = user
        self.password = password
        self.database = database

    def get_duplicate_municipalities(self):
        connection = mysql.connector.connect(
            host=self.host,
            user=self.user,
            password=self.password,
            database=self.database
        )
        cursor = connection.cursor(dictionary=True)
        query = """
        SELECT
            m.Nombre AS municipio,
            GROUP_CONCAT(
                DISTINCT d.Nombre
                ORDER BY d.Nombre
                SEPARATOR ', '
            ) AS departamentos,
            COUNT(*) AS cantidad
        FROM municipio m
        JOIN departamento d
            ON m.Id_departamento = d.Id_departamento
        GROUP BY m.Nombre
        HAVING COUNT(*) > 1
        ORDER BY m.Nombre;
        """
        cursor.execute(query)
        results = cursor.fetchall()
        cursor.close()
        connection.close()
        return results
