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
