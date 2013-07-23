async= require 'async'

crypto= require 'crypto'
sha1= (string) ->
    hash= crypto.createHash 'sha1'
    hash.update string
    return hash.digest 'hex'

module.exports= (app) ->

    ApiV1= require './ApiV1/'
    Auth= require './Auth/'
    User= require './User'
    Install= require './Install/'

    app.get '/', (req, res, next) ->
        res.redirect '/management/'


    app.get '/management/', (req, res, next) ->
        return do next if do req.isUnauthenticated
        return res.render 'Management/dashboard'

    app.get '/management/', (req, res, next) ->
        return res.render 'Management/welcome' 



    app.get '/management/engine/', (req, res, next) ->
        return res.render 'Management/Engine/dashboard' 

    app.get '/management/engine/partials/users', (req, res, next) ->
        res.render 'Management/Engine/partials/Users'



    ###

    Методы API для работы c пользователями

    ###

    ###
    Отдает список пользователей.
    ###
    app.get '/api/v1/users', (req, res, next) ->

        req.redis.exists 'users', (err, exists) ->
            return next err if err
            return res.send 500, 'кеш пуст' if not exists

        req.redis.sort 'users', 'ALPHA', (err, keys) ->
            users= []
            async.map keys

            ,   (key, done) ->
                    q= ['users', key].join ':'
                    req.redis.hgetall q, (err, user) ->
                        return done err if err
                        users.push user
                        return do done

            ,   (err) ->
                    return next err if err
                    return res.json 200, users


    ###
    Добавляет переданного пользователя в список.
    ###
    app.post '/api/v1/users', (req, res, next) ->
        time= new Date().getTime()
        user=
            username: req.body.username
            password: sha1 req.body.password
            createdAt: time

        multi= do req.redis.multi

        key= ['users', user.username].join ':'
        multi.hmset key, user

        multi.sadd 'users', user.username

        multi.exec (err, reps) ->
            return next err if err
            return res.json 201, user

    ###
    Отдает указанного пользователя.
    ###
    app.get '/api/v1/users/:userId', User.getUser

    ###
    Отдает список групп указанного пользователя.
    ###
    app.get '/api/v1/users/:userId/groups', User.getUserGroups

    ###
    Добавляет указанному пользователю переданную группу.
    ###
    app.post '/api/v1/users/:userId/groups/:groupId', User.addUserGroup



    ###

    Методы API для работы c группами пользователей

    ###

    ###
    Отдает список групп.
    ###
    app.get '/api/v1/groups', User.listGroups

    ###
    Добавляет переданную группу в список.
    ###
    app.post '/api/v1/groups', User.addGroup

    ###
    Отдает указанную группу.
    ###
    app.get '/api/v1/groups/:groupId', User.getGroup



    ###

    Методы API для работы с предметами магазина

    ###

    ###
    Отдает список предметов магазина.
    ###
    app.get '/api/v1/store/items', ApiV1.listItems

    ###
    Добавляет переданный предмет в магазин.
    ###
    app.post '/api/v1/store/items', ApiV1.addItem

    ###
    Изменяет указанный предмет в магазине.
    ###
    app.patch '/api/v1/store/items/:itemId', ApiV1.changeItem

    ###
    Удаляет указанный предмет из магазина.
    ###
    app.delete '/api/v1/store/items/:itemId', ApiV1.deleteItem




    ###

    Методы API для работы с пакетами магазина

    ###

    ###
    Отдает список пакетов магазина.
    ###
    app.get '/api/v1/store/packages', ApiV1.listPackages



    ###

    Методы для настройки приложения

    ###

    app.get '/install*', Install.isInstall


    app.get '/install', Install.renderInstall


    app.get '/install/db', Install.getDb

    app.get '/install/db/sync', Install.syncDb

    app.get '/install/db/drop', Install.dropDb

    app.get '/install/db/models', Install.listModels

    app.get '/install/db/models/:modelName', Install.getModel

    app.get '/install/db/models/:modelName/sync', Install.syncModel

    app.get '/install/db/models/:modelName/drop', Install.dropModel


    ###

    Методы API для работы со складом

    ###

    ###
    Отдает склад указанного игрока на указанном сервере.
    ###
    app.get '/api/v1/players/:playerId/servers/:serverId/storage', (req, res, next) ->
        playerId= parseInt req.param 'playerId'
        serverId= parseInt req.param 'serverId'

        storage=
            items: []

        req.models.StorageItem.find
            player_id: playerId
            server_id: serverId
        ,   (err, items) ->
                return next err if err

                storage.items= items
                return res.json 200, storage


    app.get '/api/v2/servers', (req, res, next) ->

        req.redis.exists 'servers', (err, exists) ->
            return next err if err
            return res.send 'кеш пуст' if not exists
            console.log 'есть ключ'

            req.redis.sort 'servers BY nosort GET servers:*', (err, resp) ->
                return next err if err
                return res.json resp




    app.post '/api/v1/user/login', (req, res, next) ->

        username= req.body.username
        password= req.body.password

        req.redis.exists 'users', (err, exists) ->
            return next err if err
            return res.send 'кеш пуст' if not exists

            k= ['users', username].join ':'
            req.redis.hgetall k, (err, user) ->
                return next err if err
                return res.json 204, null if not user
                return res.json 204, null if user.password != password

                user.username= username
                req.login user, (err) ->
                    return next err if err
                    return res.json 200,
                        username: username


    app.post '/api/v1/user/logout', (req, res, next) ->
        return res.json 401, null if do req.isUnauthenticated

        username= req.body.username
        return res.json 400, null if req.user.username != username

        do req.logout
        return res.json 200, true


    app.get '/api/v1/user', (req, res, next) ->
        return res.json 401, null if do req.isUnauthenticated
        return res.json 200, req.user
