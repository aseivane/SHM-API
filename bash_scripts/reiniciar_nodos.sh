#!/bin/bash

echo "Reiniciando todos los nodos"
mosquitto_pub -h 192.168.0.10 -t control/reiniciar -u usuario -P usuariopassword -m "0" 
