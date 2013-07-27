express= require 'express'



crypto= require 'crypto'
sha1= (string) ->
    hash= crypto.createHash 'sha1'
    hash.update string
    return hash.digest 'hex'



###
Методы API для аутентифицированного пользователя
###
app= module.exports= do express



###
Отдает аутентифицированного пользователя.
###
app.get '/', (req, res, next) ->
    return res.json 401, null if do req.isUnauthenticated
    return res.json 200, req.user



###
Выполняет вход пользователя.
###
app.post '/login', (req, res, next) ->
    username= req.body.username
    password= req.body.password

    User= req.resources.Users.User
    User.findBy 'username', username, (err, user) ->
        return next err if err and not (err instanceof User.Error)
        return res.json 204, null if not user
        return res.json 204, null if user.password != sha1 password

        req.login user, (err) ->
            return next err if err
            return res.json 200, user



###
Выполняет выход пользователя.
###
app.post '/logout', (req, res, next) ->
    return res.json 401, null if do req.isUnauthenticated

    username= req.body.username
    return res.json 400, null if req.user.username != username

    do req.logout
    return res.json 200, true
