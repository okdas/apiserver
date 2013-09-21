express= require 'express'



###
Методы API для аутентифицированного пользователя
###
app= module.exports= do express
app.on 'mount', (parent) ->
    app.set 'maria', maria= parent.get 'maria'



    app.post '/'
    ,   access
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   create(maria.User)
    ,   maria.transaction.commit()
    ,   (req, res) ->
            res.json 200, req.usr

    app.get '/'
    ,   access
    ,   maria(app.get 'db')
    ,   query(maria.User)
    ,   (req, res) ->
            res.json 200, req.users

    app.get '/:userId(\\d+)'
    ,   access
    ,   maria(app.get 'db')
    ,   get(maria.User)
    ,   (req, res) ->
            res.json 200, req.usr

    app.put '/:userId(\\d+)'
    ,   access
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   update(maria.User)
    ,   maria.transaction.commit()
    ,   (req, res) ->
            res.json 200, req.usr

    app.delete '/:userId(\\d+)'
    ,   access
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   remove(maria.User)
    ,   maria.transaction.commit()
    ,   (req, res) ->
            res.json 200



access= (req, res, next) ->
    err= null

    if do req.isUnauthenticated
        res.status 401
        err=
            message: 'user not authenticated'

    return next err





###
Добавляет пользователя.
###
create= (User) -> (req, res, next) ->
    newUser= new User req.body
    console.log 'new', newUser
    User.create newUser, req.maria, (err, user) ->
        req.usr= user or null
        return next err



###
Отдает список пользователей.
###
query= (User) -> (req, res, next) ->
    User.query req.maria, (err, users) ->
        req.users= users or null
        return next err



###
Отдает пользователя.
###
get= (User) -> (req, res, next) ->
    User.get req.params.userId, req.maria, (err, user) ->
        req.usr= user or null
        return next err



###
Изменяет сервер
###
update= (User) -> (req, res, next) ->
    updateUser= new User req.body
    User.update req.params.userId, updateUser, req.maria, (err, user) ->
        req.usr= user or null
        return next err



###
Удаляет пользователя.
###
remove= (User) -> (req, res, next) ->
    User.delete req.params.userId, req.maria, (err) ->
        return next err















###
app.post '/', access, (req, res, next) ->
    req.db.getConnection (err, connection) ->
        return next err if err

        connection.query 'INSERT INTO users_user SET ?'
        ,   [req.body]
        ,   (err, resp) ->
                do connection.end

                return res.json 400, req.body if err and err.code= 'ER_DUP_ENTRY'
                return next err if err
                return res.json 201, req.body



app.get '/', access, (req, res, next) ->
    req.db.getConnection (err, connection) ->
        return next err if err

        connection.query 'SELECT * FROM users_user'
        ,   (err, rows) ->
                do connection.end

                return next err if err
                return res.json 200, rows






app.get '/:userId', access, (req, res, next) ->
    req.db.getConnection (err, connection) ->
        return next err if err

        connection.query 'SELECT * FROM users_user WHERE id = ?'
        ,   [req.params.userId]
        ,   (err, rows) ->
                do connection.end

                return next err if err
                return res.json 404, null if not rows.length
                return res.json 200, do rows.shift



app.put '/:userId', access, (req, res, next) ->
    req.db.getConnection (err, connection) ->
        return next err if err

        connection.query 'UPDATE users_user SET ? WHERE id = ?'
        ,   [req.body, req.params.userId]
        ,   (err, resp) ->
                do connection.end

                return next err if err
                return res.json 200, req.body




app.delete '/:userId', access, (req, res, next) ->
    req.db.getConnection (err, connection) ->
        return next err if err

        connection.query 'DELETE FROM users_user WHERE id = ?'
        ,   [req.params.userId]
        ,   (err, resp) ->
                do connection.end

                return next err if err
                return res.json 200
###
