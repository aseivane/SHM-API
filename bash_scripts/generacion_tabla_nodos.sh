#!/bin/sh
# Con openwrt debemos cambiar lo anterior por #!/bin/sh

# Parametros iniciales

broker=$1
port="1883"
usr=$2
pass=$3

topic2="nodo/estado"

mqtt_log="/app/public/datos/estado/mensajes_mqtt.log"
csv="/app/public/datos/estado/tabla_nodos_inicio.csv"
temp="/app/public/datos/estado/temp.txt"
time_out=6


echo "AVERIGUANDO ESTADO DE LOS NODOS"
ts=$(date "+%Y/%m/%d %H:%M:%S") # Guardamos la fecha y hora actual en una variable.
echo "Hora Actual: $ts"


if test -f "$csv"; then
  cat /dev/null > $csv
fi
echo "id,alias,ip,rssi,type,sync,time,state,name,tLeft" > $csv; 

# Preguntar por el estado de los nodos
if [ ! test -f "$temp" ]; then  #si el archivo temporal ya esta generado es porque se acaba de hacer una consulta 
  mosquitto_sub -t $topic2 -h $broker -p $port -v -u $usr -P $pass -W $time_out 1> $temp 2> /dev/null &
  mosquitto_pub -t control/estado -h $broker -p $port -m "0" -u $usr -P $pass # Consulta de estado a todos los nodos
fi
sleep $time_out

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

done < $temp # se pone el comando acá eb vez de antes del while porque sino se pierde el valor de las variables dentro del bucle
if [ ! test -f "$temp" ]; then
  rm $temp
fi
echo "Fin de la consulta de estado"
