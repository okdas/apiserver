express= require 'express'
async= require 'async'



###
Методы API для работы c серверами.
###
app= module.exports= do express
app.on 'mount', (parent) ->
    app.set 'maria', maria= parent.get 'maria'



    app.post '/'
    ,   access
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   createServer(maria.Server)
    ,   createServerTags(maria.ServerTag)
    ,   maria.transaction.rollback()
    ,   (req, res) ->
            res.json 200, req.server

    app.get '/'
    ,   access
    ,   maria(app.get 'db')
    ,   getServers(maria.Server)
    ,   (req, res) ->
            res.json 200, req.servers

    app.get '/:serverId(\\d+)'
    ,   access
    ,   getServer
    ,   (req, res) ->
            res.json 200

    app.put '/:serverId(\\d+)'
    ,   access
    ,   changeServer
    ,   (req, res) ->
            res.json 200

    app.delete '/:serverId(\\d+)'
    ,   access
    ,   deleteServer
    ,   (req, res) ->
            res.json 200



access= (req, res, next) ->
    err= null

    if do req.isUnauthenticated
        res.status 401
        err=
            message: 'user not authenticated'

    return next err



###
Добавляет сервер.
###
createServer= (Server) -> (req, res, next) ->
    console.log 'creating server'
    server= new Server req.body
    Server.create server, req.maria, (err, server) ->
        req.server= server or null
        console.log 'err creating server:', err
        return next err

createServerTags= (ServerTag) -> (req, res, next) ->
    console.log 'creating server tags'
    console.log 'server', req.server
    serverTag= new ServerTag req.body.tags
    console.log 'tags', serverTag.tags
    ServerTag.create req.server.id, serverTag, req.maria, (err, serverTags) ->
        req.server.tags= serverTags or null
        console.log 'err creating server tags:', err
        return next err



###
Отдает список серверов.
###
getServers= (Server) -> (req, res, next) ->
    Server.query req.maria, (err, servers) ->
        req.servers= servers or null

        if not err and not servers
            err= 'servers not found'

        return next err





###
Отдает сервер.
###
getServer= (req, res, next) ->
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
                LEFT JOIN server_tag AS connection
                    ON connection.serverId = server.id
                LEFT JOIN tag AS tag
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
changeServer= (req, res, next) ->
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
deleteServer= (req, res, next) ->
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



testServer= (Server) -> (req, res, next) ->
        serv= new Server
            id: 'qq'
        console.log 'serv', serv.id
        res.send 200
