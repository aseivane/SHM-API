#!/bin/sh

# Parametros iniciales
broker=$1
port="1883"
usr=$2
pass=$3
epoch_inicio=$4
duracion=$5
nro_medicion=$6


topic1="control/inicio_muestreo"

nro_medicion_ext=`printf %03d $nro_medicion`
archivo1="/app/public/datos/mediciones/medicion_$nro_medicion_ext/mensajes_mqtt.log"
archivo2="/app/public/datos/mediciones/medicion_$nro_medicion_ext/tabla_nodos_inicio.csv"

echo "Archivo de confirmación: "
echo $archivo2
echo "Epoch mosquito $epoch_inicio"
echo "Enviando mensaje de inicio"
# Enviar mensaje de inicio a los nodos 
mosquitto_pub -t $topic1 -h $broker -p $port -m "$epoch_inicio $duracion $nro_medicion" -u $usr -P $pass # argumentos: $1 EPOCH inicio, $2 duracion, $3 nro de medicion


echo "Recibiendo confirmaciones de inicio"

# Recepción de confirmacion de inicio de los nodos
./bash_scripts/generacion_tabla_inicio.sh $broker $usr $pass $nro_medicion_ext 





