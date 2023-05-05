import matplotlib.pyplot as plt
from Medicion import Medicion
import os
import argparse

def graficarMediciones(medicion):
    fig, ax = plt.subplots(2,1)

    ax[0].set_title("Acelerometro")
    ax[0].plot(medicion.accelerationX, color='b', linewidth=0.1)
    ax[0].plot(medicion.accelerationY, color='r', linewidth=0.1)
    ax[0].plot(medicion.accelerationZ, color='g', linewidth=0.1)
    
    ax[1].set_title("Temperatura")
    ax[1].plot(medicion.temp, color='b', linewidth=0.1)

    plt.show()

def agregarMediciones(dirName) -> list:
    dirList = os.listdir(dirName)
    listMediciones = []

    for carpeta in dirList:
        dirNodo = os.path.join(dirName, carpeta)  # join the path
        listMediciones.append(Medicion(dirNodo))

    return listMediciones 


def configParser(parser):
    parser.add_argument('-i', '--images', type=str, metavar='dir', dest='imageDir',
                    help='Crea imagenes de las mediciones en la carpeta indicada')
    parser.add_argument('-l', '--list', type=str, metavar='dir', dest='listDir',
                    help='Lista los archivos de la carpeta indicada')
    
def main():
    ESCALA_ACELERACION = 16384
    ESCALA_GIROSCOPO = 131

    parser = argparse.ArgumentParser(prog='leer-mediciones')
    configParser(parser)
    args=vars(parser.parse_args())

    if args['imageDir'] is not None :
        dirName = args['imageDir']

        listMediciones = agregarMediciones(dirName)
    
        for medicion in listMediciones:
            medicion.leerMediciones()
            medicion.cambiarEscalaGyroscopo(ESCALA_GIROSCOPO)
            medicion.cambiarEscalaAcelerometro(ESCALA_ACELERACION)
            medicion.exportarCSV()
            medicion.graficar()

    elif args['listDir'] is not None:
        dirName = args['listDir']
        return os.listdir(dirName)

    if not dirName:
        raise SystemExit(f"Ingrese carpeta con mediciones") 
    
    if not os.path.isdir(dirName):
        raise SystemExit(f"No existe la carpeta \"{dirName}\"") 
    


if __name__ == '__main__':

    main()







