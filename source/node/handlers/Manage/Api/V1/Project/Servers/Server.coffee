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
            data=
                name: req.body.name
                title: req.body.title
                key: req.body.key

            conn.query 'INSERT INTO server SET ?'
            ,   [data]
            ,   (err, resp) ->
                    server= req.body
                    server.id= resp.insertId
                    return done err, conn, server

        (conn, server, done) ->
            # а есть ли вобще энчаты у предмета
            if not req.body.tags
                return done null, conn, server

            bulk= []
            for tag in req.body.tag
                bulk.push [server.id, tag.id]
            conn.query '
                INSERT INTO server_tag
                    (`serverId`, `tagId`)
                VALUES ?'
            ,   [bulk]
            ,   (err, resp) ->
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
            conn.query '
                SELECT
                    server.id,
                    server.name,
                    server.title,
                    server.key,
                    tag.id AS tagId,
                    tag.name AS tagName
                FROM server AS server
                JOIN server_tag AS connection
                    ON connection.serverId = server.id
                JOIN tag AS tag
                    ON tag.id = connection.tagId
                WHERE server.id = ?'
            ,   [req.params.serverId]
            ,   (err, rows) ->
                    server=
                        id: ''
                        name: ''
                        title: ''
                        key: ''
                        tags: []

                    rows.map (srv) ->
                        server.id= srv.id
                        server.name= srv.name
                        server.title= srv.title
                        server.key= srv.key
                        server.tags.push
                            id: srv.tagId
                            name: srv.tagName

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
    serverId= req.params.serverId
    delete req.body.id

    server= req.body

    tags= server.tags or []
    delete server.tags

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
            ,   [server, req.params.serverId]
            ,   (err, resp) ->
                    server.id= req.params.serverId
                    return done err, conn

        (conn, done) ->
            conn.query 'DELETE FROM server_tag WHERE serverId = ?'
            ,   [serverId]
            ,   (err, resp) ->
                    return done err, conn if err
                    return done err, conn if not tags.length

                    bulk= []
                    for tag in tags
                        bulk.push [serverId, tag.id]
                    conn.query '
                        INSERT INTO server_tag (`serverId`, `tagId`) VALUES ?
                        '
                    ,   [bulk]
                    ,   (err, resp) ->
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
