express= require 'express'



###
Методы API для работы c предметами.
###
app= module.exports= do express
app.on 'mount', (parent) ->
    app.set 'maria', maria= parent.get 'maria'



    app.post '/'
    ,   access
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   createItem(maria.Item)
    ,   maria.transaction.commit()
    ,   (req, res) ->
            res.json 200, req.item

    app.get '/'
    ,   access
    ,   maria(app.get 'db')
    ,   getItems(maria.Item)
    ,   getItemsServer(maria.ItemServer)
    ,   (req, res) ->
            res.json 200, req.items

    app.get '/:itemId(\\d+)'
    ,   access
    ,   maria(app.get 'db')
    ,   getItem(maria.Item)
    ,   getItemServer(maria.ItemServer)
    ,   getItemTag(maria.ItemTag)
    ,   getItemEnchantment(maria.ItemEnchantment)
    ,   (req, res) ->
            res.json 200, req.item

    app.put '/:itemId(\\d+)'
    ,   access
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   updateItem(maria.Item)
    ,   maria.transaction.commit()
    ,   (req, res) ->
            res.json 200, req.item

    app.delete '/:itemId(\\d+)'
    ,   access
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   deleteItem(maria.Item)
    ,   maria.transaction.commit()
    ,   (req, res) ->
            res.json 200



access= (req, res, next) ->
    err= null
    if do req.isUnauthenticated
        err=
            status: 401
            message: 'user not authenticated'

    return next err





createItem= (Item) -> (req, res, next) ->
    console.log 'REQ', req.body
    newItem= new Item req.body
    Item.create newItem, req.maria, (err, item) ->
        req.item= item or null
        return next err

createItemServer= (ItemServer) -> (req, res, next) ->
    newItemServer= new ItemServer req.body.servers
    ItemServer.create req.item.id, newItemServer, req.maria, (err, item) ->
        req.item= item or null
        return next err

createItemTag= (ItemTag) -> (req, res, next) ->
    newItemTag= new ItemTag req.body.tags
    ItemTag.create req.item.id,  newItemTag, req.maria, (err, item) ->
        req.item= item or null
        return next err

createItemEnchantment= (ItemEnchantment) -> (req, res, next) ->
    newItemEnchantment= new ItemEnchantment req.body.enchantment
    ItemEnchantment.create req.item.id, newItemEnchantment, req.maria, (err, item) ->
        req.item= item or null
        return next err



###
Отдает список серверов.
###
getItems= (Item) -> (req, res, next) ->
    Item.query req.maria, (err, items) ->
        req.items= items or null
        return next err

getItemsServer= (ItemServer) -> (req, res, next) ->
    ItemServer.query req.maria, (err, servers) ->
        req.items.map (item, i) ->
            req.items[i].servers= []

            servers.map (row) ->
                if item.id == row.itemId
                    req.items[i].servers.push row
        return next err

getItemsTag= (ItemTag) -> (req, res, next) ->
    ItemTag.query req.maria, (err, tags) ->
        req.items.map (item, i) ->
            req.items[i].tags= []

            tags.map (row) ->
                if item.id == row.itemId
                    req.items[i].tags.push row
        return next err





###
Отдает айтем.
###
getItem= (Item) -> (req, res, next) ->
    Item.get req.params.itemId, req.maria, (err, item) ->
        req.item= item or null
        return next err

getItemServer= (ItemServer) -> (req, res, next) ->
    ItemServer.get req.params.itemId, req.maria, (err, servers) ->
        req.item.servers= servers
        return next err

getItemTag= (ItemTag) -> (req, res, next) ->
    ItemTag.get req.params.itemId, req.maria, (err, tags) ->
        req.item.tags= tags
        return next err

getItemEnchantment= (ItemEnchantment) -> (req, res, next) ->
    ItemEnchantment.get req.params.itemId, req.maria, (err, enchantments) ->
        req.item.enchantments= enchantments
        return next err



###
Изменяет сервер
###
updateItem= (Item) -> (req, res, next) ->
    newItem= new Item req.body
    Item.update req.params.itemId, newItem, req.maria, (err, instance) ->
        req.item= item or null
        return next err





###
Удаляет сервер
###
deleteItem= (Item) -> (req, res, next) ->
    Item.delete req.params.itemId, req.maria, (err) ->
        return next err






###
Отдает список предметов.
###
###
app.get '/', access, (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query 'SELECT * FROM item'
            ,   (err, rows) ->
                    return done err, conn, rows

        (conn, items, done) ->
            itemIds= []

            items.map (item) ->
                item.servers= []
                itemIds.push item.id

            conn.query '
                SELECT
                    connection.itemId,
                    server.id AS serverId,
                    server.title
                FROM server_item AS connection
                JOIN server AS server
                    ON server.id = connection.serverId
                WHERE itemId IN (?)'
            ,   [itemIds]
            ,   (err, rows) ->
                    items.map (item) ->
                        rows.map (server) ->
                            if item.id == server.itemId
                                item.servers.push server

                    return done err, conn, items

    ],  (err, conn, rows) ->
            do conn.end if conn

            return next err if err
            return res.json 200, rows
