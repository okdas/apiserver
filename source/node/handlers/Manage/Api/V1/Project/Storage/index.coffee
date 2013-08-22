express= require 'express'
async= require 'async'

###
Методы API для работы c серверами.
###
app= module.exports= do express



###
Список товаров игрока
###
app.get '/:playerName/list', (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

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
                    console.log rows
                    return done err, conn, rows

        (conn, rows, done) ->
            player=
                playerName: ''
                items: []

            rows.map (item) ->
                player.playerName= item.playerName

                player.items.push
                    material: item.material
                    amount: item.amount
                    titleRu: item.titleRu
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
                    rows.map (ench) ->
                        player.items.map (item, i) ->
                            if item.id == ench.id
                                player.items[i].enchantments.push ench

                    return done err, conn, player

    ],  (err, conn, rows) ->
            do conn.end if conn

            return next err if err
            return res.json 200, rows



###
Выводит историю отгрузок (шипментов)
###
app.get '/:playerName/shipments/list', (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query '
                SELECT
                    shipment.id,
                    shipment.createdAt,
                    shipment.closedAt
                FROM player AS player
                JOIN player_shipment AS shipment
                    ON shipment.playerId = player.id AND shipment.serverId = ?
                WHERE player.name = ?'
            ,   [req.server.id, req.params.playerName]
            ,   (err, rows) ->
                    return done err, conn, rows

    ],  (err, conn, rows) ->
            do conn.end if conn

            return next err if err
            return res.json 200, rows



###
Открывает шипмент
###
app.post '/:playerName/shipments/open', (req, res, next) ->
    ###
    прислали кучу айтемов что делать:
    1. нам прислали реальные id и реальное количество то есть ошибки быть не может
       и проверять не нужно
    2. сразу создаем шипмент с этими айтемами

    req.body= [
        {
            id: '5',
            amount: 10
        },
        {
            id: '7',
            amount: '2'
        }
    ]
    нахер это все, перево
    ###
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            # открываем шипмент
            conn.query '
                INSERT INTO player_shipment
                SET
                    playerId = (SELECT id FROM player WHERE name = ?),
                    serverId = ?'
            ,   [req.params.playerName, req.server.id]
            ,   (err, resp) ->
                    # как открыли шипмент дадут id шипмента
                    shipment=
                        id: resp.insertId
                        items: req.body

                    return done err, conn, shipment

        (conn, shipment, done) ->
            # подготовим массив для инсерта
            shipmentItems= []
            shipment.items.map (item, i) ->
                shipmentItems.push [shipment.id, item.id, item.amount]

            console.log shipmentItems

            # выборку сделали, открываем шипмент
            conn.query '
                INSERT INTO
                    player_shipment_items (`shipmentId`, `plyerItemId`, `amount`)
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



###
Закрывает шипмент
###
app.get '/:playerName/shipments/:shipmentId/close', (req, res, next) ->
    ###
    1. надо получить все айтемы шипмента, записать массив
    2. вычест количество из storage_item, сделать там апдейт
    3. закрыть шипмент - указать дату закрытия
    ###
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
