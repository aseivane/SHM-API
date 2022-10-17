#!/bin/bash
# Con openwrt debemos cambiar lo anterior por #!/bin/sh

# Parametros iniciales
broker=$1
port="1883"
usr=$2
pass=$3
duracion=$4
nro_medicion=$5

topic1="control/inicio_muestreo_async"

nro_medicion_ext=`printf %03d $nro_medicion`
archivo1="./mediciones/medicion_$nro_medicion_ext/mensajes_mqtt.log"
archivo2="./mediciones/medicion_$nro_medicion_ext/tabla_nodos_inicio.csv"


echo $archivo2


echo "Iniciando medicion"


# Enviar mensaje de inicio a los nodos 
mosquitto_pub -t $topic1 -h $broker -p $port -m "$duracion $nro_medicion" -u $usr -P $pass # argumentos: $2 duracion, $3 nro de medicion

echo "Esperando confirmaciones de inicio"

# Recepción de confirmacion de inicio de los nodos
./bash_scripts/generacion_tabla_inicio.sh $broker $usr $pass $nro_medicion_ext 


