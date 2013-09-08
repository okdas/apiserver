express= require 'express'
async= require 'async'

access= (req, res, next) ->
    return next 401 if do req.isUnauthenticated
    return do next

###
Методы API для работы c серверами.
###
app= module.exports= do express



###
Добавляет сервер.
###
app.post '/', access, (req, res, next) ->
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
                    server= req.body
                    server.id= resp.insertId
                    return done err, conn, server

        (conn, server, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn, server

    ],  (err, conn, server) ->
            do conn.end if conn

            return next err if err
            return res.json 200, server



###
Отдает список серверов.
###
app.get '/', access, (req, res, next) ->
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
app.get '/:serverId(\\d+)', access, (req, res, next) ->
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
Изменяет сервер
###
app.put '/:serverId(\\d+)', access, (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            conn.query 'UPDATE server SET ? WHERE id = ?'
            ,   [req.body, req.params.serverId]
            ,   (err, resp) ->
                    server= req.body
                    server.id= req.params.serverId
                    return done err, conn

        (conn, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn

    ],  (err, conn) ->
            do conn.end if conn

            return next err if err
            return res.json 200



###
Удаляет сервер
###
app.delete '/:serverId(\\d+)', access, (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            conn.query 'DELETE FROM server WHERE id = ?'
            ,   [req.params.serverId]
            ,   (err, resp) ->
                    return done err, conn

        (conn, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn

    ],  (err, conn) ->
            do conn.end if conn

            return next err if err
            return res.json 200
