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
    username= req.body.name
    password= req.body.pass

    req.db.getConnection (err, connection) ->
        return next err if err

        connection.query 'SELECT * FROM users_user WHERE name = ?'
        ,   [username]
        ,   (err, rows) ->
                do connection.end

                return next err if err
                return res.json 400, null if not rows.length

                user= do rows.shift
                return res.json 400, null if user.pass != sha1 password

                delete user.password

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
