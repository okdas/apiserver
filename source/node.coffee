cluster= require 'cluster'
os= require 'os'

http= require 'http'

io= require 'socket.io'
ioStore= require 'socket.io/lib/stores/redis'

fs= require 'fs'
Log= require 'log'

cfg= require('./package.json').config
log= new Log 'main', fs.createWriteStream cfg.logfile

###

Инициализация кластера

Запускает воркеры по количеству процессоров.

###
if cluster.isMaster
    require('pid')(cfg.pidfile)

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
        app= app cfg, log

        srv= http.createServer app
        app.set 'io', io= io.listen srv

        io.set 'store', new ioStore
            redisClient: app.get 'redis'
            redisPub: app.get 'pub'
            redisSub: app.get 'sub'

        srv.listen cfg.default.port, ->
            log.info "apiserver listening on #{cfg.default.port}, worker #{cluster.worker.id}"
