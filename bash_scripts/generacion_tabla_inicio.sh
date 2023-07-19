#!/bin/sh

# Parametros iniciales
broker=$1
port="1883"
usr=$2
pass=$3
nro_medicion=$4

topic2="nodo/confirmacion"

mqtt_log="/app/public/datos/mediciones/medicion_$nro_medicion/mensajes_mqtt.log"
csv="/app/public/datos/mediciones/medicion_$nro_medicion/tabla_nodos_inicio.csv"
temp="/app/public/datos/mediciones/medicion_$nro_medicion/temp.txt"

ts=$(date "+%Y/%m/%d %H:%M:%S") # Guardamos la fecha y hora actual en una variable.
echo "Hora Actual: $ts"

# Guardo las respuestas y genero la tabla de nodos al inicio
while IFS= read -r line; do    

  topic=`echo "$line" | awk '{print $1}'`

  if [[ $topic = $topic2 ]]; then
    # guardar id y estado del nodo recibido
    # PREGUNTAR SI EL NODO ESTA REPETIDO EN LA TABLA 
    nodoid=`echo "$line" | awk -F' ' 'BEGIN {OFS=","} {$1=""; sub("^,", ""); print}'`
    nodoid_shell=`echo "$line" | awk '{print $2 "," $3 "," $4}'`
    echo "$nodoid" >> $csv   # guardamos datos en archivo
    echo "$ts mensaje recibido: [$line]" >> $mqtt_log   # guardamos datos en archivo
    echo "$ts Nodo identificado: $nodoid_shell"
  else 
    # mensaje no identificado
    echo "$ts mensaje recibido no identificao!: [$line]" >> $mqtt_log   # guardamos datos en archivo
    echo "$ts mensaje recibido no identificao!: [$line]"
  fi

done < $temp # se pone el comando acá en vez de antes del while porque sino se pierde el valor de las variables dentro del bucle
if [ ! test -f "$temp" ]; then
  rm $temp
fi
echo "Fin de la consulta de estado"

