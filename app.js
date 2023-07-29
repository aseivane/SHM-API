/* Tutoriales
1) Para usar este programa se necesita instalar los siguientes programas

    sudo apt install nodejs npm mosquitto

2) Despues pararse en el directorio de este archivo y ejecutar:
    npm install

3) Hacer ejecutables los scripts en la carpeta bash-scripts
    chmod +x *.*
    
    

https://www.youtube.com/watch?v=EuZnr5NZWso

https://www.youtube.com/watch?v=pk5WNnTzYyw

https://www.youtube.com/watch?v=_8HdvDqMVUI


Ejecucion de comando bash: https://stackoverflow.com/questions/44647778/how-to-run-shell-script-file-using-nodejs
                            https://stackabuse.com/executing-shell-commands-with-node-js/

Leer formularios de la página html: https://medium.com/swlh/read-html-form-data-using-get-and-post-method-in-node-js-8d2c7880adbf
                                    https://developer.mozilla.org/en-US/docs/Learn/Server-side/Express_Nodejs/forms


Mostrar los archivos: https://www.digitalocean.com/community/tutorials/use-expressjs-to-deliver-html-files  
Descargar los archivos: https://iq.opengenus.org/download-server-files-in-node-js/                                  
Comprimir Directorio: https://github.com/Mostafa-Samir/zip-local
Borrar un archivo: https://www.w3schools.com/nodejs/nodejs_filesystem.asp

*/

var express = require("express");
var bodyParser = require("body-parser");
var serveIndex = require('serve-index');
var zipper = require('zip-local');
var fs = require('fs');

var ip_mqtt_broker = 'mosquitto';
var usuario_mqtt = 'usuario';
var pass_mqtt = 'usuariopassword';
const csvtojson = require("csvtojson/v2");
const moment = require('moment')

const processData_initMedicion = {}
let lastMeasureName =  ''
 
var app = express();
const exec = require('./src/utils/exect_pid')
const terminate = require('terminate/promise')

app.use(bodyParser.urlencoded({ extended: false }));

app.use(express.json())

const cors = require('cors');
const corsOptions ={
    origin:'*', 
    credentials:false,            //access-control-allow-credentials:true
    optionSuccessStatus:200,
    // methods: ['GET','POST','DELETE','UPDATE','PUT','PATCH']

}
app.use(cors(corsOptions));

app.post('/form_config_sistema',function(req,res){
    console.log("Formulario completado:");
    console.log("IP del Broker: " + req.body.ip_mqtt);
    console.log("Usuario: " + req.body.usr_mqtt);
    console.log("Passwd: "+ req.body.pass_mqtt);
    
    ip_mqtt_broker = req.body.ip_mqtt;
    usuario_mqtt = req.body.usr_mqtt;
    pass_mqtt = req.body.pass_mqtt;
   
    return res.status(200).json({status: 'ok'});

});

app.get('/actualizar_estados', async function(req,res){
    console.log("Consulta de estado enviada");
   let response = {}

    try {
        response = await exec('sh /app/bash_scripts/generacion_tabla_nodos.sh ' + ip_mqtt_broker + ' ' + usuario_mqtt + ' ' + pass_mqtt)
      } catch (e) {
        return res.status(422).json(e)
      }

    if(response.stderr){
        return res.status(422).json({errorMessage: response.stderr})
    }
    
    let result = []

    try {
    const csvFilePath='./public/datos/estado/tabla_nodos_inicio.csv'
    await csvtojson().fromFile(csvFilePath)
                        .then((jsonObj)=>{
                            result = jsonObj
                        })
    } catch (e) {
        return res.status(422).json({error: e})
    }
         
      res.status(200).json({status: 'ok', url: 'http://localhost:3001/datos/estado/tabla_nodos_inicio.csv', data: result});
});

