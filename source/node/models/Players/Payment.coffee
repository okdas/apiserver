crypto= require 'crypto'

module.exports= class Player
    @table: 'player_payment'
    @original: 'player'



    constructor: (data) ->
        @id= data.id if data.id
        @playerId= data.playerId if data.playerId
        @playerName= data.playerName if data.playerName
        @amount= data.amount
        @status= data.status
        @createdAt= data.createdAt if data.createdAt
        @updatedAt= data.closedAt if data.closedAt





    @query: (maria, done) ->
        maria.query '
            SELECT
                object.id,
                object.playerId,
                connection.name as playerName,
                object.amount,
                object.status,
                object.createdAt,
                object.closedAt
            FROM ?? AS object
            JOIN ?? AS connection
                ON connection.id = object.playerId
            ORDER BY object.createdAt DESC, object.closedAt DESC'
        ,   [@table, @original]
        ,   (err, rows) =>
                done err, rows



    @get: (paymentId, maria, done) ->
        maria.query '
            SELECT
                object.id,
                object.playerId,
                connection.name as playerName,
                object.amount,
                object.status,
                object.createdAt,
                object.closedAt
            FROM ?? AS object
            JOIN ?? AS connection
                ON connection.id = object.playerId
            WHERE id = ?'
        ,   [@table, @original, paymentId]
        ,   (err, rows) =>
                payment= null

                if not err and rows.length
                    payment= new @ rows[0]

                done err, payment



    @pending: (paymentId, maria, done) ->
        maria.query '
            UPDATE
                ??
            SET
                closedAt = NULL,
                status = "pending"
            WHERE
                id = ?'
        ,   [@table, paymentId]
        ,   (err, res) ->
                done err



    @success: (paymentId, maria, done) ->
        maria.query '
            UPDATE
                ??
            SET
                closedAt = NOW(),
                status = "success"
            WHERE
                id = ?'
        ,   [@table, paymentId]
        ,   (err, res) ->
                done err



    @failure: (paymentId, maria, done) ->
        maria.query '
            UPDATE
                ??
            SET
                closedAt = NULL,
                status = "failure"
            WHERE
                id = ?'
        ,   [@table, paymentId]
        ,   (err, res) ->
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
