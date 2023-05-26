#!/bin/sh
# Con openwrt debemos cambiar lo anterior por #!/bin/sh

nro_medicion=1  # numero de medicion

duracion_m=1 # duracion de la medicion (minutos)

tout_recoleccion_m=2 # (minutos). Tiempo maximo de espera para recibir los archivos de todos los nodos 

# script princial
./principal.sh "$duracion_m" "$nro_medicion" "$tout_recoleccion_m" 

# EJEMPLO
# ./principal.sh "[duracion]" "[numero de medicion]" 

#***************************************************************************
# OBSERVACIONES:
# - nro_medicion: es el numero de medicion (por ahora arbitrario)
# - duracion_s: es lo que dura la medicion (en segundos)
# - Es conveniente que los nodos no transmitan apenas termien de medir, sino que esperen unos segundos (supongamos 5 s)
# - EL test inicia las mediciones luego de esperar 20 segundos (ventana de tiempo para identificar nodos)
# - los archivos y carpetas se generan automaticamente
# - IMPORTANTE: wget -r -e robots=off $ip_nodo -P $directorio_destino (pobar si funciona esla linea con un directirio elegido)
#                si no funciona, modificar archivo: recoleccion.sh, linea 45. 
# ***************************************************************************
# ESTRUCTURA DE DIRECTORIOS (las que no tienen extension son carpetas)
# gateway
#	test.sh
#	principal.sh
#	nodos_inicio.sh
#	nodos_fin.sh
#	recoleccion.sh
#	medicion_001
#		mensajes_mqtt.log
#		tabla_nodos_inico.csv
#		tabla_nodos_fin.csv
#		datos_001
#			nodo_xxxxxxxxxxx1
#			nodo_xxxxxxxxxxx2
#			...
# 			nodo_xxxxxxxxxxxN
#				xxxxxx1.DAT
#				xxxxxx2.DAT
#				...
#				xxxxxxL.DAT
#
# **************************************************************************
