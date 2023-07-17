#!/bin/sh
# Con openwrt debemos cambiar lo anterior por #!/bin/sh

# Parametros iniciales
broker=$1
port="1883"
usr=$2
pass=$3
duracion=$4
nro_medicion=$5

topic1="control/inicio_muestreo_async"
topic2="nodo/confirmacion"


mqtt_log="/app/public/datos/mediciones/medicion_$nro_medicion/mensajes_mqtt.log"
temp="/app/public/datos/mediciones/medicion_$nro_medicion/temp.txt"
time_out=6


echo "Iniciando medicion"

# Enviar mensaje de inicio a los nodos 
mosquitto_sub -t $topic2 -h $broker -p $port -v -u $usr -P $pass -W $time_out 1> $temp 2> /dev/null &
mosquitto_pub -t $topic1 -h $broker -p $port -m "$duracion $nro_medicion" -u $usr -P $pass # argumentos: $2 duracion, $3 nro de medicion
sleep $time_out
echo "Esperando confirmaciones de inicio"

# Recepción de confirmacion de inicio de los nodos
./bash_scripts/generacion_tabla_inicio.sh $broker $usr $pass $nro_medicion 

