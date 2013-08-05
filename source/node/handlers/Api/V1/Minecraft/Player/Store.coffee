express= require 'express'
async= require 'async'

###
Методы API для работы c магазином.
###
app= module.exports= do express



###
Отдает магазин аутентифицированному игроку.
###
app.get '/', (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            # Извлечь все предметы магазина
            conn.query "
                SELECT
                    item.id as itemId,
                    item.title as itemTitle,
                    server.id as serverId,
                    server.title as serverTitle
                FROM store_item as item
                LEFT OUTER JOIN store_item_servers as itemServers
                    ON itemServers.itemId = item.id
                JOIN server as server
                    ON server.id= itemServers.serverId
                "
            ,   (err, rows) ->
                    return done err, conn, rows

        (conn, rows, done) ->
            servers= []
            serversIndex= {}
            serversItemsIndex= {}
            for row in rows
                server= serversIndex[row.serverId]
                if not server
                    server= serversIndex[row.serverId]=
                        id: row.serverId
                        title: row.serverTitle
                        store:
                            items: []
                        storage:
                            items: []
                    servers.push server
                    serversItemsIndex[row.serverId]= {}
                item= serversItemsIndex[row.serverId][row.itemId]
                if not item
                    item= serversItemsIndex[row.serverId][row.itemId]=
                        id: row.itemId
                        title: row.itemTitle
                        price: 1
                    server.store.items.push item
            return done null, conn, servers

    ],  (err, conn, servers) ->
            do conn.end if conn

            return next err if err
            return res.json 200,
                servers: servers



###
Выставляет счет на покупку переданных предметов аутентифицированному игроку.
###
app.post '/order', (req, res, next) ->
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
                playerId: req.user.id
            conn.query 'INSERT INTO store_order SET ?'
            ,   [data]
            ,   (err, resp) ->
                    id= resp.insertId if not err
                    return done err, conn, id

        (conn, id, done) ->
            bulk= []
            for server in req.body.servers
                for item in server.items
                    bulk.push [req.user.id, server.id, id, item.id, item.amount]
            conn.query 'INSERT INTO storage_item (`playerId`, `serverId`, `orderId`, `itemId`, `amount`) VALUES ?'
            ,   [bulk]
            ,   (err, resp) ->
                    done err, conn

        (conn, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn

    ],  (err, conn) ->
            do conn.end if conn
            return next err if err
