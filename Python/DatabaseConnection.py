import mysql.connector

class DatabaseConnection:
    
    def connectToDb(self):
        # Open database connection
        dbConnection = mysql.connector.connect(user='root', password='ineeduyes',host='localhost',database='AWA')
        return dbConnection
    
    def closeDb(self,dbConnection):
        # close database connection
        dbConnection.close()