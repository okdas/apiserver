express= require 'express'
extend= require 'extend'
fs= require 'fs'

###
Приложение
###
app= module.exports= do express


###
Конфиг приложения
###
cfg= require('../package.json').config

app.configure ->
    config= cfg.default or {}
    app.set 'config', config

app.configure 'development', ->
    config= app.get 'config'
    extend true, config, cfg.development or {}

app.configure 'production', ->
    config= app.get 'config'
    extend true, config, cfg.production or {}


###
База данных приложения
###
Db= require './db'

app.configure ->
    config= app.get 'config'
    app.set 'db', Db config.db


###
Предметная область приложения
###
Domain= require './domain'

app.configure ->
    db= app.get 'db'
    app.set 'domain', Domain db





###
Логирование
###
Logger= require 'log'

logStream = fs.createWriteStream cfg.logfile
logger= new Logger 'main', logStream
logger.info "Server started on #{app.get('config').port}"

app.use (req,res,next) ->
    logger.info "#{req.ip} - - #{req.method} #{req.url} \"#{req.headers.referer}\"  \"#{req.headers['user-agent']}\""
    next()



###
Лог запросов приложения
###
app.configure ->
    app.use express.logger 'dev'

###
Прослойки приложения
###
app.configure ->

    app.use do express.compress

    # Публичные файлы
    app.use express.static __dirname+'/views/assets'

    app.use do express.bodyParser

    app.use do express.cookieParser

    app.use do express.methodOverride

    # Шаблоны вида
    app.set 'views', __dirname + '/views/templates'
    app.set 'view engine', 'jade'

    app.set 'logger', logger



Store= require './modules/Store'
store= new Store app.get 'db'



###
Интерфейс управления предметами магазина.
###
app.get '/store/items', (req, res) ->
    res.render 'Store/items'

###
Отдает список предметов магазина.
###
app.get '/api/v1/store/items', (req, res) ->
    store.Item.query (err, items) ->
        if not err
            res.json 200, items
        else
            res.json 500, err

###
Добавляет переданный предмет в магазин.
###
app.post '/api/v1/store/items', (req, res) ->
    store.Item.create req.body, (err, item) ->
        if not err
            res.json 201, item
        else
            res.json 500, err

###
Изменяет указанный предмет в магазине.
###
app.patch '/api/v1/store/items/:itemId', (req, res) ->
    id= req.param 'itemId'
    store.Item.update id, req.body, (err, item) ->
        if not err
            res.json 200, item
        else
            res.json 500, err

###
Удаляет указанный предмет из магазина.
###
app.delete '/api/v1/store/items/:itemId', (req, res) ->
    id= req.param 'itemId'
    store.Item.delete id, (err, item) ->
        if not err
            res.json 200, item
        else
            res.json 500, err



###
Интерфейс управления пакетами магазина.
###
app.get '/store/packages', (req, res) ->
    res.render 'Store/packages'

###
Отдает список пакетов магазина.
###
app.get '/api/v1/store/packages', (req, res) ->
    store.Package.query (err, pkgs) ->
        if not err
            res.json 200, pkgs
        else
            res.json 500, err

###
Добавляет переданный пакет в магазин.
###
app.post '/api/v1/store/packages', (req, res) ->
    store.Package.create req.body, (err, pkg) ->
        if not err
            res.json 201, pkg
        else
            res.json 500, err



