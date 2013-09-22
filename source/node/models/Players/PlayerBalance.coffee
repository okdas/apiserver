module.exports= class PlayerBalance
    @table: 'player_balance'



    constructor: (data) ->
        @playerId= data.playerId if data.playerId
        @amount= data.amount
        @updatedAt= data.updatedAt



    @create: (playerId, maria, done) ->
        return done 'not valid argument' if not playerId

        maria.query '
            INSERT
            INTO
                ??
            SET
                playerId = ?,
                amount = 0.00,
                updatedAt = NOW()'
        ,   [@table, playerId]
        ,   (err, res) ->
                if not err && res.affectedRows != 1
                    err= 'balance insert error'

                done err



    @query: (maria, done) ->
        maria.query '
            SELECT
                object.playerId,
                object.amount,
                object.updatedAt
            FROM ?? AS object'
        ,   [@table]
        ,   (err, rows) =>
                done err, rows



    @get: (playerId, maria, done) ->
        maria.query '
            SELECT
                object.amount,
                object.updatedAt
            FROM ?? AS object
            WHERE playerId = ?'
        ,   [@table, playerId]
        ,   (err, rows) =>
                balance= null

                if not err and rows.length
                    balance= new @ rows[0]

                done err, balance
