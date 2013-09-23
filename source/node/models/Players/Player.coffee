crypto= require 'crypto'

module.exports= class Player
    @table: 'player'



    constructor: (data) ->
        @id= data.id if data.id
        @pass= Player.sha1 data.pass if data.pass
        @name= data.name
        @email= data.email
        @phone= data.phone if data.phone
        @createdAt= data.createdAt if data.createdAt
        @updatedAt= data.updatedAt if data.updatedAt



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



    @sha1: (string) ->
        hash= crypto.createHash 'sha1'
        hash.update string
        return hash.digest 'hex'



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
        delete player.createdAt if player.createdAt
        delete player.updatedAt if player.updatedAt
        delete player.pass if player.pass

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
