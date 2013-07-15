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
        node= require './node/index'