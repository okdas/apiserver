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
                    item.title,
                    material.materialId,
                    storageItem.amount
                FROM storage_item AS storageItem
                JOIN material AS material
                JOIN item as item
                    ON material.id = item.material
                JOIN player AS player
                    ON player.name = ?
                WHERE
                    storageItem.itemId = item.id AND storageItem.playerId = player.id AND storageItem.serverId = ?'
            ,   [req.params.playerName,req.server.id]
            ,   (err, rows) ->
                    return done err, conn, rows

        (conn, rows, done) ->
            player=
                playerName: ''
                items: []

            for row in rows
                player.playerName= row.playerName

                player.items.push
                    materialId: row.materialId
                    title: row.title
                    amount: row.amount


            return done null, conn, player

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
                JOIN storage_shipment AS shipment
                    ON shipment.playerId = player.id AND shipment.serverId = ?
                WHERE player.name = ?'
            ,   [req.server.id,req.params.playerName]
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
    1. проверить имеем ли мы такие айтемы на складе этого игрока
    2. проверить количество, если запросили больше выдать сколько можно
    3. открыть шипмент с теми айтемами которые мы выдадим
    4. записать в storage_shipment_item айтемы которые выдадим

    req.body= [
        {
            materialId: '5',
            amount: 10
        },
        {
            materialId: '7',
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
            materialIdArr= []
            req.body.map (val, i) ->
                materialIdArr.push val.materialId

            # выбираем айтемы игрока
            conn.query '
                SELECT
                    player.name AS playerName,
                    item.id,
                    item.materialId,
                    item.amount
                FROM player AS player
                JOIN storage_item AS item
                    ON item.playerId = player.id AND item.serverId = ? AND item.materialId IN (?)
                WHERE player.name = ?'
            ,   [req.server.id, materialIdArr, req.params.playerName]
            ,   (err, rows) ->
                    # теперь нам нужно посчитать количество айтемов которые отдадим
                    playerResItems=
                        playerName: ''
                        shipmentId: ''
                        items: []

                    rows.map (row, i) ->
                        playerResItems.playerName= row.playerName

                        # ищем нужный айтем в массиве который получили от плагина
                        reqEqualItem= {}
                        req.body.map (item, i) ->
                            reqEqualItem= item if item.materialId == row.materialId

                        # смотрим amount, если больше даем сколько есть иначе сколько запросили
                        realAmount= parseInt (if reqEqualItem.amount > row.amount then row.materialId else reqEqualItem.amount)

                        # пихаем в массив, айтем
                        playerResItems.items.push
                            id: row.id
                            materialId: row.materialId
                            amount: realAmount

                    return done err, conn, playerResItems

        (conn, playerResItems, done) ->
            # выборку сделали, открываем шипмент
            conn.query '
                INSERT INTO storage_shipment
                SET
                    playerId = (SELECT id FROM player WHERE name = ?),
                    serverId = ?'
            ,   [req.params.playerName, req.server.id]
            ,   (err, resp) ->
                    # как открыли шипмент дадут id шипмента
                    playerResItems.shipmentId= resp.insertId
                    return done err, conn, playerResItems

        (conn, playerResItems, done) ->
            # подготовим массив для инсерта
            shipmentItems= []
            playerResItems.items.map (item, i) ->
                shipmentItems.push [playerResItems.shipmentId, item.id, item.amount]

            console.log shipmentItems

            # выборку сделали, открываем шипмент
            conn.query '
                INSERT INTO
                    storage_shipment_item (`shipmentId`, `itemId`, `amount`)
                VALUES ?'
            ,   [shipmentItems]
            ,   (err, resp) ->
                    # айтемы пихнули в шипмент теперь можно этот массив игроку отослать
                    return done err, conn, playerResItems

        (conn, playerResItems, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn, playerResItems

    ],  (err, conn, playerResItems) ->
            do conn.end if conn

            return next err if err
            return res.json 200, playerResItems



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
                    shipmentItem.itemId AS shipmentItemId,
                    shipmentItem.amount AS shipmentItemAmount,
                    storageItem.amount AS storageItemAmount
                FROM storage_shipment_item AS shipmentItem
                JOIN storage_item AS storageItem
                    ON storageItem.id = shipmentItem.itemId
                WHERE shipmentId = ?'
            ,   [req.params.shipmentId]
            ,   (err, items) ->
                    # получили айтемы теперь вычитаем количество
                    updateItem=[]

                    items.map (item, i) ->
                        updateItem.push
                            itemId: item.shipmentItemId
                            amount: (item.storageItemAmount - item.shipmentItemAmount)

                    return done err, conn, updateItem

        (conn, updateItem, done) ->
            # обновляем оставшееся количество на складе игрока
            updateItem.map (item, i) ->
                conn.query '
                    UPDATE storage_item
                        SET amount = ?
                    WHERE id = ?'
                ,   [item.amount, item.itemId]
                ,   (err, resp) ->
                        return done err, conn if err

            return done null, conn

        (conn, done) ->
            # обновляем шипмент - выставляем дату закрытия
            conn.query '
                UPDATE storage_shipment
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
