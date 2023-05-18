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
var moment = require('moment')
var ip_mqtt_broker = '192.168.1.230';
var usuario_mqtt = 'usuario';
var pass_mqtt = 'usuariopassword';

 
var app = express();
const shell = require('shelljs')
const { spawn } = require("child_process"); // Para ejecutar scripts en un proceso nuevo
const exec = require('await-exec')

app.use(bodyParser.urlencoded({ extended: false }));

app.use(express.json())
app.use(express.static('public'));

app.get('/',function(req,res){

//    res.render('index.pug', { name: 'John Doe', age: 21 });

  //  res.render(__dirname + "index.html", {name:ip_mqtt_broker});

res.sendfile("index.html");
//res.sendfile("./");
});

app.post('/form_config_sistema',function(req,res){
    console.log("Formulario completado:");
    console.log("IP del Broker: " + req.body.ip_mqtt);
    console.log("Usuario: " + req.body.usr_mqtt);
    console.log("Passwd: "+ req.body.pass_mqtt);
    
    ip_mqtt_broker = req.body.ip_mqtt;
    usuario_mqtt = req.body.usr_mqtt;
    pass_mqtt = req.body.pass_mqtt;
   
    return res.status(200).json({test: 'test'});

});

app.post('/actualizar_estados', async function(req,res){
    console.log("Consulta de estado enviada");
   let response 

    try {
        response = await exec('./bash_scripts/generacion_tabla_nodos.sh ' + ip_mqtt_broker + ' ' + usuario_mqtt + ' ' + pass_mqtt)
      } catch (e) {
        console.log(e)

        return res.status(422).json(e)
      }
         
      return response.stderr ? res.status(422).json({errorMessage: 'error'}) : res.status(200).json({status: 'ok'});
});

app.post('/form_inicio',async function(req,res){
    console.log("Formulario completado:");

    console.log("Epoch inicio: " + req.body.epoch_inicio);
    console.log("Duración del muestreo (minutos): " + req.body.duracion_muestreo);
    console.log("Numero de identificación del muestreo: "+ req.body.nro_muestreo);
    console.log("Muestreo sincronizado: " + req.body.sync);
    
    let response

    if (req.body.sync == "SI"){
        console.log("Muestreo SINCRONIZADO");
       // const initTime = moment().add(req.body.epoch_inicio, 'minutes').format('x')
       const initTime = moment().add(req.body.epoch_inicio, 'm').unix()
       try {
        response = await exec('./bash_scripts/principal_sync.sh' + ' ' + ip_mqtt_broker + ' ' + usuario_mqtt + ' ' + pass_mqtt + ' ' + req.body.duracion_muestreo + ' ' + req.body.nro_muestreo + ' '+ initTime +' ');
        } catch (e) {
        console.log(e)
        return res.status(422).json({error: e});

      }
    }
    else if(req.body.sync == "NO"){
        console.log("Muestreo NO SINCRONIZADO");

        try {
            response = await exec('./bash_scripts/principal_async.sh ' + ' '  + ip_mqtt_broker + ' ' + usuario_mqtt + ' ' + pass_mqtt + ' '  + req.body.duracion_muestreo + ' ' + req.body.nro_muestreo + ' ');
        } catch (e) {
            console.log(e)
            return res.status(422).json({error: e});

        }
    }   
     return response.stderr ? res.status(422).json({errorMessage: 'error'}) : res.status(200).json({test: 'test medicion'});

});


app.post('/cancelar_muestreo',async function(req,res){
    console.log("Boton apretado: Cancelar muestreo");
    let response
    try {
        response = await exec('./bash_scripts/cancelar_muestreo.sh ' + ip_mqtt_broker + ' ' + usuario_mqtt + ' ' + pass_mqtt);
    } catch (e) {
        console.log(e)
        return res.status(422).json({error: e});


    }
    return response.stderr ? res.status(422).json({errorMessage: 'error'}) : res.status(200).json({status: 'ok'});

});


app.post('/reiniciar_nodos',async function(req,res){
    console.log("Boton apretado: Reiniciar Nodos");
    let response
    try {
        response = await exec('./bash_scripts/reiniciar_nodos.sh' + ip_mqtt_broker + ' ' + usuario_mqtt + ' ' + pass_mqtt);
    } catch (e) {
        console.log(e)
        return res.status(422).json({error: e});
    }
    return response.stderr ? res.status(422).json({errorMessage: 'error'}) : res.status(200).json({status: 'ok'});

});


app.post('/borrar_SD',async function(req,res){
    console.log("Boton apretado: Borrar los archivos de los nodos");
    let response
    try {
        response = await exec('./bash_scripts/borrar_SD.sh '+ ip_mqtt_broker + ' ' + usuario_mqtt + ' ' + pass_mqtt );
    } catch (e) {
        console.log(e)
        return res.status(422).json({error: e});

    }
    return response.stderr ? res.status(422).json({errorMessage: 'error'}) : res.status(200).json({status: 'ok'});

});

app.post('/Descargar_datos',function(req,res){
    console.log("Boton apretado: Descargar datos");
    zipper.sync.zip("./mediciones/").compress().save("mediciones.zip");

    res.download('mediciones.zip');   
});



// Serve URLs like /ftp/thing as public/ftp/thing
// The express.static serves the file contents
// The serveIndex is this module serving the directory
app.use('/mediciones', express.static('mediciones'), serveIndex('mediciones', {'icons': true}))

app.listen(3001,function(){
console.log("Servidor WEB iniciado en el puerto 3001");
})

