#!/bin/bash

# Parametros iniciales
broker="192.168.0.10" 
port="1883"
usr="usuario"
pass="usuariopassword"

#topic1="control/inicio_muestreo"
topic2="nodo/confirmacion"

archivo1="./mediciones/medicion_$1/mensajes_mqtt.log"
archivo2="./mediciones/medicion_$1/tabla_nodos_inicio.csv"

#echo "Numero de medicion:"
#echo  $1

#Enviar mensaje de averiguacion de estado a todos los nodos
#mosquitto_pub -t control/estado -h $broker -p $port -m "0" -u $usr -P $pass # Consulta de estado a todos los nodos

# Guardo las respuestas y genero la tabla de nodos al inicio
while read value; do
    
  ts=$(date "+%Y/%m/%d %H:%M:%S") # Guardamos la fecha y hora actual en una variable.

   echo "Hora Actual: $ts"

  topic=`echo "$value" | awk '{print $1}'`


  if [[ $topic = $topic2 ]]; then
  # guardar id y estado del nodo recibido
  # PREGUNTAR SI EL NODO ESTA REPETIDO EN LA TABLA 
  nodoid=`echo "$value" | awk '{print $2 "," $3 "," $4 "," $5 "," $6 "," $7 "," $8}'`
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
