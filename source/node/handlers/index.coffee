async= require 'async'

module.exports= (app) ->

    Install= require './Install/'


    app.get '/', (req, res, next) ->
        res.redirect '/management/'



    app.get '/management/*', (req, res, next) ->
        return do next if do req.isAuthenticated
        return res.render 'Management/welcome'



    app.get '/management/', (req, res, next) ->
        res.locals
            user: req.user
        return res.render 'Management/dashboard'



    app.get '/management/engine/', (req, res, next) ->
        res.locals
            user: req.user
        return res.render 'Management/Engine/dashboard' 

    app.get '/management/engine/partials/users', (req, res, next) ->
        res.render 'Management/Engine/partials/Users'

    app.get '/management/engine/partials/users/user', (req, res, next) ->
        res.render 'Management/Engine/partials/Users/User'



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
