express= require 'express'
extend= require 'extend'


###
Приложение
###
app= module.exports= do express


###
Конфиг приложения
###
cfg= require './config.json'

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