app.post('/check_measure_status',async function(req,res){

    let result = []

    try {

        const dir = '/app/public/datos/mediciones/medicion_' + req.body.nro_muestreo
        if (fs.existsSync(dir) && !!req.body.nro_muestreo) {
            return res.status(200).json({status: 'repeatedMeasure',error:  'El numero de medición ya fue utilizado'})    
        }  

        const response2 = await exec('sh /app/bash_scripts/generacion_tabla_nodos.sh ' + ip_mqtt_broker + ' ' + usuario_mqtt + ' ' + pass_mqtt)
        if(!response2.stderr) {
           try { 
               const csvFilePath='./public/datos/estado/tabla_nodos_inicio.csv'
               await csvtojson().fromFile(csvFilePath)
                                   .then((jsonObj)=>{
                                       result = jsonObj
                                   })
                const measureInProgress = result.find(node  => node.state === 'esperando_hora_inicio' || node.state === 'muestreando')

                if (measureInProgress){
                    return res.status(200).json({status: 'measureInProgress', error:  'Hay una medición en curso. No se puede iniciar otra.', data: result})    
                }

                if(req.body.sync) {
                    const notSyncItems = result.find(node  => node.sync !== 'sincronizado')

                    if(notSyncItems){
                        return res.status(200).json({status: 'nodesNotSync',error:  'Los nodos no estan sincronizados'})    
                    }
                }

                res.status(200).json({status: 'ok'});

             
               } catch (e) {
                return res.status(422).json({error:  'Error al verificaar estado de nodos. Intente mas tarde'})    
               }
        }
    
    } catch (e) {
        return res.status(422).json({error:  'Error al verificaar estado de nodos. Intente mas tarde'})
    }
    
});

app.post('/init_measure',async function(req,res){
    req.setTimeout(req.body.timeout);
    console.log('Timeout: ' + req.body.timeout);
    console.log("Formulario completado:");

    console.log("Epoch inicio: " + req.body.epoch_inicio);
    console.log("Duración del muestreo (minutos): " + req.body.duracion_muestreo);
    console.log("Numero de identificación del muestreo: "+ req.body.nro_muestreo);
    console.log("Muestreo sincronizado: " + req.body.sync);

    const { epoch_inicio, duracion_muestreo, nro_muestreo, sync } = req.body || {}
    let response
    lastMeasureName = nro_muestreo

    const epochUnix = moment().add(epoch_inicio, 'm').unix()

    if (sync){
        console.log("Muestreo SINCRONIZADO");
        
        try {
        response = await exec('sh /app/bash_scripts/iniciar_medicion_sync.sh' + ' ' + ip_mqtt_broker + ' ' + usuario_mqtt + ' ' + pass_mqtt + ' ' + duracion_muestreo + ' ' + nro_muestreo + ' ' + epochUnix +' ', processData_initMedicion);
        if(response.stderr) {
            return res.status(422).json({errorMessage: response.stderr}) 
        }

        if(req.body.comment) {
        const dir = '/app/public/datos/mediciones/medicion_' + nro_muestreo + '/comentarios.txt'

        fs.writeFileSync(dir, req.body.comment);
        }

        void exec('sh /app/bash_scripts/finalizar_medicion_sync.sh' + ' ' + ip_mqtt_broker + ' ' + usuario_mqtt + ' ' + pass_mqtt + ' ' + duracion_muestreo + ' ' + nro_muestreo + ' ' + epochUnix +' ', processData_initMedicion).catch(error => {
           if( error.signal == 'SIGKILL') {
            const dir = '/app/public/datos/mediciones/medicion_' + lastMeasureName
            if (fs.existsSync(dir)) {
                fs.rmdirSync(dir, {recursive: true})
            }  
        }

        });
        return res.status(200).json({status: 'ok', message: 'Medicion iniciada'});
        } catch (e) {
        return res.status(422).json({error:  e.signal == 'SIGKILL' ? 'Medicion cancelada' : e});    
        }
    }

    console.log("Muestreo NO SINCRONIZADO");
    try {
        response = await exec('sh /app/bash_scripts/iniciar_medicion_async.sh ' + ' '  + ip_mqtt_broker + ' ' + usuario_mqtt + ' ' + pass_mqtt + ' '  + duracion_muestreo + ' ' + nro_muestreo + ' ', processData_initMedicion);
    
        if(response.stderr) {
            return res.status(422).json({errorMessage: response.stderr}) 
        }
        if(req.body.comment) {
            const dir = '/app/public/datos/mediciones/medicion_' + req.body.nro_muestreo + '/comentarios.txt'
    
            fs.writeFileSync(dir, req.body.comment);
        }
        void exec('sh /app/bash_scripts/finalizar_medicion_async.sh' + ' '  + ip_mqtt_broker + ' ' + usuario_mqtt + ' ' + pass_mqtt + ' '  + duracion_muestreo + ' ' + nro_muestreo + ' ', processData_initMedicion).catch(error => {
            if( error.signal == 'SIGKILL') {
                const dir = '/app/public/datos/mediciones/medicion_' + lastMeasureName
                if (fs.existsSync(dir)) {
                    fs.rmdirSync(dir, {recursive: true})
                }  
            }
 
         });
        return res.status(200).json({status: 'ok', message: 'Medicion iniciada'});
    } catch (e) {            
        return res.status(422).json({error:  e.signal == 'SIGKILL' ? 'Medicion cancelada' : e});

    }
});




