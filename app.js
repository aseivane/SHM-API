/* Tutoriales
https://www.youtube.com/watch?v=EuZnr5NZWso

https://www.youtube.com/watch?v=pk5WNnTzYyw

https://www.youtube.com/watch?v=_8HdvDqMVUI


Ejecucion de comando bash: https://stackoverflow.com/questions/44647778/how-to-run-shell-script-file-using-nodejs

Leer formularios de la página html: https://medium.com/swlh/read-html-form-data-using-get-and-post-method-in-node-js-8d2c7880adbf
                                    https://developer.mozilla.org/en-US/docs/Learn/Server-side/Express_Nodejs/forms
*/


var express = require("express");
var bodyParser = require("body-parser");
var app = express();
const shell = require('shelljs')


app.use(bodyParser.urlencoded({ extended: false }));

app.use(express.static('public'));

app.get('/',function(req,res){
res.sendfile("index.html");
});

/*
app.post('/login',function(req,res){
var user_name = req.body.user;
var password = req.body.password;
console.log("From Client POST request: User name = "+user_name+" and password is "+password);
shell.exec('./prueba.sh')
res.end("yes");
});
*/

app.post('/consulta',function(req,res){
    console.log("Consulta de estado enviada");
    shell.exec('./generacion_tabla_nodos.sh')
    res.end("yes");
});

app.post('/form_inicio',function(req,res){
    console.log("Formulario completado:");

  //  console.log("Datos Formulario: " + req.body);


    console.log("Epoch inicio: " + req.body.eposh_inicio);
    console.log("Duración del muestreo (minutos): " + req.body.duracion_muestreo);
    console.log("Numero de identificación del muestreo: "+ req.body.nro_muestreo);
    console.log("Muestreo sincronizado: " + req.body.sync);
 

    
    if (req.body.sync == "SI"){
        console.log("Muestreo SINCRONIZADO");
    }
    else if(req.body.sync == "NO"){
        console.log("Muestreo NO SINCRONIZADO");
    }
    
    shell.exec('mosquitto_pub -h 192.168.0.10 -t nodo/error -u usuario -P usuariopassword -m ' + req.body.eposh_inicio +' ')

    
    //console.log("Sin"+ req.body.eposh_inicio);

    //shell.exec('./generacion_tabla_nodos.sh')
    res.send("Muestreo iniciado");
//    res.end("yes");
});


app.listen(3000,function(){
console.log("Servidor WEB iniciado en el puerto 3000");
})



/*
app.post('/test', function (req, res) {
    console.log('works');
});
*/
