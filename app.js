/* Tutoriales
https://www.youtube.com/watch?v=EuZnr5NZWso

https://www.youtube.com/watch?v=pk5WNnTzYyw

https://www.youtube.com/watch?v=_8HdvDqMVUI


Ejecucion de comando bash: https://stackoverflow.com/questions/44647778/how-to-run-shell-script-file-using-nodejs

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

app.post('/login',function(req,res){
var user_name = req.body.user;
var password = req.body.password;
console.log("From Client POST request: User name = "+user_name+" and password is "+password);
shell.exec('./prueba.sh')
res.end("yes");
});


app.post('/consulta',function(req,res){
console.log("Consulta de estado enviada");
shell.exec('./generacion_tabla_nodos.sh')
res.end("yes");
});


app.listen(3000,function(){
console.log("Servidor WEB iniciado en el puerto 3000");
})



/*
app.post('/test', function (req, res) {
    console.log('works');
});
*/
