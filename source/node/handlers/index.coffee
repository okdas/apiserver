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

    app.use App.static "#{__dirname}/../views/public/templates/play"


    ###
    Методы API для работы c аутентифицированным игроком.
    ###
    app.use '/api/v1/player'
    ,   require './Api/V1/Minecraft/Player'

    ###
    Методы API для работы игрока с магазином.
    ###
    app.use '/api/v1/player/store'
    ,   require './Api/V1/Minecraft/Player/Store'

    app



exports.management= () ->
    app= do App

    passport= new Passport
    passport.serializeUser (user, done) ->
        console.log 'serialize user', user
        done null, user
    passport.deserializeUser (id, done) ->
        console.log 'deserialize user', id
        done null, id

    app.use App.session
        key:'management.sid', secret:'user'
        store: new SessionStore
    app.use do passport.initialize
    app.use do passport.session


    app.get '/management/', (req, res, next) ->
        console.log 'auth user', req.session
        return do next if do req.isUnauthenticated
        return res.redirect '/management/project/'

    app.get '/management/project', (req, res, next) ->
        return do next if do req.isAuthenticated
        return res.redirect '/management/'

    app.get '/management/engine', (req, res, next) ->
        return do next if do req.isAuthenticated
        return res.redirect '/management/'


    app.use App.static "#{__dirname}/../views/public/templates/management"


    ###

    Пользователи

    ###

    ###
    Методы API для работы c аутентифицированным пользователем.
    ###
    app.use '/api/v1/user'
    ,   require './Api/V1/User'

    ###
    Методы API для работы c пользователями.
    ###
    app.use '/api/v1/users'
    ,   require './Api/V1/Users'


    ###

    Проект

    ###

    ###
    Методы API для работы c игроками.
    ###
    app.use '/api/v1/players'
    ,   require './Api/V1/Minecraft/Players'

    ###
    Методы API для работы c серверами.
    ###
    app.use '/api/v1/servers'
    ,   require './Api/V1/Minecraft/Servers'

    ###
    Методы API для работы c инстансами.
    ###
    app.use '/api/v1/instances'
    ,   require './Api/V1/Minecraft/Instances'


    ###

    Магазин

    ###

    ###
    Методы API для работы c заказами магазина.
    ###
    app.use '/api/v1/store/orders'
    ,   require './Api/V1/Minecraft/Store/Orders'

    ###
    Методы API для работы c чарами.
    ###
    app.use '/api/v1/store/enchantments'
    ,   require './Api/V1/Minecraft/Store/Enchantments'

    ###
    Методы API для работы c предметами.
    ###
    app.use '/api/v1/store/items'
    ,   require './Api/V1/Minecraft/Store/Items'


    ###

    Сервер

    ###

    ###
    Методы API для работы c аутентифицированным сервером.
    ###
    app.use '/api/v1/server', require './Api/V1/Minecraft/MiddlewareSecret'

    app
