#!/bin/bash
# Con openwrt debemos cambiar lo anterior por #!/bin/sh

# Parametros iniciales

broker=$1
port="1883"
usr=$2
pass=$3

topic2="nodo/estado"

archivo1="public/datos/estado/mensajes_mqtt.log"
archivo2="public/datos/estado/tabla_nodos_inicio.csv"


echo "AVERIGUANDO ESTADO DE LOS NODOS"


if test -f "$archivo2"; then
    rm $archivo2
fi
echo "id,ip,rssi,type,sync,time,state" > $archivo2; 

# Preguntar por el estado de los nodos
mosquitto_pub -t control/estado -h $broker -p $port -m "0" -u $usr -P $pass # Consulta de estado a todos los nodos

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

done < <(timeout 5s mosquitto_sub -t $topic2 -h $broker -p $port -v -u $usr -P $pass) # se pone el comando acá eb vez de antes del while porque sino se pierde el valor de las variables dentro del bucle
echo "Fin de la consulta de estado"
