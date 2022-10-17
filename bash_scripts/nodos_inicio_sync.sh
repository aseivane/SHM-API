#!/bin/bash

# Parametros iniciales
epoch_inicio=$1
broker="192.168.0.10" 
port="1883"
usr="usuario"
pass="usuariopassword"

topic1="control/inicio_muestreo"

nro_medicion=`printf %03d $3`
archivo1="./mediciones/medicion_$nro_medicion/mensajes_mqtt.log"
archivo2="./mediciones/medicion_$nro_medicion/tabla_nodos_inicio.csv"

echo "Archivo de confirmación: "
echo $archivo2

echo "Enviando mensaje de inicio"
# Enviar mensaje de inicio a los nodos 
mosquitto_pub -t $topic1 -h $broker -p $port -m "$1 $2 $3" -u $usr -P $pass # argumentos: $1 EPOCH inicio, $2 duracion, $3 nro de medicion


echo "Recibiendo confirmaciones de inicio"

# Recepción de confirmacion de inicio de los nodos
./bash_scripts/generacion_tabla_inicio.sh $nro_medicion 





