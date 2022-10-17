clear all
close all

% Nombre del archivo a abrir
filename = "../mediciones/medicion_003/datos_003/nodo_84d8e28798/3-0.DAT";
long_encabezado = 23;


fd = fopen(filename);
data_archivo = fread(fd);
enc = textscan (fd, "%s");
fclose(fd);
bytes_leidos = 14;  %Cantidad de bytes para cada muestra. Cada muestra incluye las tres aceleraciones, velocidades angulares y la temperatura.


data = data_archivo (long_encabezado:length(data_archivo));  % Para sacarle el encabezado a los datos
%data = data_archivo;

% Los siguientes valores dependen de la sensibilidad utilizada
Escala_aceleracion = 16384;
Escala_giroscopo = 131; 

N = ceil(length(data)/bytes_leidos); % numero de muestras tomadas
N = N-2

ax = zeros(1,N);
ay = zeros(1,N);
az = zeros(1,N);
temp = zeros(1,N);
gx = zeros(1,N);
gy = zeros(1,N);
gz = zeros(1,N);

for j=1:N

s=(j-1)*bytes_leidos;

ACCEL_XOUT_H = data(s+1);
ACCEL_XOUT_L = data(s+2);
ACCEL_YOUT_H = data(s+3);
ACCEL_YOUT_L = data(s+4);
ACCEL_ZOUT_H = data(s+5);
ACCEL_ZOUT_L = data(s+6);

TEMP_OUT_H = data(s+7);
TEMP_OUT_L = data(s+8);

GYRO_XOUT_H = data(s+9);
GYRO_XOUT_L = data(s+10);
GYRO_YOUT_H = data(s+11);
GYRO_YOUT_L = data(s+12);
GYRO_ZOUT_H = data(s+13);
GYRO_ZOUT_L = data(s+14);


ax(j) = typecast (uint8 ([ACCEL_XOUT_L ACCEL_XOUT_H]), 'int16' );
ay(j) = typecast (uint8 ([ACCEL_YOUT_L ACCEL_YOUT_H]), 'int16' );
az(j) = typecast (uint8 ([ACCEL_ZOUT_L ACCEL_ZOUT_H]), 'int16' );

temp(j) = (typecast (uint8 ([TEMP_OUT_L TEMP_OUT_H]), 'int16' ) /340) + 36.53;
%temp(j) = typecast (uint8 ([TEMP_OUT_L TEMP_OUT_H]), 'int16' );


gx(j) = typecast (uint8 ([GYRO_XOUT_L GYRO_XOUT_H]), 'int16' );
gy(j) = typecast (uint8 ([GYRO_YOUT_L GYRO_YOUT_H]), 'int16' );
gz(j) = typecast (uint8 ([GYRO_ZOUT_L GYRO_ZOUT_H]), 'int16' );


%Cambio de escala

ax(j) = ax(j)/Escala_aceleracion;
ay(j) = ay(j)/Escala_aceleracion;
az(j) = az(j)/Escala_aceleracion;

%temp(j) = (temp(j)/340) + 36.53;

gx(j) = gx(j)/Escala_giroscopo;
gy(j) = gy(j)/Escala_giroscopo;
gz(j) = gz(j)/Escala_giroscopo;


end
hold on
plot(ax,'b')
plot(ay,'r')
plot(az,'k')
legend( 'Eje X', 'Eje Y', 'Eje Z', 'location', 'eastoutside' );
xlabel ("Tiempo");
ylabel ("Aceleración (g)");
title('Aceleración')
hold off

figure
plot(temp)
xlabel ("Tiempo");
ylabel ("Temperatura (ºC)");
title('Temperatura')

figure
hold on
plot(gx,'b')
plot(gy,'r')
plot(gz,'k')
legend( 'Eje X', 'Eje Y', 'Eje Z', 'location', 'eastoutside');
xlabel ("Tiempo");
ylabel ("grados/seg");
title('Giroscopo')
hold off
