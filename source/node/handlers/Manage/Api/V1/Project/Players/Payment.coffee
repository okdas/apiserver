express= require 'express'
async= require 'async'




###
Методы API для платежей
###
app= module.exports= do express
app.on 'mount', (parent) ->
    cfg= parent.get 'config'



    app.get '/'
    ,   access
    ,   listPayment
    ,   (req, res) ->
            res.json 200



    app.put '/close/:paymentId(\\d+)'
    ,   access
    ,   closePayment
    ,   (req, res) ->
            res.json 200





access= (req, res, next) ->
    return next 401 if do req.isUnauthenticated
    return do next



###
Отдает список платежей
###
listPayment= (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query '
                SELECT
                    payment.id,
                    payment.playerId,
                    player.name,
                    payment.amount,
                    payment.status,
                    payment.createdAt,
                    payment.closedAt
                FROM player_payment AS payment
                JOIN player AS player
                    ON player.id = payment.playerId'
            ,   (err, rows) ->
                    return done err, conn, rows

    ],  (err, conn, payments) ->
            do conn.end if conn

            return next err if err
            return res.json 404, null if not payments
            return res.json 200, payments



###
Закрывает платеж
###
closePayment= (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            conn.query 'UPDATE player_payment SET closedAt = NOW(), status = "success" WHERE id = ?'
            ,   [req.params.paymentId]
            ,   (err, resp) ->
                    return done err, conn

        (conn, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn

    ],  (err, conn) ->
            do conn.end if conn

            return next err if err
            return res.json 200
