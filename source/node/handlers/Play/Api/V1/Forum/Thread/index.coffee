express= require 'express'
async= require 'async'

###
Методы API для работы c форумом
###
app= module.exports= do express



###
Добавляет инстанс.
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
            conn.query 'INSERT INTO forum_thread SET ?'
            ,   [req.body]
            ,   (err, resp) ->
                    thread= req.body
                    thread.id= resp.insertId

                    return done err, conn, thread

        (conn, thread, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn, thread

    ],  (err, conn, thread) ->
            do conn.end if conn

            return next err if err
            return res.json 200, thread



###
Отдает список инстансов.
###
app.get '/', (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query 'SELECT * FROM forum_thread'
            ,   (err, rows) ->
                    return done err, conn, rows

    ],  (err, conn, rows) ->
            do conn.end if conn

            return next err if err
            return res.json 200, rows



###
Отдает инстанс.
###
app.get '/:threadId', (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query 'SELECT * FROM forum_thread WHERE id = ?'
            ,   [req.params.threadId]
            ,   (err, resp) ->
                    thread= do resp.shift if not err
                    return done err, conn, thread

    ],  (err, conn, thread) ->
            do conn.end if conn

            return next err if err
            return res.json 404, null if not thread
            return res.json 200, thread



###
Изменяет инстанс
###
app.put '/:threadId', (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            conn.query 'UPDATE forum_thread SET ? WHERE id = ?'
            ,   [req.body, req.params.threadId]
            ,   (err, resp) ->
                    thread= req.body
                    thread.id= req.params.threadId
                    return done err, conn, thread

        (conn, thread, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn, thread

    ],  (err, conn, thread) ->
            do conn.end if conn

            return next err if err
            return res.json 200, thread



###
Удаляет инстанс
###
app.delete '/:threadId', (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            conn.query 'DELETE FROM forum_thread WHERE id = ?'
            ,   [req.params.threadId]
            ,   (err, resp) ->
                    return done err, conn

        (conn, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn

    ],  (err, conn) ->
            do conn.end if conn

            return next err if err
            return res.json 200

