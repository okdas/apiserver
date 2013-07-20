module.exports= (app) ->

    ApiV1= require './ApiV1/'
    Auth= require './Auth/'



    app.get '/', (req,res,next) ->
        res.send 200




    app.get '/login', Auth.getLogin
    app.post '/login', Auth.postLogin




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


