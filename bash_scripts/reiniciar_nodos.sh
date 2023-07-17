#!/bin/sh

ip_mqtt_broker=$1
usuario_mqtt=$2
pass_mqtt=$3

echo "Reiniciando todos los nodos"
mosquitto_pub -h $ip_mqtt_broker -t "control/reiniciar" -u $usuario_mqtt -P $pass_mqtt -m "0" 
