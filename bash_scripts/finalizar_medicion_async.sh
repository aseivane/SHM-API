#!/bin/sh

# Parametros iniciales
#---------------------------------------------------

broker=$1
port="1883"
usr=$2
pass=$3
duracion_m=$4
nro_medicion=$5
epoch_inicio=$6

nro_medicion_ext=`printf %03d "$nro_medicion"` 

tout_inicio_s=0
directorio="/app/public/datos/mediciones/medicion_$nro_medicion_ext"
archivo1="/app/public/datos/mediciones/medicion_$nro_medicion_ext/mensajes_mqtt.log"
archivo2="/app/public/datos/mediciones/medicion_$nro_medicion_ext/tabla_nodos_inicio.csv"
archivo3="/app/public/datos/mediciones/medicion_$nro_medicion_ext/tabla_nodos_fin.csv"  
n=0
k=0

# Comprobar la existencia de directorio de medición y archivos
# Si existen, se vacían, sino se crean.
#----------------------------------------------------
if [ -d $directorio ]; then
nop
else
mkdir $directorio
fi

cat /dev/null > $archivo1
cat /dev/null > $archivo2
cat /dev/null > $archivo3

# Espera para finalizar las mediciones
#--------------------------------------------------
hora_actual_s=`date "+%s"`  # devuelve los segundos de hora actual, desde algun año que no conozco
espera_fin_s=$(( $duracion_m * 60  - 10 )) # tiempo de espera es la duracion menos 10 segundos de anticipación

sleep $espera_fin_s

echo -e "\rFin de las mediciones    $(date +"%Y/%m/%d %H:%M:%S")          "

# Configuración inicial de tiempos
#------------------------------------------------

echo -e "\nCONFIRMACÓN\n-----------"

# escuchar confirmaciones de los nodos
./bash_scripts/nodos_fin.sh $broker $usr $pass $nro_medicion

datos=$(wc -l $archivo3)
k=$(echo $datos | awk '{print $1}')  # numero de nodos que confirmaron la medición completa
echo "Completaron las medicioens $k nodos (de los $n nodos identificados inicialmente)"


# pedir archivos por http nodo por nodo (leyendo de la tabla usando como topic coordinador/MAC-NODO)
#--------------------------------------------------
echo -e "\nRECOLECCIÓN Y BORRADO DE TARJETAS\n-----------"
echo "Solicitando archivos a los nodos..."
./bash_scripts/recoleccion.sh $broker $usr $pass $nro_medicion