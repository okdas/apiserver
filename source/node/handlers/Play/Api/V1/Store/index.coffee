express= require 'express'
async= require 'async'

access= (req, res, next) ->
    return next 401 if do req.isUnauthenticated
    return do next


class Item
    constructor: (data) ->
        @id= data.itemId
        @name= data.itemName
        @titleRu= data.itemTitleRu
        @titleEn= data.itemTitleEn
        @price= data.itemPrice
        @material= data.itemMaterial
        @imageUrl= data.itemImageUrl
        @enchantability= data.itemEnchantability
        
        @enchantments= [] if data.itemEnchantability


class Enchantment
    constructor: (data) ->
        @id= data.enchantmentId
        @titleRu= data.enchantmentTitleRu
        @titleEn= data.enchantmentTitleEn
        @levelMax= data.enchantmentLevelMax
        @level= data.enchantmentLevel
        @order= data.enchantmentOrder


###
Методы API для работы c магазином.
###
app= module.exports= do express



###
Отдает магазин аутентифицированному игроку.
###
app.get '/', access, (req, res, next) ->
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
                    item.price as itemPrice,
                    server.id as serverId,
                    server.name as serverName,
                    server.title as serverTitle
                FROM ?? as Item
                LEFT OUTER JOIN store_item_servers as itemServers
                    ON itemServers.itemId = item.id
                JOIN server as server
                    ON server.id= itemServers.serverId
                "
            ,   ['item']
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
                        name: row.serverName
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
                        price: row.itemPrice
                    server.store.items.push item
            return done null, conn, servers

    ],  (err, conn, servers) ->
            do conn.end if conn

            return next err if err
            return res.json 200,
                servers: servers



app.get '/servers', access, (req, res, next) ->

    servers= []

    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            # Извлечь все предметы магазина
            conn.query "
                SELECT
                    Server.id,
                    Server.name,
                    Server.title

                FROM
                    ?? as Server
                "
            ,   ['server']
            ,   (err, rows) ->
                    servers= rows if not err
                    return done err, conn

    ],  (err, conn) ->
            do conn.end if conn

            return next err if err
            return res.json 200, servers



app.post '/servers/:serverId(\\d+)/order', access, (req, res, next) ->
    console.log req.body, req.params

    playerId= req.user.id
    serverId= req.body.serverId

    itemIds= []
    itemIdx= {}
    for item in req.body.items
        itemIds.push item.id
        itemIdx[item.id]= item

    price= 0
    balance= 0

    items= []
    enchantments= []

    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            conn.query "
                SELECT
                    Item.id,
                    Item.material,
                    Item.titleRu,
                    Item.titleEn,
                    Item.price
                FROM
                    ?? as ServerItem
                JOIN
                    ?? as Item
                    ON Item.id = ServerItem.itemId
                WHERE
                    serverId = ? AND itemId IN(?)
                "
            ,   ['server_item', 'item', serverId, itemIds]
            ,   (err, rows) ->
                    if not err
                        for row in rows
                            amount= itemIdx[row.id].amount
                            price= price + row.price * amount
                            items.push [serverId, playerId, row.material, row.titleRu, row.titleEn, row.name, amount]

                            item= itemIdx[row.id]
                            if item.enchantments and item.enchantments.length
                                for enchantment in item.enchantments
                                    enchantments.push [item.id, enchantment.id, enchantment.level]

                    return done err, conn

        (conn, done) ->
            conn.query "
                SELECT
                    PlayerBalance.amount
                FROM
                    ?? as PlayerBalance
                WHERE
                    PlayerBalance.playerId = ?
                "
            ,   ['player_balance', playerId]
            ,   (err, rows) ->
                    if not err
                        row= do rows.shift
                        balance= row.amount
                        console.log 'надо', price, 'есть', balance
                        return done 'not enought money', conn if price > balance
                    return done err, conn

        (conn, done) ->
            conn.query "
                UPDATE
                    ?? as PlayerBalance
                SET
                    PlayerBalance.amount = PlayerBalance.amount - ?
                WHERE
                    PlayerBalance.playerId = ?
                "
            ,   ['player_balance', price, playerId]
            ,   (err, resp) ->
                    return done err, conn

        (conn, done) ->
            conn.query "
                INSERT INTO ?? (
                    `serverId`,
                    `playerId`,
                    `material`,
                    `titleRu`,
                    `titleEn`,
                    `name`,
                    `amount`
                )
                    VALUES ?
                "
            ,   ['player_item', items]
            ,   (err, resp) ->
                    return done err, conn

        (conn, done) ->
            conn.query "
                INSERT INTO ?? (
                    `itemId`,
                    `enchantmentId`,
                    `level`
                )
                    VALUES ?
                "
            ,   ['player_item_enchantment', enchantments]
            ,   (err, resp) ->
                    return done err, conn

        (conn, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn

    ],  (err, conn) ->
            do conn.end if conn

            return next err if err
            return next 201, true


