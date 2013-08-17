express= require 'express'

access= (req, res, next) ->
    return next 401 if do req.isUnauthenticated
    return do next


###
Методы API для аутентифицированного пользователя
###
app= module.exports= do express



###
Отдает список пользователей.
###
app.get '/', access, (req, res, next) ->
    req.db.getConnection (err, connection) ->
        return next err if err

        connection.query 'SELECT * FROM users_user'
        ,   (err, rows) ->
                do connection.end

                return next err if err
                return res.json 200, rows



###
Добавляет пользователя.
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



###
Отдает пользователя.
###
app.get '/user/:userId', access, (req, res, next) ->
    req.db.getConnection (err, connection) ->
        return next err if err

        connection.query 'SELECT * FROM users_user WHERE id = ?'
        ,   [req.params.userId]
        ,   (err, rows) ->
                do connection.end

                return next err if err
                return res.json 404, null if not rows.length
                return res.json 200, do rows.shift



###
Обновляет пользователя.
###
app.patch '/user/:userId', access, (req, res, next) ->
    req.db.getConnection (err, connection) ->
        return next err if err

        connection.query 'UPDATE users_user SET ? WHERE id = ?'
        ,   [req.body, req.params.userId]
        ,   (err, resp) ->
                do connection.end

                return next err if err
                return res.json 200, req.body




###
Удаляет пользователя.
###
app.delete '/user/:userId', access, (req, res, next) ->
    req.db.getConnection (err, connection) ->
        return next err if err

        connection.query 'DELETE FROM users_user WHERE id = ?'
        ,   [req.params.userId]
        ,   (err, resp) ->
                do connection.end

                return next err if err
                return res.json 200, {}
