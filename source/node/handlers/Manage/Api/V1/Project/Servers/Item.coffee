express= require 'express'
async= require 'async'

access= (req, res, next) ->
    return next 401 if do req.isUnauthenticated
    return do next

###
Методы API для работы c предметами.
###
app= module.exports= do express



###
Добавляет предмет.
###
app.post '/', access, (req, res, next) ->
    console.log '!!!!!!!!!', req.body

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
                material: req.body.material
                titleRu: req.body.titleRu
                titleEn: req.body.titleEn
                price: req.body.price
                amount: req.body.amount

            conn.query 'INSERT INTO item SET ?'
            ,   [data]
            ,   (err, resp) ->
                    id= resp.insertId if not err
                    return done err, conn, id

        (conn, id, done) ->
            # а есть ли вобще энчаты у предмета
            if not req.body.enchantments
                return done null, conn, id

            bulk= []
            for enchantment, order in req.body.enchantments
                bulk.push [id, enchantment.id, enchantment.level, order]
            conn.query '
                INSERT INTO item_enchantment
                    (`itemId`, `enchantmentId`, `level`, `order`)
                VALUES ?'
            ,   [bulk]
            ,   (err, resp) ->
                    return done err, conn, id

        (conn, id, done) ->
            # а есть ли сервера
            if not req.body.servers
                return done null, conn

            bulk= []
            for server in req.body.servers
                bulk.push [id, server.id]
            conn.query "
                INSERT INTO server_item
                    (`itemId`, `serverId`)
                VALUES ?
                "
            ,   [bulk]
            ,   (err, resp) ->
                    return done err, conn

        (conn, done) ->
            conn.query 'COMMIT', (err) ->
                console.log err
                return done err, conn

    ],  (err, conn) ->
            do conn.end if conn

            return next err if err
            return res.json 201, req.body



###
Отдает список предметов.
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
Отдает предмет.
###
app.get '/:itemId', access, (req, res, next) ->
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

    ],  (err, conn, item) ->
            do conn.end if conn

            return next err if err
            return res.json 404, null if not item
            return res.json 200, item



###
Обновляет предмет.
###
app.put '/:itemId', access, (req, res, next) ->
    itemId= req.params.itemId
    delete req.body.id

    item= req.body

    enchantments= item.enchantments or []
    delete item.enchantments

    servers= item.servers or []
    delete item.servers

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
            conn.query 'COMMIT', (err) ->
                return done err, conn

    ],  (err, conn) ->
            do conn.end if conn

            return next err if err
            return res.json 200, req.body



###
Удаляет предмет.
###
app.delete '/:itemId', access, (req, res, next) ->
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
