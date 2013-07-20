###

Методы для аутентификации пользователей

###


###
Загружает данные аутентифицированного пользователя и его роли.
###
loadUser= (req,res,next) ->

    if not req.user
        # пользователь не аутентифицирован
        return res.redirect '/login'

    # загрузить пользователя из базы данных
    req.models.User.get req.user.id, (err, user) ->

        if err
            # ошибка при загрузке пользователя
            return next err

        # загрузить роли пользователя из базы данных
        user.getRoles (err, roles) ->
            if err
                # ошибка при загрузке ролей пользователя
                return next err

            # пользователь загружен
            req.user= user
            req.user.roles= roles

            return do next






###
Отдает форму аутентификации.
###

exports.getLogin= (req,res,next) ->
    res.render 'Users/Login'




###
Обрабатывает форму аутентификации.
###
exports.postLogin= (req,res,next) ->
    username= req.body.username
    password= sha1 req.body.password

    # найти пользователя в базе данных
    req.models.User.find
        username: username
        password: password
    ,   (err, users) ->

            if err
                # ошибка при поиске пользователя
                return next err

            if not users.length
                # пользователь не найден
                return res.redirect '/login'

            # пользователь найден
            user= do users.shift
            req.login user, (err) ->

                if err
                    # ошибка при аутентификации пользователя
                    return next err

                # пользователь аутентифицирован
                return res.redirect '/'






