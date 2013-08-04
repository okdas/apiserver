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
            conn.query 'INSERT INTO forum SET ?'
            ,   [req.body]
            ,   (err, resp) ->
                    forum= req.body
                    forum.id= resp.insertId

                    return done err, conn, forum

        (conn, forum, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn, forum

    ],  (err, conn, forum) ->
            do conn.end if conn

            return next err if err
            return res.json 200, forum



###
Отдает список инстансов.
###
app.get '/', (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query 'SELECT * FROM forum'
            ,   (err, rows) ->
                    return done err, conn, rows

    ],  (err, conn, rows) ->
            do conn.end if conn

            return next err if err
            return res.json 200, rows



###
Отдает инстанс.
###
app.get '/:forumId', (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query 'SELECT * FROM forum WHERE id = ?'
            ,   [req.params.forumId]
            ,   (err, resp) ->
                    forum= do resp.shift if not err
                    return done err, conn, forum

    ],  (err, conn, forum) ->
            do conn.end if conn

            return next err if err
            return res.json 404, null if not forum
            return res.json 200, forum



###
Изменяет инстанс
###
app.put '/:forumId', (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            conn.query 'UPDATE forum SET ? WHERE id = ?'
            ,   [req.body, req.params.forumId]
            ,   (err, resp) ->
                    forum= req.body
                    forum.id= req.params.forumId
                    return done err, conn, forum

        (conn, forum, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn, forum

    ],  (err, conn, forum) ->
            do conn.end if conn

            return next err if err
            return res.json 200, forum



###
Удаляет инстанс
###
app.delete '/:forumId', (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            conn.query 'DELETE FROM forum WHERE id = ?'
            ,   [req.params.forumId]
            ,   (err, resp) ->
                    return done err, conn

        (conn, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn

    ],  (err, conn) ->
            do conn.end if conn

            return next err if err
            return res.json 200

