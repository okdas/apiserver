module.exports= (app) ->

    ApiV1= require './ApiV1/'
    Auth= require './Auth/'
    User= require './User'


    app.get '/', (req,res,next) ->
        res.send 200



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
    app.get '/api/v1/users/:userId/groups', User.getGroupsOfUser

    ###
    Добавляет указанному пользователю переданную группу.
    ###
    app.post '/api/v1/users/:userId/groups', User.addGroupOfUser



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

    app.get '/install*', (req, res, next) ->
        config= app.get 'config'

        if config.installed
            return next 404

        return do next


    app.get '/install', (req, res, next) ->
        return res.render 'Management/Install'

    app.get '/install/db', (req, res, next) ->
        return res.json
            models: Object.keys req.models
            driver:
                name: req.db.driver_name
                config: req.db.driver.config
                options: req.db.driver.opts

    app.get '/install/db/sync', (req, res, next) ->
        req.db.sync (err) ->
            if err
                # ошибка при запиливании базы данных
                return next err
            # база данных запилена
            return res.json true

    app.get '/install/db/drop', (req, res, next) ->
        req.db.drop (err) ->
            if err
                # ошибка при выпиливании базы данных
                return next err
            # база данных выпилена
            return res.json true

    app.get '/install/db/models', (req, res, next) ->
        return res.json Object.keys req.models

    app.get '/install/db/models/:modelName', (req, res, next) ->
        modelName= req.param 'modelName'
        return res.json !!req.models[modelName]

    app.get '/install/db/models/:modelName/sync', (req, res, next) ->
        modelName= req.param 'modelName'
        req.models[modelName].sync (err) ->
            if err
                # ошибка при запиливании модели
                return next err
            return res.json true

    app.get '/install/db/models/:modelName/drop', (req, res, next) ->
        modelName= req.param 'modelName'
        req.models[modelName].drop (err) ->
            if err
                # ошибка при выпиливании модели
                return next err
            return res.json true
