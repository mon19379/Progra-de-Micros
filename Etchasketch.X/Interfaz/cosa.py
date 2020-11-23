import serial
import time
import sys
import math
# loop infinito
dato = serial.Serial(port='COM4',baudrate=9600, parity=serial.PARITY_NONE, stopbits=serial.STOPBITS_ONE,bytesize=serial.EIGHTBITS, timeout=0)
dato.flushInput()
dato.flushOutput()
def un_nombre():
        dato.flushInput()
        datos = ''
        time.sleep(.1)
        dato.readline()
        #variable = dato.readline(3)
        variables = ord(dato.read())
        variables1 = ord(dato.read())
        variables2 = ord(dato.read())
        datos = str(variables1) + "," + str(variables) + "," +str(variables2)
        datos1 = datos.split(",")
        map1 =  math.floor(5*int(datos1[1])/13)
        map2 =  math.floor(5*int(datos1[2])/13)
        ret = [map1,map2]
        return ret
def enviar_datos(envio1, envio2):
        try:
                dato.write(bytes.fromhex(envio1))
        except:
                dato.write(bytes.fromhex('00'))
        try:
                dato.write(bytes.fromhex(envio2))
        except:
                dato.write(bytes.fromhex('00'))
        return 

