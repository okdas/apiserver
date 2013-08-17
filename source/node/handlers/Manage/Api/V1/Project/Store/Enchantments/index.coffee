express= require 'express'

access= (req, res, next) ->
    return next 401 if do req.isUnauthenticated
    return do next


###
Методы API для работы c чарами.
###
app= module.exports= do express



###
Отдает список чар.
###
app.get '/', access, (req, res, next) ->
    req.db.getConnection (err, connection) ->
        return next err if err

        connection.query 'SELECT * FROM store_enchantment'
        ,   (err, rows) ->
                do connection.end

                return next err if err
                return res.json 200, rows



###
Добавляет чару.
###
app.post '/', access, (req, res, next) ->
    req.db.getConnection (err, connection) ->
        return next err if err

        connection.query 'INSERT INTO store_enchantment SET ?'
        ,   [req.body]
        ,   (err, resp) ->
                do connection.end

                return res.json 400, req.body if err and err.code= 'ER_DUP_ENTRY'
                return next err if err
                return res.json 201, req.body



###
Отдает чару.
###
app.get '/:enchantmentId', access, (req, res, next) ->
    req.db.getConnection (err, connection) ->
        return next err if err

        connection.query 'SELECT * FROM store_enchantment WHERE id = ?'
        ,   [req.params.enchantmentId]
        ,   (err, rows) ->
                do connection.end

                return next err if err
                return res.json 404, null if not rows.length
                return res.json 200, do rows.shift



###
Обновляет чару.
###
app.patch '/:enchantmentId', access, (req, res, next) ->
    req.db.getConnection (err, connection) ->
        return next err if err

        connection.query 'UPDATE store_enchantment SET ? WHERE id = ?'
        ,   [req.body, req.params.enchantmentId]
        ,   (err, resp) ->
                do connection.end

                return next err if err
                return res.json 200, req.body



###
Удаляет чару.
###
app.delete '/:enchantmentId', access, (req, res, next) ->
    req.db.getConnection (err, connection) ->
        return next err if err

        connection.query 'DELETE FROM store_enchantment WHERE id = ?'
        ,   [req.params.enchantmentId]
        ,   (err, resp) ->
                do connection.end

                return next err if err
                return res.json 200, {}
