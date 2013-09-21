express= require 'express'
async= require 'async'



###
Методы API для работы c инстансами серверов.
###
app= module.exports= do express
app.on 'mount', (parent) ->
    app.set 'maria', maria= parent.get 'maria'



    app.post '/'
    ,   access
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   createInstance(maria.Instance)
    ,   maria.transaction.commit()
    ,   (req, res) ->
            res.json 200, req.instance

    app.get '/'
    ,   access
    ,   maria(app.get 'db')
    ,   getInstances(maria.Instance)
    ,   (req, res) ->
            res.json 200, req.instances

    app.get '/:instanceId(\\d+)'
    ,   access
    ,   maria(app.get 'db')
    ,   getInstance(maria.Instance)
    ,   (req, res) ->
            res.json 200, req.instance

    app.put '/:instanceId(\\d+)'
    ,   access
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   updateInstance(maria.Instance)
    ,   maria.transaction.commit()
    ,   (req, res) ->
            res.json 200, req.instance

    app.delete '/:instanceId(\\d+)'
    ,   access
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   deleteInstance(maria.Instance)
    ,   maria.transaction.commit()
    ,   (req, res) ->
            res.json 200



access= (req, res, next) ->
    err= null

    if do req.isUnauthenticated
        res.status 401
        err=
            message: 'user not authenticated'

    return next err






createInstance= (Instance) -> (req, res, next) ->
    instance= new Instance req.body
    Instance.create instance, req.maria, (err, instance) ->
        req.instance= instance or null
        return next err



###
Отдает список серверов.
###
getInstances= (Instance) -> (req, res, next) ->
    Instance.query req.maria, (err, instances) ->
        req.instance= instances or null
        return next err



###
Отдает сервер.
###
getInstance= (Instance) -> (req, res, next) ->
    Instance.get req.params.instanceId, req.maria, (err, instance) ->
        req.instance= instance or null
        return next err



###
Изменяет сервер
###
updateInstance= (Instance) -> (req, res, next) ->
    instance= new Instance req.body
    Instance.update req.params.instanceId, instance, req.maria, (err, instance) ->
        req.instance= instance or null
        return next err



###
Удаляет сервер
###
deleteInstance= (Instance) -> (req, res, next) ->
    Instance.delete req.params.instanceId, req.maria, (err) ->
        return next err

















###
Добавляет инстанс.
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
            conn.query 'INSERT INTO server_instance SET ?'
            ,   [req.body]
            ,   (err, resp) ->
                    instance= req.body
                    instance.id= resp.insertId

                    return done err, conn, instance

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
            conn.query '
                SELECT * FROM server_instance'
            ,   (err, rows) ->
                    return done err, conn, rows

    ],  (err, conn, rows) ->
            do conn.end if conn

            return next err if err
            return res.json 200, rows



###
Отдает инстанс.
###
app.get '/:instanceId(\\d+)', access, (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query '
            SELECT * FROM server_instance WHERE id = ?'
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
app.put '/:instanceId(\\d+)', access, (req, res, next) ->
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
app.delete '/:instanceId(\\d+)', access, (req, res, next) ->
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

