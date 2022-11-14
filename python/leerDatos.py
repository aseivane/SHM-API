import os.path, math
import numpy as np
import struct
import matplotlib.pyplot as plt

class Medicion:
    def __init__(self, fileName) -> None:
        if not os.path.exists(fileName):
            print("No existe el archivo")
            exit()
        
        self.fileName = fileName


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
        return self.fileName[-67:]

    def leerMediciones(self) -> None:
        self.file = open(self.fileName,"rb")
        self.file.read(self.BYTES_ENCABEZADO) #tira los datos del encabezado

        byte = self.file.read(self.BYTES_MUESTRA)
        i=1
        while byte:
            self.agregarMediciones(byte,i)
            i+=1
            byte = self.file.read(self.BYTES_MUESTRA)

    def agregarMediciones(self, byte,i) -> None:
        # toma bytes de a dos valores uint8 + uint8 -> int16
        '''
        cada byte es una medicion de lo siguiente campos
        ACCEL_XOUT_H = byte[1];
        ACCEL_XOUT_L = byte[2];
        ACCEL_YOUT_H = byte[3];
        ACCEL_YOUT_L = byte[4];
        ACCEL_ZOUT_H = byte[5];
        ACCEL_ZOUT_L = byte[6];

        TEMP_OUT_H = byte[7];
        TEMP_OUT_L = byte[8];

        GYRO_XOUT_H = byte[9];
        GYRO_XOUT_L = byte[10];
        GYRO_YOUT_H = byte[11];
        GYRO_YOUT_L = byte[12];
        GYRO_ZOUT_H = byte[13];
        GYRO_ZOUT_L = byte[14];
        '''
        if len(byte) != 14:
            return
        unpackedByte = struct.unpack('7h', byte)

        self.accelerationX.append(unpackedByte[0])
        self.accelerationY.append(unpackedByte[1])
        self.accelerationZ.append(unpackedByte[2])

        self.temp.append(unpackedByte[3])

        self.gyroscopeX.append(unpackedByte[4])
        self.gyroscopeY.append(unpackedByte[5])
        self.gyroscopeZ.append(unpackedByte[6])

    def cambiarEscalaGyroscopo(self, escala):
        self.gyroscopeX = [ x/escala for x in self.gyroscopeX]
        self.gyroscopeY = [ x/escala for x in self.gyroscopeY]
        self.gyroscopeZ = [ x/escala for x in self.gyroscopeZ]

    def cambiarEscalaAcelerometro(self, escala):
        self.accelerationX = [ x/escala for x in self.accelerationX]
        self.accelerationY = [ x/escala for x in self.accelerationY]
        self.accelerationZ = [ x/escala for x in self.accelerationZ]
    
    def cantidadMediciones(self) -> int:
        # numero de muestras tomadas
        muestras = math.ceil(os.fstat(self.fileName.fileno()).st_size / self.BYTES_MUESTRA)
        muestras = muestras-2
        return muestras
        

if __name__ == '__main__':

    # Los siguientes valores dependen de la sensibilidad utilizada
    ESCALA_ACELERACION = 16384
    ESCALA_GIROSCOPO = 131
    fileName = "C:\\Users\\user\\Documents\\Facu\\TP profesional\\prueba\\prueba\\p20\\5min\\medicion_025\\datos_025\\nodo_94b97eda7f38\\25-0.DAT"
    medicion = Medicion(fileName)
    medicion.leerMediciones()
    medicion.cambiarEscalaGyroscopo(ESCALA_GIROSCOPO)
    medicion.cambiarEscalaAcelerometro(ESCALA_ACELERACION)

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




