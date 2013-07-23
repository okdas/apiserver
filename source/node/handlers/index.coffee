module.exports= (app) ->

    ApiV1= require './ApiV1/'
    Auth= require './Auth/'
    User= require './User'
    Install= require './Install/'

    app.get '/', (req, res, next) ->
        res.render 'Management/welcome'


    ###

    Методы для аутентификации пользователей

    ###

    app.get '/login', Auth.getLogin

    app.post '/login', Auth.postLogin



    app.get '/management', (req, res, next) ->
        res.render 'Management'

    app.get '/management/partials/groups', (req, res, next) ->
        res.render 'Management/partials/Groups'

    app.get '/management/partials/groups/form', (req, res, next) ->
        res.render 'Management/partials/Groups/form'



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

    Методы API для работы c пользователями

    ###

    ###
    Отдает список пользователей.
    ###
    app.get '/api/v1/users', User.listUsers

    ###
    Добавляет переданного пользователя в список.
    ###
    app.post '/api/v1/users', User.addUser

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
