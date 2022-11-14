import os, math, csv
import numpy as np
import struct
import matplotlib.pyplot as plt

class Medicion:
    def __init__(self, dirName) -> None:
        #si no existe el directori, sale
        if not os.path.exists(dirName):
            print("ERROR: No existe el directorio")
            exit()
        
        #define los atributos basicos de la Medicion
        self.dirName = dirName

        self.accelerationX = []
        self.accelerationY = []
        self.accelerationZ = []

        self.temp = []

        self.gyroscopeX = []
        self.gyroscopeY = []
        self.gyroscopeZ = []

        #Las muestras de guardan de a 14 bytes
        self.BYTES_MUESTRA = 14
        #Los primeros 23 bytes corresponden al encabezado y se tiran
        self.BYTES_ENCABEZADO = 23
    
    def __str__(self) -> str:
        return self.dirName[-67:]

    def leerMediciones(self) -> None:
        #Busca todos los archivos dentro del directorio para apenderlos a la medicion
        #El ESP genera archivos de a 3000 mediciones (1min de grabacion)
        dirList = os.listdir(self.dirName)
        for archivo in dirList:
            self.leerArchivoMediciones(self.dirName+"\\"+archivo)
    
    def leerArchivoMediciones(self, fileName) -> None:
        file = open(fileName,"rb")
        file.read(self.BYTES_ENCABEZADO) #tira los datos del encabezado

        muestra = file.read(self.BYTES_MUESTRA)
        while muestra:
            #por cada byte que lee lo apendea
            self.agregarMediciones(muestra)
            muestra = file.read(self.BYTES_MUESTRA)
        
        file.close()

    def agregarMediciones(self, muestra) -> None:
        # toma bytes de a dos valores uint8 + uint8 -> int16
        '''
        cada byte es una medicion de lo siguiente campos
        ACCEL_XOUT_H = muestra[1];
        ACCEL_XOUT_L = muestra[2];
        ACCEL_YOUT_H = muestra[3];
        ACCEL_YOUT_L = muestra[4];
        ACCEL_ZOUT_H = muestra[5];
        ACCEL_ZOUT_L = muestra[6];

        TEMP_OUT_H = muestra[7];
        TEMP_OUT_L = muestra[8];

        GYRO_XOUT_H = muestra[9];
        GYRO_XOUT_L = muestra[10];
        GYRO_YOUT_H = muestra[11];
        GYRO_YOUT_L = muestra[12];
        GYRO_ZOUT_H = muestra[13];
        GYRO_ZOUT_L = muestra[14];
        '''
        if len(muestra) != 14:
            return

        listaMuestras = struct.unpack('7h', muestra)

        self.accelerationX.append(listaMuestras[0])
        self.accelerationY.append(listaMuestras[1])
        self.accelerationZ.append(listaMuestras[2])

        self.temp.append(listaMuestras[3]/340 + 36.53)

        self.gyroscopeX.append(listaMuestras[4])
        self.gyroscopeY.append(listaMuestras[5])
        self.gyroscopeZ.append(listaMuestras[6])

    def cambiarEscalaGyroscopo(self, escala) -> None:
        self.gyroscopeX = [ x/escala for x in self.gyroscopeX]
        self.gyroscopeY = [ x/escala for x in self.gyroscopeY]
        self.gyroscopeZ = [ x/escala for x in self.gyroscopeZ]

    def cambiarEscalaAcelerometro(self, escala) -> None:
        self.accelerationX = [ x/escala for x in self.accelerationX]
        self.accelerationY = [ x/escala for x in self.accelerationY]
        self.accelerationZ = [ x/escala for x in self.accelerationZ]
    
    def cantidadMediciones(self,fileName) -> int:
        # numero de muestras tomadas
        cantMuestras = math.ceil(os.fstat(fileName.fileno()).st_size / self.BYTES_MUESTRA)
        cantMuestras -=2
        return cantMuestras
    
    def exportarCSV(self):
        csvName = self.dirName.split("\\")[-1] + ".csv"
        csvName = self.dirName + "\\" + csvName

        with open( csvName, 'w', newline='') as file:
            writer = csv.writer(file)

            headers = ['accelerationX', 'accelerationY', 'accelerationZ',
                     'gyroscopeX', 'gyroscopeY', 'gyroscopeZ', 'Temperature']  

            writer.writerow(headers)
            matrix = [ self.accelerationX , self.accelerationY, self.accelerationZ,
                        self.gyroscopeX, self.gyroscopeY, self.gyroscopeZ, self.temp ]
            #traspone la matrix
            matrix = map(list, zip(*matrix))

            writer.writerows(matrix)
    

        
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






