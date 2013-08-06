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
    return res.json 400, null if not req.body.servers or not req.body.servers.length

    order=
        id: null
        items: []
    for server in req.body.servers
        continue if not server.items or not server.items.length
        for item in server.items
            order.items.push
                serverId: server.id
                itemId: item.id
                itemAmount: item.amount

    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) -> # получить доступные для покупки предметы и подсчитать стоимость

            serverIds= []
            itemIds= []
            for item in order.items
                serverId= item.serverId
                itemId= item.itemId
                serverIds.push serverId if not ~serverIds.indexOf serverId
                itemIds.push itemId if not ~itemIds.indexOf itemId

            conn.query "
                SELECT
                    item.id,
                    item.price
                FROM store_item as item
                JOIN store_item_servers as itemServers
                    ON itemServers.itemId = item.id AND itemServers.serverId IN (?)
                JOIN server as itemServer
                    ON itemServer.id = itemServers.serverId
                WHERE item.id IN (?)
                GROUP BY
                    item.id
                "
            ,   [serverIds, itemIds]
            ,   (err, items) ->
                    return done err, conn if err

                    price= 0
                    for item, i in order.items
                        found= false
                        for itm in items
                            if itm.id == item.itemId
                                price= price + item.itemAmount * itm.price
                                found= true
                                break
                        if not found
                            order.items.splice i, 1

                    return done err, conn, price

        (conn, price, done) ->
            data= [[req.user.id, price]]
            conn.query "
                INSERT INTO store_order (playerId, price)
                VALUES ?
                "
            ,   [data]
            ,   (err, resp) ->
                    orderId= resp.insertId if not err
                    return done err, conn, orderId

        (conn, orderId, done) ->
            bulk= []
            for item in order.items
                bulk.push [orderId, item.itemId, item.serverId, item.itemAmount]
            conn.query "
                INSERT INTO store_order_items (orderId, itemId, serverId, amount)
                VALUES ?
                "
            ,   [bulk]
            ,   (err, resp) ->
                    done err, conn

        (conn, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn

    ],  (err, conn) ->
            do conn.end if conn
            return next err if err

            return res.json 201, {}