app.post('/form_inicio',async function(req,res){
    req.setTimeout(req.body.timeout);
    console.log('Timeout: ' + req.body.timeout);
    console.log("Formulario completado:");

    console.log("Epoch inicio: " + req.body.epoch_inicio);
    console.log("Duración del muestreo (minutos): " + req.body.duracion_muestreo);
    console.log("Numero de identificación del muestreo: "+ req.body.nro_muestreo);
    console.log("Muestreo sincronizado: " + req.body.sync);

    const { epoch_inicio, duracion_muestreo, nro_muestreo, sync } = req.body || {}
    let response


    if (sync){
        console.log("Muestreo SINCRONIZADO");

        try {
        response = await exec('sh /app/bash_scripts/principal_sync.sh' + ' ' + ip_mqtt_broker + ' ' + usuario_mqtt + ' ' + pass_mqtt + ' ' + duracion_muestreo + ' ' + nro_muestreo + ' ' + epoch_inicio +' ', processData_initMedicion);
        } catch (e) {
        return res.status(422).json({error:  e.signal == 'SIGKILL' ? 'Medicion cancelada' : e});    
        }
    }
    else {
        console.log("Muestreo NO SINCRONIZADO");
        try {
            response = await exec('sh /app/bash_scripts/principal_async.sh ' + ' '  + ip_mqtt_broker + ' ' + usuario_mqtt + ' ' + pass_mqtt + ' '  + duracion_muestreo + ' ' + nro_muestreo + ' ', processData_initMedicion);
        } catch (e) {            
            return res.status(422).json({error:  e.signal == 'SIGKILL' ? 'Medicion cancelada' : e});

        }
    }   
     
    return response.stderr ? res.status(422).json({errorMessage: response.stderr}) : res.status(200).json({status: 'ok', message: 'Medicion finalizadas'});
});


app.post('/cancelar_muestreo',async function(req,res){
    console.log("Boton apretado: Cancelar muestreo");
    let response
    
    try {
        const pid = processData_initMedicion?.pid
        console.log(pid)
        response = await exec('sh /app/bash_scripts/cancelar_muestreo.sh ' + ip_mqtt_broker + ' ' + usuario_mqtt + ' ' + pass_mqtt + ' ' + pid);
        await terminate(pid)
    } catch (e) {
        return res.status(422).json({error: e});
    }
    return response.stderr ? res.status(422).json({errorMessage: response.stderr}) : res.status(200).json({status: 'ok', message: 'Medicion cancelada exitosamente'});

});


app.post('/reiniciar_nodos',async function(req,res){
    console.log("Boton apretado: Reiniciar Nodos");
    let response
    try {
        response = await exec('sh /app/bash_scripts/reiniciar_nodos.sh' + " " + ip_mqtt_broker + ' ' + usuario_mqtt + ' ' + pass_mqtt);
    } catch (e) {
        return res.status(422).json({error: {message: 'error al reiniciar nodos'}});
    }
    return response.stderr ? res.status(422).json({error: {message: 'error al reiniciar nodos'}}) : res.status(200).json({status: 'ok', message: 'Reinicio exitoso'});

});


app.post('/borrar_SD',async function(req,res){
    console.log("Boton apretado: Borrar los archivos de los nodos");
    let response
    try {
        response = await exec('sh /app/bash_scripts/borrar_SD.sh '+ ip_mqtt_broker + ' ' + usuario_mqtt + ' ' + pass_mqtt );
        res.status(200).json({status: 'ok', message: 'SD borrada exitosamente'});
    } catch (e) {
        return res.status(422).json({error: e});

    }
    return response.stderr ? res.status(422).json({errorMessage: response.stderrs}) : res.status(200).json({status: 'ok', message: 'SD card borrada'});

});

app.get('/download_files',function(req,res){
    console.log("Boton apretado: Descargar datos");
    zipper.sync.zip("./public/datos/mediciones/").compress().save("./public/datos/downloads/mediciones.zip");
     res.download('./public/datos/downloads/mediciones.zip');   
});

