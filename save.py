import mysql.connector
import csv
from datetime import datetime

class TYPE:
    NET = "net.usage.average"
    CPU = "cpu.usage.average"
    MEM = "mem.usage.average"

DB = mysql.connector.connect(host="localhost",user= "root", password="", database="vsphere", port=3308)

def save2DB(DB, par):
    cursor = DB.cursor()
    sql = "SELECT * FROM performance WHERE entity=%s AND timestamp=%s AND type=%s"
    cursor.execute(sql, (par[0], par[2], par[3]))
    cursor.fetchall()
    if cursor.rowcount == 0:
        sql = "INSERT INTO `performance`(`entity`, `value`, `timestamp`, `type`, `unit`) VALUES (%s, %s, %s, %s, %s)"
        cursor.execute(sql, par)
        DB.commit()

def readFile(fileName):
    index = 0
    for row in csv.reader(open(fileName)):
        index = index + 1
        if index > 1:
            watt = row[0]
            timestamp = datetime.strptime(row[1], "%d/%m/%Y %I:%M:%S %p")
            entity = row[5]
            unit = row[3]
            metricID = row[2]
            val = (entity, float(watt), timestamp, metricID, unit)
            save2DB(DB, val)
    print("Read " + fileName + " complete at " + str(datetime.now()))


readFile("power.csv")
readFile("net.csv") 
readFile("mem.csv")  
readFile("cpu.csv")    