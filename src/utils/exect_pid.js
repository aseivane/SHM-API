const cp = require('child_process')
const process = require('process')
module.exports = Exec_pid

function Exec_pid (command, processData={}, options = { log: false, cwd: process.cwd() }) {

  const newPromise = new Promise((done, failed) => {
   const child = cp.exec(command, { ...options }, (err, stdout, stderr) => {
    console.log(stdout, stderr)
      if (err) {
        err.stdout = stdout
        err.stderr = stderr
        failed(err)
        return
      }
      done({ stdout, stderr })
    })
    console.log("Running command: ", command)
    //console.log(child.pid)
    processData.pid= child.pid 
  })

  return newPromise

}
