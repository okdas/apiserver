App= require 'express'
{Passport}= require 'passport'

SessionStore= require 'connect-redis'
SessionStore= SessionStore App



app= module.exports= do App

app.on 'mount', (parent) ->
    app.set 'config', parent.get 'config'

    app.enable 'strict routing'


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



    app.use App.static "#{__dirname}/../views/templates/Manage"



    app.get '/', (req, res, next) ->
        return do next if do req.isUnauthenticated
        return res.redirect '/project/'



    app.get '/project', (req, res, next) ->
        return do next if do req.isAuthenticated
        return res.redirect '/'



    app.get '/engine', (req, res, next) ->
        return do next if do req.isAuthenticated
        return res.redirect '/'





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
    app.use '/api/v1/players/player', require './Manage/Api/V1/Project/Players/Player'

    # Методы API для работы с платежами.
    app.use '/api/v1/players/payment', require './Manage/Api/V1/Project/Players/Payment'

    #  Методы API для работы c ордерами.
    app.use '/api/v1/players/order', require './Manage/Api/V1/Project/Players/Order'

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
    app.use '/api/v1/servers/server', require './Manage/Api/V1/Project/Servers/Server'

    ###
    Методы API для работы c инстансами серверов.
    ###
    app.use '/api/v1/servers/instance', require './Manage/Api/V1/Project/Servers/Instance'

    ###
    Методы API для работы c предметами сервера.
    ###
    app.use '/api/v1/servers/item', require './Manage/Api/V1/Project/Servers/Item'





    ###
    Методы API для рассылки писем и смс.
    ###
    app.use '/api/v1/sender', require './Manage/Api/V1/Project/Players/Sender'





    ###
    Методы API для рассылки писем и смс.
    ###
    app.use '/api/v1/tags', require './Manage/Api/V1/Project/Tags/Tag'



    ###
    Обрабатывает ошибку
    ###
    app.use (err, req, res, next) ->
        res.json
            message: err.message
