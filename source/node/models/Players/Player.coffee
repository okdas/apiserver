module.exports= class Player
    @table: 'player'



    constructor: (data) ->
        @id= data.id if data.id
        @name= data.name
        @email= data.email
        @phone= data.phone if data.phone



    @create: (player, maria, done) ->
        return done 'not a Player' if not (player instanceof @)

        delete player.id if player.id

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



    @query: (maria, done) ->
        maria.query '
            SELECT
                object.id,
                object.name,
                object.email,
                object.phone,
                object.createdAt,
                object.enabledAt
            FROM ?? AS object'
        ,   [@table]
        ,   (err, rows) =>
                done err, rows



    @get: (playerId, maria, done) ->
        maria.query '
            SELECT
                object.id,
                object.name,
                object.email,
                object.phone,
                object.createdAt,
                object.enabledAt
            FROM ?? AS object
            WHERE id = ?'
        ,   [@table, playerId]
        ,   (err, rows) =>
                player= null

                if not err and rows.length
                    player= new @ rows[0]

                done err, player




    @update: (playerId, player, maria, done) ->
        return done 'not a Player' if not (player instanceof @)

        delete player.id if player.id

        maria.query '
            UPDATE
                ??
            SET
                ?
            WHERE
                id = ?'
        ,   [@table, player, playerId]
        ,   (err, res) ->

                if not err and res.affectedRows != 1
                    err= 'player update error'

                done err, player


    @activate: (playerId, maria, done) ->
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

                done err, player



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

                done err, player



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
