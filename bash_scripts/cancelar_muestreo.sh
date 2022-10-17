#!/bin/bash

echo "Cancelando muestreo en curso"
mosquitto_pub -h 192.168.0.10 -t control/cancelar_muestreo -u usuario -P usuariopassword -m "0 cancelar" 