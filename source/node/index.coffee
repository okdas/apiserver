express= require 'express'
extend= require 'extend'


###
Возвращает настроенный экзмепляр приложения.
###
module.exports= (cfg, log, done) ->

    ###
    Экземпляр приложения
    ###
    app= do express

    app.use do express.compress


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



    passport= require 'passport'

    passport.serializeUser (user, done) ->
        done null, user

    passport.deserializeUser (id, done) ->
        done null, id


    ###
    Сессии пользователей приложения
    ###
    app.configure ->
        app.use do express.cookieParser

        #MariaStore= require('connect-mysql-session')(express)
        #handler= express.session
        #    secret: 'apiserver'
        #    store: new MariaStore app.db, 'users_session'
        RedisStore= require('connect-redis')(express)
        handler= express.session
            secret: 'apiserver'
            store: new RedisStore
        app.use '/management', handler
        app.use '/api', handler

        handler= do passport.initialize
        app.use '/management', handler
        app.use '/api', handler

        handler= do passport.session
        app.use '/management', handler
        app.use '/api', handler


    app.get '/management/', (req, res, next) ->
        return do next if do req.isUnauthenticated
        return res.redirect '/management/project/'

    app.get '/management/project/', (req, res, next) ->
        return do next if do req.isAuthenticated
        return res.redirect '/management/'

    app.get '/management/engine/', (req, res, next) ->
        return do next if do req.isAuthenticated
        return res.redirect '/management/'


    ###
    Прослойки приложения
    ###
    app.configure ->

        # Публичные файлы
        app.use express.static "#{__dirname}/views/public/templates"
        app.use express.static "#{__dirname}/views/public"

        app.use do express.bodyParser


    ###
    База данных приложения
    ###
    maria= require 'mysql'

    app.configure ->
        config= app.get 'config'

        app.db= maria.createPool config.db

        app.use (req, res, next) ->
            req.db= app.db
            return do next


    ###
    Обработчики маршрутов
    ###
    handlers= require './handlers'
    handlers app
