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
topic2="nodo/confirmacion"

temp="/app/public/datos/mediciones/medicion_$nro_medicion/temp.txt"
time_out=6

echo "Enviando mensaje de inicio"

# Enviar mensaje de inicio a los nodos 
mosquitto_sub -t $topic2 -h $broker -p $port -v -u $usr -P $pass -W $time_out 1> $temp 2> /dev/null &
mosquitto_pub -t $topic1 -h $broker -p $port -m "$epoch_inicio $duracion $nro_medicion" -u $usr -P $pass # argumentos: $1 EPOCH inicio, $2 duracion, $3 nro de medicion
sleep $time_out


echo "Recibiendo confirmaciones de inicio"

# Recepción de confirmacion de inicio de los nodos
./bash_scripts/generacion_tabla_inicio.sh $broker $usr $pass $nro_medicion 





