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
            conn.query 'INSERT INTO forum_comment SET ?'
            ,   [req.body]
            ,   (err, resp) ->
                    comment= req.body
                    comment.id= resp.insertId

                    return done err, conn, comment

        (conn, comment, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn, comment

    ],  (err, conn, comment) ->
            do conn.end if conn

            return next err if err
            return res.json 200, comment



###
Отдает список инстансов.
###
app.get '/', (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query 'SELECT * FROM forum_comment'
            ,   (err, rows) ->
                    return done err, conn, rows

    ],  (err, conn, rows) ->
            do conn.end if conn

            return next err if err
            return res.json 200, rows



###
Отдает инстанс.
###
app.get '/:commentId', (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query 'SELECT * FROM forum_comment WHERE id = ?'
            ,   [req.params.commentId]
            ,   (err, resp) ->
                    comment= do resp.shift if not err
                    return done err, conn, comment

    ],  (err, conn, comment) ->
            do conn.end if conn

            return next err if err
            return res.json 404, null if not comment
            return res.json 200, comment



###
Изменяет инстанс
###
app.put '/:commentId', (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            conn.query 'UPDATE forum_comment SET ? WHERE id = ?'
            ,   [req.body, req.params.commentId]
            ,   (err, resp) ->
                    comment= req.body
                    comment.id= req.params.commentId
                    return done err, conn, comment

        (conn, comment, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn, comment

    ],  (err, conn, comment) ->
            do conn.end if conn

            return next err if err
            return res.json 200, comment



###
Удаляет инстанс
###
app.delete '/:commentId', (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            conn.query 'DELETE FROM forum_comment WHERE id = ?'
            ,   [req.params.commentId]
            ,   (err, resp) ->
                    return done err, conn

        (conn, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn

    ],  (err, conn) ->
            do conn.end if conn

            return next err if err
            return res.json 200

