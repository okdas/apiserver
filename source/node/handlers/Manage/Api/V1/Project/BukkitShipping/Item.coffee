express= require 'express'
async= require 'async'

###
Методы API для работы c шипментами.
###
app= module.exports= do express
app.on 'mount', (parent) ->
    app.set 'maria', maria= parent.get 'maria'



    app.get '/:playerName/list'
    ,   maria(app.get 'db')
    ,   server(maria.Server)
    ,   player(maria.Player)
    ,   getItems(maria.BukkitShipping)
    ,   getItemsEnchantment(maria.BukkitShipping)
    ,   (req, res) ->
            res.json 200, req.items

    app.get '/:playerName/shipments/list'
    ,   maria(app.get 'db')
    ,   server(maria.Server)
    ,   player(maria.Player)
    ,   getShipments(maria.BukkitShipping)
    ,   (req, res) ->
            res.json 200, req.shipments

    app.post '/:playerName/shipments/open'
    ,   access
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   server(maria.Server)
    ,   player(maria.Player)
    ,   openShipment(maria.BukkitShipping)
    ,   maria.transaction.commit()
    ,   (req, res) ->
            res.json 200, req.shipment

    app.get '/:playerName/shipments/:shipmentId(\\d+)/close'
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   server(maria.Server)
    ,   player(maria.Player)
    ,   closeShipment(maria.BukkitShipping)
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



server= (Server) -> (req, res, next) ->
    return res.json 500, 'no key server' if not req.query.key

    Server.getByKey req.query.key, req.maria, (err, server) ->
        if server
            req.server= server
        else
            err=
                status: 404
                message: 'server not found'
        return next err



player= (Player) -> (req, res, next) ->
    Player.getByName req.params.playerName, req.maria, (err, player) ->
        if player
            req.player= player
        else
            err=
                status: 404
                message: 'player not found'
        return next err



getItems= (BukkitShipping) -> (req, res, next) ->
    BukkitShipping.queryItem req.player.id, req.server.id, req.maria, (err, items) ->
        req.items= items or null
        return next err

getItemsEnchantment= (BukkitShipping) -> (req, res, next) ->
    itemIds= []
    req.items.map (item, i) ->
        req.items[i].enchantments= []
        itemIds.push item.id

    BukkitShipping.queryEnchantment itemIds, req.maria, (err, enchantments) ->
        enchantments.map (ench) ->
            req.items.map (item, i) ->
                if item.id == ench.id
                    req.items[i].enchantments.push ench
        
        return next err



getShipments= (PlayerItem) -> (req, res, next) ->
    PlayerItem.get req.params.playerName, req.maria, (err, items) ->
        req.items= items or null
        return next err



openShipment= (PlayerItem) -> (req, res, next) ->
    PlayerItem.get req.params.playerName, req.maria, (err, items) ->
        req.items= items or null
        return next err



closeShipment= (PlayerItem) -> (req, res, next) ->
    PlayerItem.get req.params.playerName, req.maria, (err, items) ->
        req.items= items or null
        return next err







###
app.get '/:playerName/list', (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        # запрашиваем айтемы
        (conn, done) ->
            conn.query '
                SELECT
                    player.name AS playerName,
                    item.material,
                    item.titleRu,
                    item.amount,
                    item.id
                FROM player_item AS item
                JOIN player AS player
                    ON player.name = ?
                WHERE item.playerId = player.id AND item.amount > 0 AND item.serverId = ?'
            ,   [req.params.playerName, req.server.id]
            ,   (err, rows) ->
                    return done 'empty', conn if rows.length == 0
                    return done err, conn, rows

        # массив айтемов
        (conn, rows, done) ->
            player=
                playerName: ''
                items: []

            rows.map (item) ->
                player.playerName= item.playerName

                player.items.push
                    material: item.material
                    amount: item.amount
                    title: item.titleRu
                    id: item.id
                    enchantments: []

            return done null, conn, player

        # прицепляем энчаты
        (conn, player, done) ->
            idItems= []
            player.items.map (item) ->
                idItems.push item.id

            conn.query '
                SELECT
                    itemId AS id,
                    enchantmentId,
                    level
                FROM player_item_enchantment
                WHERE itemId IN (?)'
            ,   [idItems]
            ,   (err, rows) ->
                    return done 'empty', conn if rows.length == 0

                    rows.map (ench) ->
                        player.items.map (item, i) ->
                            if item.id == ench.id
                                player.items[i].enchantments.push ench

                    return done err, conn, player

    ],  (err, conn, rows) ->
            do conn.end if conn

            return next err if err
            return res.json 200, rows







