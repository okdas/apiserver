module.exports= (app) ->



    app.get '/', (req, res, next) ->
        res.redirect '/management/'



    app.get '/management/*', (req, res, next) ->
        return do next if do req.isAuthenticated
        return res.render 'Management/welcome'



    app.get '/management/', (req, res, next) ->
        res.locals
            user: req.user
        return res.render 'Management/dashboard'

    app.get '/partials/management/store', (req, res, next) ->
        res.render 'partials/Management/Store'

    app.get '/partials/management/store/items', (req, res, next) ->
        res.render 'partials/Management/Store/Items'

    app.get '/partials/management/store/items/create', (req, res, next) ->
        res.render 'partials/Management/Store/Items/ItemCreate'

    app.get '/partials/management/store/items/update', (req, res, next) ->
        res.render 'partials/Management/Store/Items/ItemUpdate'

    app.get '/partials/management/store/enchantments', (req, res, next) ->
        res.render 'partials/Management/Store/Enchantments'

    app.get '/partials/management/store/enchantments/create', (req, res, next) ->
        res.render 'partials/Management/Store/Enchantments/EnchantmentCreate'

    app.get '/partials/management/store/enchantments/update', (req, res, next) ->
        res.render 'partials/Management/Store/Enchantments/EnchantmentUpdate'



    app.get '/management/engine/', (req, res, next) ->
        res.locals
            user: req.user
        return res.render 'Management/Engine/dashboard'

    app.get 'partials/management/engine/users', (req, res, next) ->
        res.render '/partials/Management/Engine/Users'

    app.get '/management/engine/partials/users/user/create', (req, res, next) ->
        res.render '/partials/Management/Engine/Users/UserCreate'

    app.get '/management/engine/partials/users/user/update', (req, res, next) ->
        res.render '/partials/Management/Engine/Users/UserUpdate'



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
