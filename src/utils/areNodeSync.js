
module.exports = areNodeSync
const exec = require('./src/utils/exect_pid')
const csvtojson = require("csvtojson/v2");

const  areNodeSync = async ({ ip_mqtt_broker, usuario_mqtt, pass_mqtt}) => {
    try {
        const response = await exec('sh /app/bash_scripts/generacion_tabla_nodos.sh ' + ip_mqtt_broker + ' ' + usuario_mqtt + ' ' + pass_mqtt)
         if(!response.stderr) {
            let result = []
            try { 
                const csvFilePath='./public/datos/estado/tabla_nodos_inicio.csv'
                await csvtojson().fromFile(csvFilePath)
                                    .then((jsonObj)=>{
                                        result = jsonObj
                                    })
                result.find(node  => node.sync !== 'sincronizado')
                console.log('result sync', result)
                return !result
                } catch (e) {
                    return false
                }
         }

    } catch (e) {
        return false
    }
}
