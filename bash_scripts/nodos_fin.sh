#!/bin/sh
# Con openwrt debemos cambiar lo anterior por #!/bin/sh

# Parametros iniciales
broker=$1
port="1883"
usr=$2
pass=$3
nro_medicion=$4

topic2="nodo/fin"
archivo1="/app/public/datos/mediciones/medicion_$nro_medicion/mensajes_mqtt.log"
archivo3="/app/public/datos/mediciones/medicion_$nro_medicion/tabla_nodos_fin.csv"  
tout_fin="20s"

#------------------------------------
# Escuchar las confirmaciones de las mediciones completas
echo "Comenzando espera de $tout_fin para confirmaciones..."

# Formato mensaje: [mac] [nro_meidcion]. $1 <topic>, $2 [mac], $3 [nro_medicion]

while read value; do

  ts=$(date "+%Y/%m/%d %H:%M:%S") # Guardamos la fecha y hora actual en una variable.

  topic=`echo "$value" | awk '{print $1}'`

echo "Mensaje recibido"

  if [[ $topic = $topic2 ]]; then

  # guardar confirmación de medición completa
  nodofin=`echo "$value" | awk '{print $2 "," $3}'`
  echo "$nodofin,$ts" >> $archivo3   # guardamos datos en archivo
  echo "$ts mensaje recibido: [$value]" >> $archivo1   # guardamos datos en archivo
  echo "$ts $value" 
  
  else
  # respuesta no identificada
  echo "$ts mensaje recibido no identificao!: [$value]" >> $archivo1   # guardamos datos en archivo
  echo "$ts mensaje recibido no identificao!: [$value]"

  fi
   
done < <(timeout $tout_fin mosquitto_sub -t $topic2 -h $broker -p $port -v -u $usr -P $pass)


