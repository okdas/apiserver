module.exports= (app) ->



    app.get '/', (req, res, next) ->
        res.redirect '/management/'


    app.get '/management/*', (req, res, next) ->
        return do next if do req.isAuthenticated
        return res.render 'management'


    app.get '/management/', (req, res, next) ->
        res.locals
            user: req.user
        return res.render 'management/project'


    app.get '/management/engine/', (req, res, next) ->
        res.locals
            user: req.user
        return res.render 'management/engine'



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

    Содержимое

    ###

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


    app.get '/test', (req, res, next) ->
        res.render 'test.jade'

