






module.exports= class Item
    @table: 'player_server_item'
    @original: 'item'
    @originalPlayer: 'player'



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
                item.material,
                item.titleRu,
                connection.amount,
                player.name
            FROM ?? AS connection
            JOIN ?? AS item
                ON item.id = connection.itemId
            JOIN ?? AS player
                ON player.id = connection.playerId
            WHERE
                connection.playerId = ?
                AND
                connection.amount > 0
                AND
                connection.serverId = ?'
        ,   [@table, @original, @originalPlayer, playerId, serverId]
        ,   (err, rows) =>
                done err, rows



    @queryShipment: (playerId, serverId, maria, done) ->
        maria.query '
            SELECT
                item.material,
                item.titleRu,
                connection.amount,
                player.name
            FROM ?? AS connection
            JOIN ?? AS item
                ON item.id = connection.itemId
            JOIN ?? AS player
                ON player.id = connection.playerId
            WHERE
                connection.playerId = ?
                AND
                connection.amount > 0
                AND
                connection.serverId = ?'
        ,   [@table, @original, @originalPlayer, playerId, serverId]
        ,   (err, rows) =>
                done err, rows



    ###
    прислали кучу айтемов что делать:
    1. нам прислали id из player_item и реальное количество то есть ошибки быть не может
       и проверять не нужно (но! всетаки проверим, тем более меньше работы плагину)
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
    @openShipment: (maria, done) ->
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








    @deactivate: (playerId, maria, done) ->
        return done 'not valid argument' if not playerId

        maria.query '
            UPDATE
                ??
            SET
                enabledAt = NULL
            WHERE
                id = ?'
        ,   [@table, playerId]
        ,   (err, res) ->

                if not err and res.affectedRows != 1
                    err= 'player deactivate error'

                done err



    @delete: (playerId, maria, done) ->
        maria.query '
            DELETE
            FROM
                ??
            WHERE
                id = ?'
        ,   [@table, playerId]
        ,   (err, res) ->

                if not err and res.affectedRows != 1
                    err= 'player delete error'

                done err
