express= require 'express'
async= require 'async'




###
Методы API для платежей
###
app= module.exports= do express
app.on 'mount', (parent) ->
    cfg= parent.get 'config'



    app.post '/'
    ,   access
    ,   createTag
    ,   (req, res) ->
            res.json 200

    app.get '/'
    ,   access
    ,   getTags
    ,   (req, res) ->
            res.json 200

    app.get '/:tagId(\\d+)'
    ,   access
    ,   getTag
    ,   (req, res) ->
            res.json 200

    app.put '/:tagId(\\d+)'
    ,   access
    ,   changeTag
    ,   (req, res) ->
            res.json 200


    app.delete '/:tagId(\\d+)'
    ,   access
    ,   deleteTag
    ,   (req, res) ->
            res.json 200





access= (req, res, next) ->
    return next 401 if do req.isUnauthenticated
    return do next



createTag= (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            conn.query 'INSERT INTO tag SET ?'
            ,   [req.body]
            ,   (err, resp) ->
                    tag= req.body
                    tag.id= resp.insertId

                    return done err, conn, tag

        (conn, tag, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn, tag

    ],  (err, conn, tag) ->
            do conn.end if conn

            return next err if err
            return res.json 200, tag



getTags= (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query '
                SELECT * FROM tag'
            ,   (err, rows) ->
                    return done err, conn, rows

    ],  (err, conn, rows) ->
            do conn.end if conn

            return next err if err
            return res.json 200, rows



getTag= (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query '
                SELECT * FROM tag WHERE id = ?'
            ,   [req.params.tagId]
            ,   (err, resp) ->
                    return done err, conn, resp

    ],  (err, conn, resp) ->
            do conn.end if conn

            return next err if err
            return res.json 200, resp



changeTag= (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            conn.query 'UPDATE tag SET ? WHERE id = ?'
            ,   [req.body, req.params.tagId]
            ,   (err, resp) ->
                    tag= req.body
                    tag.id= req.params.tagId
                    return done err, conn, tag

        (conn, tag, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn, tag

    ],  (err, conn, tag) ->
            do conn.end if conn

            return next err if err
            return res.json 200, tag



deleteTag= (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            conn.query 'DELETE FROM tag WHERE id = ?'
            ,   [req.params.tagId]
            ,   (err, resp) ->
                    return done err, conn

        (conn, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn

    ],  (err, conn) ->
            do conn.end if conn

            return next err if err
            return res.json 200
