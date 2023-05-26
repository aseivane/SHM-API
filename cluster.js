const os = require('os');
const cluster = require('cluster');
const coresNr = os.cpus().length;
const numCPUs = coresNr || 1;
const workers= {};
if (!cluster.isMaster) {
    void import('./app.js');
} else {
    console.log(`Starting server`);
    console.log(`Number of processes per instance: ${numCPUs}`);
    for (let i = 0; i < numCPUs; i++) {
        const worker = cluster.fork();
        workers[worker.id] = worker;
    }
    cluster.on('exit', (worker, code, signal) => {
        console.log(`worker ${worker.process.pid} died... creating a new worker`);
        const newWorker = cluster.fork();
        workers[newWorker.id] = newWorker;
    });
}