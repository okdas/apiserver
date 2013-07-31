express= require 'express'
async= require 'async'



###
Методы API для работы c серверами.
###
app= module.exports= do express



###
Отдает список серверов.
###
app.get '/', (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query 'SELECT * FROM server'
            ,   (err, rows) ->
                    return done err, conn, rows

    ],  (err, conn, rows) ->
            do conn.end if conn

            return next err if err
            return res.json 200, rows



###
Отдает сервер.
###
app.get '/:serverId', (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query 'SELECT * FROM server WHERE id = ?'
            ,   [req.params.serverId]
            ,   (err, resp) ->
                    server= do resp.shift if not err
                    return done err, conn, server

    ],  (err, conn, server) ->
            do conn.end if conn

            return next err if err
            return res.json 404, null if not server
            return res.json 200, server



###
Добавляет сервер.
###
app.post '/', (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            conn.query 'INSERT INTO server SET ?'
            ,   [req.body]
            ,   (err, resp) ->
                    id= resp.insertId if not err
                    return done err, conn, id

        (conn, id, done) ->
            conn.query 'SHOW TABLES LIKE ?'
            ,   ["server_#{req.body.name}"]
            ,   (err, resp) ->
                    err= 'exists' if not err and resp.length
                    return done err, conn

        (conn, id, done) ->
            conn.query 'CREATE TABLE ?? (`id` INT NOT NULL AUTO_INCREMENT, PRIMARY KEY (`id`) )'
            ,   ["server_#{req.body.name}"]
            ,   (err, resp) ->
                    console.log arguments
                    return done err, conn

        (conn, done) ->
            conn.query 'ROLLBACK', (err) ->
                return done err, conn

    ],  (err, conn) ->
            do conn.end if conn