cluster= require 'cluster'
os= require 'os'

fs= require 'fs'
Log= require 'log'

cfg= require('./package.json').config
log= new Log 'main', fs.createWriteStream cfg.logfile

###

Инициализация кластера

Запускает воркеры по количеству процессоров.

###
if cluster.isMaster
    nWorkers= (do os.cpus).length
    for i in [1..nWorkers]
        worker= do cluster.fork

###

Инициализация воркера

###
if cluster.isWorker

    domain= require 'domain'
    d= do domain.create

    d.run ->
        App= require './node/index'
        app= App cfg, log
        app.listen cfg.default.port, ->
            log.info "apiserver listening on #{cfg.default.port}, worker #{cluster.worker.id}"
