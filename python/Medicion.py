import os, math, csv
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
        dirObjects = dirName.split('\\')

        self.nodo = dirObjects.pop(-1)
        self.medicion = dirObjects.pop(-2)

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
            if archivo.split('.')[-1] == "DAT":
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
        if len(muestra) != 14:
            return
            
        # toma bytes de a dos valores uint8 + uint8 -> int16
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
    
    
    def graficar(self):
        fig, ax = plt.subplots(3,1)

        ax[0].set_title("Acelerometro")
        ax[0].plot(self.accelerationX, color='b', linewidth=0.1)
        ax[0].plot(self.accelerationY, color='r', linewidth=0.1)
        ax[0].plot(self.accelerationZ, color='g', linewidth=0.1)

        #plt.savefig()
    
    def exportarCSV(self):
        csvName = self.dirName.split("\\")[-1] + ".csv"
        csvName = self.dirName + "\\" + csvName

        try:
            newFile = open( csvName, 'w', newline='')
        except:
            raise "No se puede abrir o modificar el archivo"

        writer = csv.writer(newFile)

        headers = ['accelerationX', 'accelerationY', 'accelerationZ',
                    'gyroscopeX', 'gyroscopeY', 'gyroscopeZ', 'Temperature']  

        writer.writerow(headers)
        matrix = [ self.accelerationX , self.accelerationY, self.accelerationZ,
                    self.gyroscopeX, self.gyroscopeY, self.gyroscopeZ, self.temp ]
        #traspone la matrix
        matrix = map(list, zip(*matrix))

        writer.writerows(matrix)

        newFile.close()