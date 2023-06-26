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

nro_medicion_ext=`printf %03d "$nro_medicion"` 

tout_inicio_s=0
directorio="/app/public/datos/mediciones/medicion_$nro_medicion_ext"
archivo1="/app/public/datos/mediciones/medicion_$nro_medicion_ext/mensajes_mqtt.log"
archivo2="/app/public/datos/mediciones/medicion_$nro_medicion_ext/tabla_nodos_inicio.csv"
archivo3="/app/public/datos/mediciones/medicion_$nro_medicion_ext/tabla_nodos_fin.csv"  
n=0
k=0


# Espera para finalizar las mediciones
#--------------------------------------------------
echo -e "\nMEDICIÓN\n--------"
hora_actual_s=`date "+%s"`  # devuelve los segundos de hora actual, desde algun año que no conozco
espera_inicio_s=$(( hora_inicio_s - hora_actual_s)) # tiempo de espera desde la hora actual hasta la hora de inicio
#espera_inicio_s=5 # solo para pruebas!!!!

cuenta_regresiva=$((`date +%s` + $espera_inicio_s)); 

while [ "$cuenta_regresiva" -ge `date +%s` ]; do 
:
 # echo -ne "Tiempo restante para iniciar la medicion: $(date -u --date @$(($cuenta_regresiva - `date +%s` )) +%H:%M:%S)\r"; 
done #< <(timeout espera_fin_s) # se pone el comando acá eb vez de antes del while porque sino se pierde el valor de las variables dentro del bucle
echo -e "\rInicio de las mediciones $(date +"%Y/%m/%d %H:%M:%S")         "

hora_actual_s=`date "+%s"`  # devuelve los segundos de hora actual, desde algun año que no conozco
espera_fin_s=$(( hora_fin_s - hora_actual_s - 10 )) # tiempo de espera es la duracion menos 10 segundos de anticipación
#espera_fin_s=5 # solo para pruebas!!!!

cuenta_regresiva=$((`date +%s` + $espera_fin_s)); 
#cuenta_regresiva=$((`date +%s` + $espera_fin_s - 10 `+%s` )); 
while [ "$cuenta_regresiva" -ge `date +%s` ]; do 
:
#  echo -ne "Midiendo...   Tiempo restante para finalizar: $(date -u --date @$(($cuenta_regresiva - `date +%s` )) +%H:%M:%S)\r"; 
done #< <(timeout espera_fin_s) # se pone el comando acá eb vez de antes del while porque sino se pierde el valor de las variables dentro del bucle
echo -e "\rFin de las mediciones    $(date +"%Y/%m/%d %H:%M:%S")          "


# Escuchar las confirmaciones de las mediciones completas
#--------------------------------------------------
echo -e "\nCONFIRMACÓN\n-----------"

# escuchar confirmaciones de los nodos
./bash_scripts/nodos_fin.sh $broker $usr $pass $nro_medicion

datos=$(wc -l $archivo3)
k=$(echo $datos | awk '{print $1}')  # numero de nodos que confirmaron la medición completa
echo "Completaron las medicioens $k nodos (de los $n nodos identificados inicialmente)"


# pedir archivos por http nodo por nodo (leyendo de la tabla usando como topic coordinador/MAC-NODO)
#--------------------------------------------------
echo -e "\nRECOLECCIÓN Y BORRADO DE TARJETAS\n-----------"
echo "Solicitando archivos a los nodos..."
./bash_scripts/recoleccion.sh $broker $usr $pass $nro_medicion


#--------------------------------------------------
echo -e "\nPROCESAMIENTO\n-------------"
echo "(pendiente)"
# procesar mediciones (dar formato, corregir errores, comprimir)
#  procesar_mediciones.py


#--------------------------------------------------
echo -e "\nACTUALIZACIÓN\n-------------"
echo "(pendiente)"
# Subir archivos a la nube (por sftp)
#  ./subir_datos

