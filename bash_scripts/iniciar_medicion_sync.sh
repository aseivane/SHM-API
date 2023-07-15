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


tout_inicio_s=0
directorio="/app/public/datos/mediciones/medicion_$nro_medicion"
archivo1="/app/public/datos/mediciones/medicion_$nro_medicion/mensajes_mqtt.log"
archivo2="/app/public/datos/mediciones/medicion_$nro_medicion/tabla_nodos_inicio.csv"
archivo3="/app/public/datos/mediciones/medicion_$nro_medicion/tabla_nodos_fin.csv"  
n=0
k=0

# Comprobar la existencia de directorio de medición y archivos
# Si existen, se vacían, sino se crean.
#----------------------------------------------------
if [ -d $directorio ]; then
echo "El directorio existe"
else
mkdir $directorio
fi

cat /dev/null > $archivo1
cat /dev/null > $archivo2
cat /dev/null > $archivo3

# Configuración inicial de tiempos
#------------------------------------------------

hora_actual_s=`date "+%s"`   # Lee la hora local en formato EPOCH
hora_inicio_s=$epoch_inicio
echo "epoch inicio $epoch_inicio" 
#hora_inicio_s=$(( hora_actual_s + tout_inicio_s ))

hora_fin_s=$(( hora_inicio_s + (60*duracion_m )))

# Enviar mensaje de inicialización y escuchar respuestas
#--------------------------------------------------
# formato fecha-hora
hora_inicio=`date +'%Y/%m/%d %H:%M:%S' -d @$hora_inicio_s`
hora_fin=`date +'%Y/%m/%d %H:%M:%S' -d @$hora_fin_s`

echo -e "\nINICIO\n------"
echo "Hora de inicio:       $hora_inicio"
echo "Hora de finalización: $hora_fin"
echo "Duración configurada: $duracion_m minutos"

echo "Se envia mensaje de inicialización e identificación de nodos."
# escucha confirmación de inicio de los nodos
./bash_scripts/nodos_inicio_sync.sh $broker $usr $pass $epoch_inicio $duracion_m $nro_medicion

# contamos la cantidad de nodos identificados
echo $archivo2


datos=$(wc -l $archivo2)
n=$(echo $datos | awk '{print $1}') 

# confirmamos
echo "Se indentificaron $n nodos."

