express= require 'express'



###
Методы API для аутентифицированного пользователя
###
app= module.exports= do express
app.on 'mount', (parent) ->
    app.set 'maria', maria= parent.get 'maria'



    app.get '/'
    ,   access
    ,   getUser
    ,   (req, res) ->
            res.json 200, req.user

    app.post '/login'
    ,   maria(app.get 'db')
    ,   login(maria.User)
    ,   (req, res) ->
            res.json 200

    app.post '/logout'
    ,   access
    ,   logout
    ,   (req, res) ->
            res.json 200

    app.get '/sha1/:string'
    ,   getSha1(maria.User)
    ,   (req, res) ->
            res.json 200, req.sha1





access= (req, res, next) ->
    err= null

    if do req.isUnauthenticated
        res.status 401
        err=
            message: 'user not authenticated'

    return next err





getUser= (req, res, next) ->
    return next null



login= (User) -> (req, res, next) ->
    userQuery= new User req.body
    User.login userQuery, req.maria, (err, user) ->
        req.login user, (err) ->
            req.user= user
            return next err



logout= (req, res, next) ->
    do req.logout
    return next null



getSha1= (User) -> (req, res, next) ->
    req.sha1= User.sha1 req.params.string
    return next null














###

app.get '/', access, (req, res, next) ->
    return res.json 401, null if do req.isUnauthenticated
    return res.json 200, req.user



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



app.post '/logout', access, (req, res, next) ->
    return res.json 400, null if req.user.name != req.body.name

    do req.logout
    return res.json 200, true
###
