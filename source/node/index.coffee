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



    ###
    База данных приложения
    ###
    Db= require 'orm'

    app.configure ->
        config= app.get 'config'

        Db.connect config.db, (err, db) ->
            app.set 'db', db

            User= require './models/User'

            Store= require './models/Store'



    passport= require 'passport'

    passport.serializeUser (user, done) ->
        done null, user.id

    passport.deserializeUser (id, done) ->
        done null,
            id: id

    crypto= require 'crypto'
    sha1= (string) ->
        hash= crypto.createHash 'sha1'
        hash.update string
        return hash.digest 'hex'



    ###
    Сессии пользователей приложения
    ###
    app.configure ->
        # Сессия
        app.use express.session
            secret: 'apiserver'

        app.use do passport.initialize

        app.use do passport.session



    ###

    Методы для аутентификации пользователей

    ###


    ###
    Отдает форму аутентификации.
    ###
    app.get '/login', (req, res) ->
        console.log req.session
        res.render 'Users/Login'


    ###
    Обрабатывает форму аутентификации.
    ###
    app.post '/login', (req, res, next) ->
        username= req.body.username
        password= sha1 req.body.password

        db= req.app.get 'db'

        # найти пользователя в базе данных
        db.models.User.find
            username: username
            password: password
        ,   (err, users) ->

                if err
                    # ошибка при поиске пользователя
                    return next err

                if not users.length
                    # пользователь не найден
                    return res.redirect '/login'

                # пользователь найден
                user= do users.shift
                req.login user, (err) ->

                    if err
                        # ошибка при аутентификации пользователя
                        return next err

                    # пользователь аутентифицирован
                    return res.redirect '/'


    ###
    Загружает данные аутентифицированного пользователя и его роли.
    ###
    loadUser= (req, res, next) ->

        if not req.user
            # пользователь не аутентифицирован
            return res.redirect '/login'

        db= req.app.get 'db'

        # загрузить пользователя из базы данных
        db.models.User.get req.user.id, (err, user) ->

            if err
                # ошибка при загрузке пользователя
                return next err

            # загрузить роли пользователя из базы данных
            user.getRoles (err, roles) ->
                if err
                    # ошибка при загрузке ролей пользователя
                    return next err

                # пользователь загружен
                req.user= user
                req.user.roles= roles

                return do next



    ###

    Методы API для работы с предметами магазина

    ###


    ###
    Отдает список предметов магазина.
    ###
    app.get '/api/v1/store/items', (req, res, next) ->
        db= req.app.get 'db'

        # загрузить предметы из базы данных
        db.models.Item.find (err, items) ->
            if err
                # ошибка при загрузке предмета
                return next err

            return res.json 200, items


    ###
    Добавляет переданный предмет в магазин.
    ###
    app.post '/api/v1/store/items', (req, res) ->
        item:
            title: req.body.title

        db= req.app.get 'db'

        # сохранить новый предмет в базе данных
        item= new db.models.Item item
        item.save (err) ->

            if err
                # ошибка при сохранении предмета
                return next err

            return res.json 201, item


    ###
    Изменяет указанный предмет в магазине.
    ###
    app.patch '/api/v1/store/items/:itemId', (req, res) ->
        id= req.param 'itemId'

        db= req.app.get 'db'

        # загрузить предмет из базы данных
        db.models.Item.get id, (err, item) ->

            if err
                # ошибка при загрузке предмета
                return next err

            # применить изменения
            if req.body.title
                item.title= req.body.title

            # сохранить предмет в базе данных
            item.save (err) ->

                if err
                    # ошибка при загрузке предмета
                    return next err

                return res.json 201, item


    ###
    Удаляет указанный предмет из магазина.
    ###
    app.delete '/api/v1/store/items/:itemId', (req, res) ->
        id= req.param 'itemId'

        db= req.app.get 'db'

        # загрузить предмет из базы данных
        db.models.Item.get id, (err, item) ->

            if err
                # ошибка при загрузке предмета
                return next err

            item.remove (err) ->

                if err
                    # ошибка при удалении предмета
                    return next err

                return res.json 200, item



    ###

    Методы API для работы с пакетами магазина

    ###


    ###
    Отдает список пакетов магазина.
    ###
    app.get '/api/v1/store/packages', (req, res) ->
        db= req.app.get 'db'

        # загрузить предметы из базы данных
        db.models.Package.find (err, pkgs) ->

            async.map pkgs
            ,   (pkg, done) ->

                    async.parallel

                        items: (done) ->
                            pkg.getItems (err, items) ->
                                return done err, items

                        servers: (done) ->
                            pkg.getServers (err, servers) ->
                                return done err, servers

                    ,   (err, result) ->
                            pkg.items= result.items
                            pkg.servers= result.servers
                            return done err, pkg

            ,   (err, pkgs) ->

                    if err
                        # ошибка при загрузке пакетов
                        return next err

                    return res.json 200, pkgs