app.post '/:playerName/shipments/open', (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            # чекаем айтемы и их количество
            idItems= []
            req.body.map (item) ->
                idItems.push item.id

            conn.query '
                SELECT
                    id,
                    amount
                FROM player_item
                WHERE id IN (?)'
            ,   [idItems]
            ,   (err, rows) ->
                    return done 'empty', conn if rows.length == 0

                    # как открыли шипмент дадут id шипмента
                    shipment=
                        id: ''
                        items: []

                    # проверяем amount шипментов
                    rows.map (tableItem) ->
                        req.body.map (reqItem) ->
                            if tableItem.id == parseInt reqItem.id
                                shipment.items.push
                                    id: tableItem.id
                                    amount: parseInt (if reqItem.amount > tableItem.amount then tableItem.amount else reqItem.amount)

                    return done err, conn, shipment

        (conn, shipment, done) ->
            # открываем шипмент
            conn.query '
                INSERT INTO player_shipment
                SET
                    playerId = (SELECT id FROM player WHERE name = ?),
                    serverId = ?'
            ,   [req.params.playerName, req.server.id]
            ,   (err, resp) ->
                    # как открыли шипмент дадут id шипмента
                    shipment.id= resp.insertId

                    return done err, conn, shipment

        (conn, shipment, done) ->
            # подготовим массив для инсерта
            shipmentItems= []
            shipment.items.map (item, i) ->
                shipmentItems.push [shipment.id, item.id, item.amount]

            # выборку сделали, открываем шипмент
            conn.query '
                INSERT INTO
                    player_shipment_items (`shipmentId`, `playerItemId`, `amount`)
                VALUES ?'
            ,   [shipmentItems]
            ,   (err, resp) ->
                    # айтемы пихнули в шипмент теперь можно этот массив игроку отослать
                    return done err, conn, shipment

        (conn, shipment, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn, shipment

    ],  (err, conn, shipment) ->
            do conn.end if conn

            return next err if err
            return res.json 200, shipment


app.get '/:playerName/shipments/:shipmentId(\\d+)/close', (req, res, next) ->
        async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            # ищем айтемы шипмента
            conn.query '
                SELECT
                    shipmentItem.playerItemId,
                    playerItem.amount AS playerAmount,
                    shipmentItem.amount AS shipmentAmount
                FROM player_shipment_items AS shipmentItem
                JOIN player_item AS playerItem
                    ON playerItem.id = playerItemId
                WHERE shipmentId = ?'
            ,   [req.params.shipmentId]
            ,   (err, items) ->
                    return done 'empty', conn if items.length == 0

                    # получили айтемы теперь вычитаем количество
                    updateItem=[]

                    items.map (item, i) ->
                        updateItem.push
                            itemId: item.playerItemId
                            amount: (item.playerAmount - item.shipmentAmount)

                    return done err, conn, updateItem

        (conn, updateItem, done) ->
            # обновляем оставшееся количество на складе игрока
            updateItem.map (item, i) ->
                conn.query '
                    UPDATE player_item
                        SET amount = ?
                    WHERE id = ?'
                ,   [item.amount, item.itemId]
                ,   (err, resp) ->
                        return done err, conn if err

            return done null, conn

        (conn, done) ->
            # обновляем шипмент - выставляем дату закрытия
            conn.query '
                UPDATE player_shipment
                    SET closedAt = NOW()
                WHERE id = ?'
            ,   [req.params.shipmentId]
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
