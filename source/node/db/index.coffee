express= require 'express'
async= require 'async'
fs= require 'fs'



class Db
    @syncDb: (conn, database, cb) ->

    @syncMaterial: (conn, database, cb) ->

module.exports= Db





access= (req, res, next) ->
    return next 401 if do req.isUnauthenticated
    return do next

###
Методы API для работы c серверами.
###
app= module.exports= do express



###
Добавляет бд и таблицы
###
app.post '/db', access, (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            dump= fs.readFileSync './sql/db.sql'
            console.log dump
            #conn.query dump, (err, resp) ->
            #    return done err, conn, instance

        (conn, instance, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn, instance

    ],  (err, conn, instance) ->
            do conn.end if conn

            return next err if err
            return res.json 200, instance



###
Отдает список инстансов.
###
app.get '/', access, (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query 'SELECT * FROM server_instance'
            ,   (err, rows) ->
                    return done err, conn, rows

    ],  (err, conn, rows) ->
            do conn.end if conn

            return next err if err
            return res.json 200, rows



###
Отдает инстанс.
###
app.get '/:instanceId', access, (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query 'SELECT * FROM server_instance WHERE id = ?'
            ,   [req.params.instanceId]
            ,   (err, resp) ->
                    instance= do resp.shift if not err
                    return done err, conn, instance

    ],  (err, conn, instance) ->
            do conn.end if conn

            return next err if err
            return res.json 404, null if not instance
            return res.json 200, instance



###
Изменяет инстанс
###
app.put '/:instanceId', access, (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            conn.query 'UPDATE server_instance SET ? WHERE id = ?'
            ,   [req.body, req.params.instanceId]
            ,   (err, resp) ->
                    instance= req.body
                    instance.id= req.params.instanceId
                    return done err, conn, instance

        (conn, instance, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn, instance

    ],  (err, conn, instance) ->
            do conn.end if conn

            return next err if err
            return res.json 200, instance



###
Удаляет инстанс
###
app.delete '/:instanceId', access, (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            conn.query 'DELETE FROM server_instance WHERE id = ?'
            ,   [req.params.instanceId]
            ,   (err, resp) ->
                    return done err, conn

        (conn, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn

    ],  (err, conn) ->
            do conn.end if conn

            return next err if err
            return res.json 200
