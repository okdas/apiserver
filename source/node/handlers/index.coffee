App= require 'express'
{Passport}= require 'passport'

SessionStore= require 'connect-redis'
SessionStore= SessionStore App


exports.play= () ->
    app= do App

    passport= new Passport
    passport.serializeUser (user, done) ->
        console.log 'serialize player', user
        done null, user
    passport.deserializeUser (id, done) ->
        console.log 'deserialize player', id
        done null, id

    app.use App.session
        key:'play.sid', secret:'player'
        store: new SessionStore
    app.use do passport.initialize
    app.use do passport.session


    app.get '/', (req, res, next) ->
        return res.redirect '/player/' if do req.isAuthenticated
        return res.redirect '/welcome/'

    app.get '/player', (req, res, next) ->
        return res.redirect '/welcome/' if do req.isUnauthenticated
        return do next

    app.use App.static "#{__dirname}/../views/templates/Play"


    ###
    Методы API для работы c аутентифицированным игроком.
    ###
    app.use '/api/v1/player'
    ,   require './Play/Api/V1/Player'

    ###
    Методы API для работы c платежами аутентифицированного игрока.
    ###
    app.use '/api/v1/player/payments'
    ,   require './Play/Api/V1/Player/Payments'

    ###
    Методы API для работы игрока с магазином.
    ###
    app.use '/api/v1/player/store'
    ,   require './Play/Api/V1/Player/Store'

    app



exports.manage= () ->
    app= do App

    passport= new Passport
    passport.serializeUser (user, done) ->
        console.log 'serialize user', user
        done null, user
    passport.deserializeUser (id, done) ->
        console.log 'deserialize user', id
        done null, id

    app.use App.session
        key:'manage.sid', secret:'user'
        store: new SessionStore
    app.use do passport.initialize
    app.use do passport.session


    app.get '/', (req, res, next) ->
        return do next if do req.isUnauthenticated
        return res.redirect '/project/'

    app.get '/project', (req, res, next) ->
        return do next if do req.isAuthenticated
        return res.redirect '/'

    app.get '/engine', (req, res, next) ->
        return do next if do req.isAuthenticated
        return res.redirect '/'


    app.use App.static "#{__dirname}/../views/templates/Manage"


    ###

    Пользователи

    ###

    ###
    Методы API для работы c аутентифицированным пользователем.
    ###
    app.use '/api/v1/user', require './Manage/Api/V1/User'

    ###
    Методы API для работы c пользователями.
    ###
    app.use '/api/v1/users', require './Manage/Api/V1/Users'



    ###

    Проект

    ###

    ###
    Игрок

    Игрок имеет предмет, шипмент, и ордер, поэтому это все его
    ###

    # Методы API для работы с игрокам.
    app.use '/api/v1/players', require './Manage/Api/V1/Project/Players/Player'

    #  Методы API для работы c ордерами.
    app.use '/api/v1/players/orders', require './Manage/Api/V1/Project/Players/Order'

    # Методы API для работы c аутентифицированным сервером.
    app.use '/api/v1/players/server', require './Manage/Api/V1/Project/Players/MiddlewareServer'

    # Методы API для плагина, требуют key сервера.
    app.use '/api/v1/players/server/item', require './Manage/Api/V1/Project/Players/Item'



    ###
    Баккит
    ###
    # Методы API для работы c чарами.
    app.use '/api/v1/bukkit/enchantments', require './Manage/Api/V1/Project/Bukkit/Enchantments'

    # Методы API для работы c материалами.
    app.use '/api/v1/bukkit/materials', require './Manage/Api/V1/Project/Bukkit/Materials'




    ###
    Методы API для работы c серверами.
    ###
    app.use '/api/v1/servers', require './Manage/Api/V1/Project/Servers'

    ###
    Методы API для работы c инстансами серверов.
    ###
    app.use '/api/v1/servers/instances', require './Manage/Api/V1/Project/Servers/Instances'

    ###
    Методы API для работы c предметами сервера.
    ###
    app.use '/api/v1/server/items', require './Manage/Api/V1/Project/Servers/Items'



    ###

    Рассылка

    ###

    ###
    Методы API для рассылки писем.
    ###
    app.use '/api/v1/sender/mail', require './Manage/Api/V1/Sender/Mail'

    ###
    Методы API для рассылки смс.
    ###
    app.use '/api/v1/sender/sms', require './Manage/Api/V1/Sender/Sms'





    app
