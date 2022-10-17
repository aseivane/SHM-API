#!/bin/bash
# Con openwrt debemos cambiar lo anterior por #!/bin/sh

# Parametros iniciales
hora_inicio_s=$1
broker="192.168.0.10" 
port="1883"
usr="usuario"
pass="usuariopassword"

topic1="control/inicio_muestreo_async"

nro_medicion=`printf %03d $3`
archivo1="./mediciones/medicion_$nro_medicion/mensajes_mqtt.log"
archivo2="./mediciones/medicion_$nro_medicion/tabla_nodos_inicio.csv"



echo $archivo2


echo "Iniciando medicion"


# Enviar mensaje de inicio a los nodos 
mosquitto_pub -t $topic1 -h $broker -p $port -m "$2 $3" -u $usr -P $pass # argumentos: $2 duracion, $3 nro de medicion

echo "Esperando confirmaciones de inicio"

# Recepción de confirmacion de inicio de los nodos
./bash_scripts/generacion_tabla_inicio.sh $nro_medicion 


