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

    name= req.body.name
    pass= sha1 req.body.pass

    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query "
                SELECT
                    u.id,
                    u.name
                FROM
                    users_user as u
                WHERE
                    name = ?
                    AND pass = ?
                "
            ,   [name, pass]
            ,   (err, rows) ->
                    user= do rows.shift if not err
                    return done err, conn, user

    ],  (err, conn, user) ->
            do conn.end if conn

            return next err if err
            return res.json 400, user if not user

            req.login user, (err) ->
                return next err if err
                return res.json 200, user



###
Выполняет выход пользователя.
###
app.post '/logout', (req, res, next) ->
    return res.json 400, null if req.user.name != req.body.name

    do req.logout
    return res.json 200, true
