#!/bin/bash
# Con openwrt debemos cambiar lo anterior por #!/bin/sh

# Parametros iniciales
hora_inicio_s=$1
broker="192.168.0.10" 
port="1883"
usr="usuario"
pass="usuariopassword"

topic1="control/inicio_muestreo"
topic2="nodo/estado"


nro_medicion=`printf %03d $3`
archivo1="./mediciones/medicion_$nro_medicion/mensajes_mqtt.log"
archivo2="./mediciones/medicion_$nro_medicion/tabla_nodos_inicio.csv"

echo $archivo2

#./bash_scripts/generacion_tabla_inicio.sh $nro_medicion &  # Lo ejecuto en una tarea nueva
./bash_scripts/generacion_tabla_inicio.sh $nro_medicion 

#------------------------------------
# Ponemos al coordinador a escuchar las respuestas a la configuración inicial
# Formato mensaje: [mac] [ip] [rssi] [tipo] [sync] [epoch]. # ej: "246f28108160 192.168.0.144 -56 nodo_acelerometro no_sincronizado" 

hora_actual_s=`date "+%s"`   # Carga en hora actual la hora EPOCH actual en formato string
tout_inicio_s="$((hora_inicio_s - hora_actual_s))s"
echo "Hora_inicio: $hora_inicio_s Hora_actual: $hora_actual_s TIMEOUT: $tout_inicio_s"

# Enviar mensaje de inicio a los nodos 

#mosquitto_pub -t $topic1 -h $broker -p $port -m "$1 $2 $3" -u $usr -P $pass # argumentos: $1 EPOCH inicio, $2 duracion, $3 nro de medicion
mosquitto_pub -t control/inicio_muestreo_async -h $broker -p $port -m "$2 $3" -u $usr -P $pass # argumentos: $1 EPOCH inicio, $2 duracion, $3 nro de medicion





