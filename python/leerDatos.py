import matplotlib.pyplot as plt
from Medicion import Medicion
import os, sys

def graficarMediciones(medicion):
    fig, ax = plt.subplots(2,1)

    ax[0].set_title("Acelerometro")
    ax[0].plot(medicion.accelerationX, color='b', linewidth=0.1)
    ax[0].plot(medicion.accelerationY, color='r', linewidth=0.1)
    ax[0].plot(medicion.accelerationZ, color='g', linewidth=0.1)
    
    ax[1].set_title("Temperatura")
    ax[1].plot(medicion.temp, color='b', linewidth=0.1)

    plt.show()

def listaMediciones(dirName) -> list:
    dirList = os.listdir(dirName)
    listMediciones = []

    for carpeta in dirList:
        dirNodo = os.path.join(dirName, carpeta)  # join the path
        listMediciones.append(Medicion(dirNodo))

    return listMediciones

if __name__ == '__main__':

    flags = ("-f", "-l")

    # Los siguientes valores dependen de la sensibilidad utilizada
    try:
        argFlag = sys.argv[1]
    except IndexError:
        raise SystemExit(f"python leerDatos.py -f <carpeta mediciones> ")
    
    if not argFlag in flags:
        raise SystemExit(f"Unknown flag \"{argFlag}\"")
    
    try:
        argDir = sys.argv[2]
    except IndexError:
        raise SystemExit(f"Falta directorio") 

    if not os.path.isdir(argDir):
        raise SystemExit(f"No existe la carpeta") 
    
    '''
    ESCALA_ACELEROMETRO = 16384
    ESCALA_GIROSCOPO = 131

    dirName = "C:\\Users\\user\\Documents\\Facu\\TP profesional\\prueba\\prueba\\p20\\5min\\medicion_025\\datos_025"
    
    listMediciones = agregarMediciones(dirName)
    
    for medicion in listMediciones:
        medicion.leerMediciones()
        medicion.cambiarEscalaAcelerometro(ESCALA_ACELEROMETRO)
        medicion.exportarCSV()

    #graficarMediciones(listMediciones[1])
    '''






