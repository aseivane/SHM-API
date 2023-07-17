nro_medicion=$1

directorio="/app/public/datos/mediciones/medicion_$nro_medicion"


directorio_datos=$directorio"/datos_$nro_medicion"
echo "directorio_datos $directorio_datos"
python3 /app/python/leerDatos.py --images $directorio_datos