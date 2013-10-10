module.exports= class Item
    @table: 'player_server_item'
    @original: 'item'
    @originalPlayer: 'player'
    @originalShipment: 'player_shipment'
    @originalShipmentItem: 'player_shipment_items'



    @create: (player, maria, done) ->
        return done 'not a Player' if not (player instanceof @)

        delete player.id if player.id
        delete player.createdAt if player.createdAt
        delete player.updatedAt if player.updatedAt

        maria.query '
            INSERT
            INTO
                ??
            SET
                ?'
        ,   [@table, player]
        ,   (err, res) ->
                if not err && res.affectedRows != 1
                    err= 'player insert error'

                player.id= res.insertId

                done err, player



    @query: (playerId, serverId, maria, done) ->
        maria.query '
            SELECT
                connection.id,
                item.material,
                item.titleRu,
                connection.amount
            FROM
                ?? AS connection
            JOIN
                ?? AS item
                ON item.id = connection.itemId
            WHERE
                connection.playerId = ?
                AND
                connection.amount > 0
                AND
                connection.serverId = ?'
        ,   [@table, @original, playerId, serverId]
        ,   (err, rows) =>
                done err, rows



    @get: (itemIds, maria, done) ->
        maria.query '
            SELECT
                connection.id,
                connection.amount
            FROM
                ?? AS connection
            WHERE
                connection.id IN (?)'
        ,   [@table, @original, itemIds]
        ,   (err, rows) =>
                done err, rows





    @queryShipment: (playerId, serverId, maria, done) ->
        maria.query '
            SELECT
                shipment.id,
                shipment.createdAt,
                shipment.closedAt
            FROM
                ?? AS shipment
            WHERE
                shipment.playerId = ?
                AND
                shipment.serverId = ?'
        ,   [@originalShipment, playerId, serverId]
        ,   (err, rows) =>
                done err, rows



    ###
    прислали кучу айтемов что делать:
    1. нам прислали id из player_item и реальное количество то есть ошибки быть не может
       и проверять не нужно (но! всетаки проверим)
    2. сразу создаем шипмент с этими айтемами

    req.body= [
        {
            id: '5', # это id из player_item
            amount: 10
        },
        {
            id: '7',
            amount: '2'
        }
    ]
    ###
    @openShipment: (playerId, serverId, maria, done) ->
        maria.query '
            INSERT
            INTO
                player_shipment
            SET
                playerId = ?,
                serverId = ?'
        ,   [@originalShipment, playerId, serverId]
        ,   (err, res) ->
                id= res.insertId
                done err, id



    @createShipmentItems: (shipmentId, items, maria, done) ->
        data= []
        items.map (item) ->
            data.push [shipmentId, item.itemId, item.amount]
        maria.query '
            INSERT
            INTO
                ??
                (`shipmentId`, `playerItemId`, `amount`)
            VALUES
                ?'
        ,   [@originalShipmentItem, data]
        ,   (err, res) ->
                done err



    ###
    1. надо получить все айтемы шипмента, записать массив
    2. вычест количество из storage_item, сделать там апдейт
    3. закрыть шипмент - указать дату закрытия
    ###
    @closeShipment: (playerId, maria, done) ->
        return done 'not valid argument' if not playerId

        maria.query '
            UPDATE
                ??
            SET
                enabledAt = NOW()
            WHERE
                id = ?'
        ,   [@table, playerId]
        ,   (err, res) ->

                if not err and res.affectedRows != 1
                    err= 'player activate error'

                done err














###
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
