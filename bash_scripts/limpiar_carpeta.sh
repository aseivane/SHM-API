#!/bin/bash

url = $1

echo "Eliminando archivos"
rmdir -rf "./$url/*"