#!/bin/sh

# Parametros iniciales
broker=$1
port="1883"
usr=$2
pass=$3
nro_medicion=$4

topic2="nodo/confirmacion"

archivo1="/app/public/datos/mediciones/medicion_$nro_medicion/mensajes_mqtt.log"
archivo2="/app/public/datos/mediciones/medicion_$nro_medicion/tabla_nodos_inicio.csv"

# Guardo las respuestas y genero la tabla de nodos al inicio
while read value; do
    
  ts=$(date "+%Y/%m/%d %H:%M:%S") # Guardamos la fecha y hora actual en una variable.

   echo "Hora Actual: $ts"

  topic=`echo "$value" | awk '{print $1}'`

  if [[ $topic = $topic2 ]]; then
  # guardar id y estado del nodo recibido
  # PREGUNTAR SI EL NODO ESTA REPETIDO EN LA TABLA 
  nodoid=`echo "$value" | awk -F' ' 'BEGIN {OFS=","} {$1=""; sub("^,", ""); print}'`
  nodoid_shell=`echo "$value" | awk '{print $2 "," $3 "," $5}'`
  echo "$nodoid" >> $archivo2   # guardamos datos en archivo
  echo "$ts mensaje recibido: [$value]" >> $archivo1   # guardamos datos en archivo
  echo "$ts Nodo identificado: $nodoid_shell"
  else 
  # mensaje no identificado
  echo "$ts mensaje recibido no identificao!: [$value]" >> $archivo1   # guardamos datos en archivo
  echo "$ts mensaje recibido no identificao!: [$value]"
  fi
sync=`echo "$value" | awk '{print $6}'`

done < <(timeout 5s mosquitto_sub -t $topic2 -h $broker -p $port -v -u $usr -P $pass) # se pone el comando acá en vez de antes del while porque sino se pierde el valor de las variables dentro del bucle
echo "Fin de la consulta de estado"