###


###
Отдает предмет.
###
###
app.get '/:itemId(\\d+)', access, (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query 'SELECT * FROM item WHERE id = ?'
            ,   [req.params.itemId]
            ,   (err, resp) ->
                    item= do resp.shift if not err
                    return done err, conn, item

        (conn, item, done) ->
            conn.query '
                SELECT
                    ofBukkit.id,
                    ofBukkit.titleRu,
                    ofBukkit.titleEn,
                    ofItem.level,
                    ofBukkit.levelMax,
                    ofItem.order
                FROM item_enchantment AS ofItem
                JOIN bukkit_enchantment AS ofBukkit
                    ON ofBukkit.id = ofItem.enchantmentId
                WHERE ofItem.itemId = ?
                ORDER BY ofItem.order'
            ,   [req.params.itemId]
            ,   (err, resp) ->
                    item.enchantments= resp
                    return done err, conn, item

        (conn, item, done) ->
            conn.query '
                SELECT
                    connection.id,
                    server.id,
                    server.title
                FROM server_item AS connection
                JOIN server AS server
                    ON server.id = connection.serverId
                WHERE itemId = ?'
            ,   [req.params.itemId]
            ,   (err, resp) ->
                    item.servers= resp
                    return done err, conn, item

        (conn, item, done) ->
            conn.query '
                SELECT
                    tag.*
                FROM item_tag AS connection
                JOIN tag AS tag
                    ON tag.id = connection.tagId
                WHERE itemId = ?'
            ,   [req.params.itemId]
            ,   (err, resp) ->
                    item.tags= resp
                    return done err, conn, item

    ],  (err, conn, item) ->
            do conn.end if conn

            return next err if err
            return res.json 404, null if not item
            return res.json 200, item
###


###
Обновляет предмет.
###
###
app.put '/:itemId(\\d+)', access, (req, res, next) ->
    itemId= req.params.itemId
    delete req.body.id

    item= req.body

    enchantments= item.enchantments or []
    delete item.enchantments

    servers= item.servers or []
    delete item.servers

    tags= item.tags or []
    delete item.tags

    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            conn.query 'UPDATE item SET ? WHERE id = ?'
            ,   [item, req.params.itemId]
            ,   (err, resp) ->
                    console.log arguments
                    return done err, conn

        (conn, done) ->
            conn.query 'DELETE FROM item_enchantment WHERE itemId = ?'
            ,   [itemId]
            ,   (err, resp) ->
                    return done err, conn if err
                    return done err, conn if not enchantments.length

                    bulk= []
                    for enchantment, order in enchantments
                        bulk.push [itemId, enchantment.id, enchantment.level, order]
                    conn.query "
                        INSERT INTO item_enchantment (`itemId`, `enchantmentId`, `level`, `order`) VALUES ?
                        "
                    ,   [bulk]
                    ,   (err, resp) ->
                            return done err, conn

        (conn, done) ->
            conn.query 'DELETE FROM server_item WHERE itemId = ?'
            ,   [itemId]
            ,   (err, resp) ->
                    return done err, conn if err
                    return done err, conn if not servers.length

                    bulk= []
                    for server in servers
                        bulk.push [itemId, server.id]
                    conn.query 'INSERT INTO server_item (`itemId`, `serverId`) VALUES ?'
                    ,   [bulk]
                    ,   (err, resp) ->
                            return done err, conn

        (conn, done) ->
            conn.query 'DELETE FROM item_tag WHERE itemId = ?'
            ,   [itemId]
            ,   (err, resp) ->
                    return done err, conn if err
                    return done err, conn if not tags.length

                    bulk= []
                    for tag in tags
                        bulk.push [itemId, tag.id]
                    conn.query 'INSERT INTO item_tag (`itemId`, `tagId`) VALUES ?'
                    ,   [bulk]
                    ,   (err, resp) ->
                            return done err, conn

        (conn, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn

    ],  (err, conn) ->
            do conn.end if conn

            return next err if err
            return res.json 200, req.body
###


###
Удаляет предмет.
###
###
app.delete '/:itemId(\\d+)', access, (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query 'DELETE FROM item WHERE id = ?'
            ,   [req.params.itemId]
            ,   (err, resp) ->
                    item= {} if not err
                    return done err, conn, item

    ],  (err, conn, item) ->
            do conn.end if conn

            return next err if err
            return res.json 200, item
###
