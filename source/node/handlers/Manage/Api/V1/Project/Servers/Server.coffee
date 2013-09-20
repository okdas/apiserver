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
    ,   maria.transaction.commit()
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
    ,   maria(app.get 'db')
    ,   getServer(maria.Server)
    ,   getServerTag(maria.ServerTag)
    ,   (req, res) ->
            res.json 200, req.server

    app.put '/:serverId(\\d+)'
    ,   access
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   updateServer(maria.Server)
    ,   updateServerTag(maria.ServerTag)
    ,   maria.transaction.commit()
    ,   (req, res) ->
            res.json 200

    app.delete '/:serverId(\\d+)'
    ,   access
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   deleteServer(maria.Server)
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



###
Добавляет сервер.
###
createServer= (Server) -> (req, res, next) ->
    server= new Server req.body
    Server.create server, req.maria, (err, server) ->
        req.server= server or null
        return next err

createServerTags= (ServerTag) -> (req, res, next) ->
    serverTag= new ServerTag req.body.tags
    ServerTag.create req.server.id, serverTag, req.maria, (err, tags) ->
        req.server.tags= tags or null
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
getServer= (Server) -> (req, res, next) ->
    Server.get req.params.serverId, req.maria, (err, server) ->
        req.server= server or null
        return next err

getServerTag= (ServerTag) -> (req, res, next) ->
    ServerTag.get req.params.serverId, req.maria, (err, tags) ->
        req.server.tags= tags or null
        return next err



###
Изменяет сервер
###
updateServer= (Server) -> (req, res, next) ->
    server= new Server req.body
    Server.update req.params.serverId, server, req.maria, (err, server) ->
        req.server= server or null
        return next err

updateServerTag= (ServerTag) -> (req, res, next) ->
    serverTag= new ServerTag req.body.tags
    ServerTag.create req.params.serverId, serverTag, req.maria, (err, tags) ->
        req.server.tags= tags or null
        return next err





###
Удаляет сервер
###
deleteServer= (Server) -> (req, res, next) ->
    Server.delete req.params.serverId, req.maria, (err) ->
        return next err



###
Удаляет сервер
###


deleteServerqqq= (req, res, next) ->
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