app.get '/servers/:serverName', access, (req, res, next) ->

    serverName= req.params.serverName
    server= null

    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query "
                SELECT
                    Server.id,
                    Server.name,
                    Server.title

                FROM
                    ?? as Server

                WHERE
                    Server.name = ?
                "
            ,   ['server', serverName]
            ,   (err, rows) ->
                    server= do rows.shift if not err and rows.length
                    return done err, conn

        (conn, done) ->
            return done null, conn if not server
            conn.query "
                SELECT
                    *,
                    Item.id as itemId,
                    Item.name as itemName,
                    Item.titleRu as itemTitleRu,
                    Item.titleEn as itemTitleEn,
                    Item.price as itemPrice,
                    Material.id as itemMaterial,
                    Material.imageUrl as itemImageUrl,
                    Material.enchantability as itemEnchantability,
                    Enchantment.id as enchantmentId,
                    Enchantment.titleRu as enchantmentTitleRu,
                    Enchantment.titleEn as enchantmentTitleEn,
                    Enchantment.levelmax as enchantmentLevelMax,
                    ItemEnchantment.level as enchantmentLevel,
                    ItemEnchantment.order as enchantmentOrder
                FROM
                    ?? as ServerItem
                JOIN
                    ?? as Item
                    ON Item.id = ServerItem.itemId
                JOIN
                    ?? as Material
                    ON Material.id = Item.material
                LEFT OUTER JOIN
                    ?? as ItemEnchantment
                    ON ItemEnchantment.itemId = Item.id AND Material.enchantability IS NOT NULL
                LEFT OUTER JOIN
                    ?? as Enchantment
                    ON Enchantment.id = ItemEnchantment.enchantmentId
                WHERE
                    ServerItem.serverId = ?
                "
            ,   ['server_item', 'item', 'bukkit_material', 'item_enchantment', 'bukkit_enchantment', server.id]
            ,   (err, rows) ->
                    server.items= []
                    if not err
                        itemIds= {}
                        for row in rows
                            item= itemIds[row.itemId]
                            if not item
                                server.items.push item= itemIds[row.itemId]= new Item row
                            if item.enchantability and row.enchantmentId
                                item.enchantments= [] if not item.enchantments
                                item.enchantments.push new Enchantment row
                    return done err, conn

    ],  (err, conn) ->
            do conn.end if conn

            return next err if err
            return res.json 404, server if not server
            return res.json 200, server



###
Выставляет счет на покупку переданных предметов аутентифицированному игроку.
###
app.post '/order', access, (req, res, next) ->
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
                    order.id= resp.insertId if not err
                    return done err, conn

        (conn, done) ->
            bulk= []
            for item in order.items
                bulk.push [order.id, item.itemId, item.serverId, item.itemAmount]
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

            return res.json 201, order



###
Отдает список заказов.
###
app.get '/order', access, (req, res, next) ->

    playerId= req.user.id

    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query "
                SELECT
                    o.id,
                    o.price,
                    o.createdAt
                FROM store_order as o
                WHERE o.playerId = ?
                ORDER BY o.createdAt DESC
                "
            ,   [playerId]
            ,   (err, orders) ->
                    return done err, conn, orders

    ],  (err, conn, orders) ->
            do conn.end if conn

            return next err if err
            return res.json 200, orders



###
Отдает заказ.
###
app.get '/order/:orderId', access, (req, res, next) ->

    order=
        id: req.params.orderId
        playerId: req.user.id
        servers: []

    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query "
                SELECT
                    o.id as orderId,
                    o.price as orderPrice,
                    i.id as itemId,
                    i.title as itemTitle,
                    oi.amount as itemAmount,
                    server.id as serverId
                FROM store_order as o
                JOIN store_order_items as oi
                    ON oi.orderId = o.id
                JOIN store_item as i
                    ON oi.itemId = i.id
                JOIN server
                    ON oi.serverId = server.id
                WHERE
                    o.id = ?
                    AND o.playerId = ?
                "
            ,   [order.id, order.playerId]
            ,   (err, rows) ->
                    return done err, conn if err
                    serverIds= {}
                    for row in rows
                        serverId= row.serverId
                        server= serverIds[serverId]
                        if not server
                            server= serverIds[serverId]=
                                id: serverId
                                items: []
                            order.servers.push server
                        server.items.push
                            id: row.itemId
                            title: row.itemTitle
                            amount: row.itemAmount
                    order.price= row.orderPrice
                    return done err, conn, order

    ],  (err, conn, order) ->
            do conn.end if conn

            return next err if err
            return res.json 200, order
