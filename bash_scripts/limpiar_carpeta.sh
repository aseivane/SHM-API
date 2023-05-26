#!/bin/sh

url = $1

echo "Eliminando archivos"
rmdir -rf "./$url/*"