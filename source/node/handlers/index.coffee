module.exports= (app) ->

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


    ###

    Игрок

    ###

    ###
    Методы API для работы c аутентифицированным игроком.
    ###
    app.use '/api/v1/player'
    ,   require './Api/V1/Minecraft/Player'

    ###
    Методы API для работы игрока с магазином.
    ###
    app.use '/api/v1/store'
    ,   require './Api/V1/Minecraft/Store'


    ###
    Ищем сервер по переданному ключу key
    ###
    app.use '/api/v1/server', require './Api/V1/Minecraft/MiddlewareSecret'


    app.use '/api/v1/forum/forum', require './Api/V1/Forum/Forum'
    app.use '/api/v1/forum/section', require './Api/V1/Forum/Section'
    app.use '/api/v1/forum/thread', require './Api/V1/Forum/Thread'
    app.use '/api/v1/forum/comment', require './Api/V1/Forum/Comment'
