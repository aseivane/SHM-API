#!/bin/bash

ip_mqtt_broker=$1
usuario_mqtt=$2
pass_mqtt=$3

echo "Cancelando muestreo en curso"
mosquitto_pub -h $ip_mqtt_broker -t control/cancelar_muestreo -u $usuario_mqtt -P $pass_mqtt -m "0 cancelar" 
