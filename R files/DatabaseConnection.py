import mysql.connector

def connectToDb():
    # Open database connection
    dbConnection = mysql.connector.connect(user='root', password='ineeduyes',host='localhost',database='corpus')
    return dbConnection

def closeDb(dbConnection):
    # close database connection
    dbConnection.close()