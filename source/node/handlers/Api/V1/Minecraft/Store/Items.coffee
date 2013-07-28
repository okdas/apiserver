express= require 'express'



###
Методы API для работы c предметами.
###
app= module.exports= do express



###
Отдает список предметов.
###
app.get '/', (req, res, next) ->
    req.db.getConnection (err, connection) ->
        return next err if err

        connection.query 'SELECT * FROM store_item'
        ,   (err, rows) ->
                do connection.end

                return next err if err
                return res.json 200, rows



###
Добавляет предмет.
###
app.post '/', (req, res, next) ->
    req.db.getConnection (err, connection) ->
        return next err if err

        connection.query 'INSERT INTO store_item SET ?'
        ,   [req.body]
        ,   (err, resp) ->
                do connection.end

                return res.json 400, req.body if err and err.code= 'ER_DUP_ENTRY'
                return next err if err
                return res.json 201, req.body



###
Отдает предмет.
###
app.get '/:itemId', (req, res, next) ->
    req.db.getConnection (err, connection) ->
        return next err if err

        connection.query 'SELECT * FROM store_item WHERE id = ?'
        ,   [req.params.itemId]
        ,   (err, rows) ->
                do connection.end

                return next err if err
                return res.json 404, null if not rows.length
                return res.json 200, do rows.shift



###
Обновляет предмет.
###
app.patch '/:itemId', (req, res, next) ->
    req.db.getConnection (err, connection) ->
        return next err if err

        connection.query 'UPDATE store_item SET ? WHERE id = ?'
        ,   [req.body, req.params.itemId]
        ,   (err, resp) ->
                do connection.end

                return next err if err
                return res.json 200, req.body



###
Удаляет предмет.
###
app.delete '/:itemId', (req, res, next) ->
    req.db.getConnection (err, connection) ->
        return next err if err

        connection.query 'DELETE FROM store_item WHERE id = ?'
        ,   [req.params.itemId]
        ,   (err, resp) ->
                do connection.end

                return next err if err
                return res.json 200, {}



###
Добавить чары предмету
###
app.post '/:itemId/enchantments', (req, res, next) ->
    req.body.itemId= req.params.itemId
    req.db.getConnection (err, connection) ->
        return next err if err

        connection.query 'INSERT INTO store_item_enchantments SET ?'
        ,   [req.body]
        ,   (err, resp) ->
                do connection.end

                return next err if err
                return res.json 201, req.body