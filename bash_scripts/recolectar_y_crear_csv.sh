broker=$1
port="1883"
usr=$2
pass=$3
duracion_m=$4
nro_medicion=$5

directorio="/app/public/datos/mediciones/medicion_$nro_medicion"

csv_fin="/app/public/datos/mediciones/medicion_$nro_medicion/tabla_nodos_fin.csv"  


echo -e "\nRECOLECCIÓN Y BORRADO DE TARJETAS\n-----------"
echo "Solicitando archivos a los nodos..."
cant_archivos=$duracion_m #un archivo por minuto
./bash_scripts/recoleccion.sh $broker $usr $pass $nro_medicion $cant_archivos


#--------------------------------------------------
echo -e "\nPROCESAMIENTO\n-------------"
# procesar mediciones (dar formato, corregir errores, comprimir)
#agregar headers aca para que no rompa el resto de los scripts
sed -i '1s/^/id,ip,alias,time\n/' $csv_fin

directorio_datos=$directorio"/datos_$nro_medicion"
echo "Generando csv en $directorio_datos"
python3 /app/python/leerDatos.py --images $directorio_datos