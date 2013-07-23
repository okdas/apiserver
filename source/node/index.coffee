express= require 'express'
extend= require 'extend'
async= require 'async'

###
Возвращает настроенный экзмепляр приложения.
###
module.exports= (cfg, log, done) ->



    ###
    Экземпляр приложения
    ###
    app= module.exports= do express



    ###
    Конфиг приложения
    ###
    app.configure ->
        config= cfg.default or {}
        app.set 'config', config

    ###
    Конфиг приложения для разработчиков
    ###
    app.configure 'development', ->
        config= app.get 'config'
        extend true, config, cfg.development or {}

    ###
    Конфиг приложения для производства
    ###
    app.configure 'production', ->
        config= app.get 'config'
        extend true, config, cfg.production or {}



    ###
    Логгер приложения
    ###
    app.configure ->
        app.set 'log', log

    ###
    Логгер приложения для разработчиков
    ###
    app.configure 'development', ->
        app.use express.logger 'dev'

    ###
    Логгер приложения для производства
    ###
    app.configure 'production', ->
        app.use (req, res, next) ->
            log.info "#{req.ip} - - #{req.method} #{req.url} \"#{req.headers.referer}\"  \"#{req.headers['user-agent']}\""
            do next



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



    Redis= require 'redis'
    redis= do Redis.createClient

    app.use (req, res, next) ->

        req.redis= redis
        do next

    ###
    База данных приложения
    ###
    Db= require 'orm'

    app.configure ->
        config= app.get 'config'

        app.use (req, res, next) ->

            Db.connect config.db, (err, db) ->
                if err
                    # ошибка при подключении к базе данных
                    return next err

                req.db= db
                req.models= db.models

                # подключить модели
                db.load 'models', (err) ->
                    return do next



    passport= require 'passport'

    passport.serializeUser (user, done) ->
        done null, user.username

    passport.deserializeUser (username, done) ->
        done null,
            username: username


    ###
    Сессии пользователей приложения
    ###
    app.configure ->
        RedisStore= require('connect-redis')(express)

        # Сессия
        app.use express.session
            secret: 'apiserver'
            store: new RedisStore
                prefix: 'sessions'

        app.use do passport.initialize

        app.use do passport.session



    ###
    Обработчики маршрутов
    ###
    handlers= require './handlers'
    handlers app