app.get('/download_image/:imgName',function(req,res){
    console.log(req.params.imgName)
    res.download('public/img/' + req.params.imgName);   
});

app.post('/erase_reading',async function(req,res){
    let exitoso = false

    try {


        const dir = '/app/public/datos/mediciones/medicion_' + req.body.nro_muestreo
        console.log(dir)
        if (fs.existsSync(dir)) {
            fs.rmSync(dir, {recursive: true})
            exitoso = true
        }  
        
    } catch (e) {
        return res.status(422).json({error: e});

    }
    return !exitoso ? res.status(422).json({error: {message: 'Medición no encontrada'}}) : res.status(200).json({status: 'ok', message:  'Medición borrada exitosamente' });
});

app.post('/erase_all_reading',async function(req,res){
    try {


        const dir = '/app/public/datos/mediciones/'
        if (fs.existsSync(dir)) {
            fs.rmdirSync(dir, {recursive: true})
            if (!fs.existsSync(dir)){
                fs.mkdirSync(dir);
            }
        }  
        
    } catch (e) {
        return res.status(422).json({error: e});

    }
    return  res.status(200).json({status: 'ok', message: 'Mediciones borradas exitosamente'});
});

app.post('/erase_images',async function(req,res){
    let response = {}
    try {
        response = await exec('sh /app/bash_scripts/limpiar_carpeta.sh ' + 'public/img');
    } catch (e) {
        return res.status(422).json({error: e});

    }
    return response.stderr ? res.status(422).json({errorMessage: response.stderrs}) : res.status(200).json({status: 'ok', message: 'Imagenes borradas'});
});

app.post('/reset_tabla_nodos',async function(req,res){
    let response = {}
    try {
        response = await exec('sh /app/bash_scripts/limpiar_carpeta.sh ' + 'public/datos/estado');
    } catch (e) {
        return res.status(422).json({error: e});

    }
    return response.stderr ? res.status(422).json({errorMessage: response.stderrs}) : res.status(200).json({status: 'ok', message: 'Tabla de nodos limpia'});
});


app.get('/graph_readings/:medName',async function(req,res){
    let response = {}
    let result = []
    let nodes = []

    try {

        const nodeNamesFile=`./public/datos/mediciones/medicion_${req.params.medName}/tabla_nodos_fin.csv`

        await csvtojson().fromFile(nodeNamesFile)
        .then((jsonObj)=>{
            nodes = jsonObj.map(item => item.id)
        })

        if(nodes?.length === 0){
            return res.status(422).json({error:{message: 'No se encontraron nodos para graficar'}})
        }

        for(let i = 0; i < nodes.length; i++){
            const nodeName = nodes[i]

            await csvtojson().fromFile(`./public/datos/mediciones/medicion_${req.params.medName}/datos_${req.params.medName}/nodo_${nodeName}/nodo_${nodeName}.csv`)
            .then((jsonObj)=>{
                const item = {name: nodeName, data: jsonObj}
                result.push(item)
            })    
        }
        
    } catch (e) {
        return res.status(422).json({error: {message: `Error leyendo datos para la medicion ${req.params.medName}`}})
    }

    return response.stderr ? res.status(422).json({error:{message: response.stderrs}}) : res.status(200).json({status: 'ok', data: result});
});

app.post('/create_csv',async function(req,res){
    let response
    try {
        response = await exec('sh /app/bash_scripts/create_csv.sh '+ ' ' + req.body.nro_muestreo );
    } catch (e) {
        return res.status(422).json({error: e});

    }
    return response.stderr ? res.status(422).json({error: {message: response.stderrs}}) : res.status(200).json({status: 'ok', message: 'Csv creados correctamente'});

});

app.post('/recolect_last_measure',async function(req,res){
    let response
    try {
        response = await exec('sh /app/bash_scripts/create_csv.sh '+ ' ' + req.body.nro_muestreo );
    } catch (e) {
        return res.status(422).json({error: e});

    }
    return response.stderr ? res.status(422).json({error: {message: response.stderrs}}) : res.status(200).json({status: 'ok', message: 'Csv creados correctamente'});

});



// Serve URLs like /ftp/thing as public/ftp/thing
// The express.static serves the file contents
// The serveIndex is this module serving the directory

app.use(express.static('public'), serveIndex('public', {'icons': true}));


app.listen(3001,function(){
console.log("Servidor WEB iniciado en el puerto 3001");
})

