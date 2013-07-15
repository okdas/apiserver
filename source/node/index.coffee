express= require 'express'
extend= require 'extend'


###
Приложение
###
app= module.exports= do express


###
Конфигурация
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
Конфигурация приложения
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