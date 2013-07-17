cluster= require 'cluster'
os= require 'os'

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
        app= require './node/index'
        cfg= app.get 'config'
        app.listen cfg.port, ->
            console.log "apiserver listening on #{cfg.port}, worker #{cluster.worker.id}"

