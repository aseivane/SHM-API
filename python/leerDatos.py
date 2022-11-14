import matplotlib.pyplot as plt
from Medicion import Medicion
import os

def graficarMediciones(medicion):
    fig, ax = plt.subplots(3,1)

    ax[0].set_title("Acelerometro")
    ax[0].plot(medicion.accelerationX, color='b', linewidth=0.1)
    ax[0].plot(medicion.accelerationY, color='r', linewidth=0.1)
    ax[0].plot(medicion.accelerationZ, color='g', linewidth=0.1)

    ax[1].set_title("Giroscopo")
    ax[1].plot(medicion.gyroscopeX, color='b', linewidth=0.1)
    ax[1].plot(medicion.gyroscopeY, color='r', linewidth=0.1)
    ax[1].plot(medicion.gyroscopeZ, color='g', linewidth=0.1)
    
    ax[2].set_title("Temperatura")
    ax[2].plot(medicion.temp, color='b', linewidth=0.1)

    plt.show()

def agregarMediciones(dirName) -> list:
    dirList = os.listdir(dirName)
    listMediciones = []

    for carpeta in dirList:
        dirNodo = os.path.join(dirName, carpeta)  # join the path
        #os.chdir(full_path)  # change directory to the desired path
        listMediciones.append(Medicion(dirNodo))

    return listMediciones

if __name__ == '__main__':

    # Los siguientes valores dependen de la sensibilidad utilizada
    ESCALA_ACELERACION = 16384
    ESCALA_GIROSCOPO = 131

    dirName = "C:\\Users\\user\\Documents\\Facu\\TP profesional\\prueba\\prueba\\p20\\5min\\medicion_025\\datos_025"
    
    listMediciones = agregarMediciones(dirName)
    
    for medicion in listMediciones:
        medicion.leerMediciones()
        medicion.cambiarEscalaGyroscopo(ESCALA_GIROSCOPO)
        medicion.cambiarEscalaAcelerometro(ESCALA_ACELERACION)
        medicion.exportarCSV()

    graficarMediciones(listMediciones[1])






