#!/bin/sh

# Parametros iniciales
#---------------------------------------------------

broker=$1
port="1883"
usr=$2
pass=$3
duracion_m=$4
nro_medicion=$5
epoch_inicio=$6

directorio="/app/public/datos/mediciones/medicion_$nro_medicion"
mqtt_log="/app/public/datos/mediciones/medicion_$nro_medicion/mensajes_mqtt.log"
csv_inicio="/app/public/datos/mediciones/medicion_$nro_medicion/tabla_nodos_inicio.csv"
csv_fin="/app/public/datos/mediciones/medicion_$nro_medicion/tabla_nodos_fin.csv"  


# Espera para finalizar las mediciones
#--------------------------------------------------
echo -e "\nMEDICIÓN\n--------"
hora_actual_s=`date "+%s"`  # devuelve los segundos de hora actual, desde algun año que no conozco
espera_inicio_s=$(( $epoch_inicio - $hora_actual_s)) # tiempo de espera desde la hora actual hasta la hora de inicio

sleep $espera_inicio_s

echo -e "\rInicio de las mediciones $(date +"%Y/%m/%d %H:%M:%S")         "

hora_actual_s=`date "+%s"`  # devuelve los segundos de hora actual, desde algun año que no conozco
espera_fin_s=$(( $duracion_m * 60  - 10 )) # tiempo de espera es la duracion menos 10 segundos de anticipación

sleep $espera_fin_s

echo -e "\rFin de las mediciones    $(date +"%Y/%m/%d %H:%M:%S")          "


# Escuchar las confirmaciones de las mediciones completas
#--------------------------------------------------
echo -e "\nCONFIRMACÓN\n-----------"

# escuchar confirmaciones de los nodos
./bash_scripts/nodos_fin.sh $broker $usr $pass $nro_medicion

k=$(wc -l $csv_fin | awk '{print $1}')  # numero de nodos que confirmaron la medición completa
n=$(wc -l $csv_inicio | awk '{print $1}') 

echo "Completaron las mediciones $k nodos (de los $n nodos identificados inicialmente)"


# # pedir archivos por http nodo por nodo (leyendo de la tabla usando como topic coordinador/MAC-NODO)
# #--------------------------------------------------
# echo -e "\nRECOLECCIÓN Y BORRADO DE TARJETAS\n-----------"
# echo "Solicitando archivos a los nodos..."
# cant_archivos=$duracion_m #un archivo por minuto
# ./bash_scripts/recoleccion.sh $broker $usr $pass $nro_medicion $cant_archivos


# #--------------------------------------------------
# echo -e "\nPROCESAMIENTO\n-------------"
# # procesar mediciones (dar formato, corregir errores, comprimir)
# #agregar headers aca para que no rompa el resto de los scripts
# sed -i '1s/^/id,ip,time\n/' $csv_fin

# directorio_datos=$directorio"/datos_$nro_medicion"
# echo "Generando csv en $directorio_datos"
# python3 /app/python/leerDatos.py --images $directorio_datos

