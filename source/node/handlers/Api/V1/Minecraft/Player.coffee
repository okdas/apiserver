express= require 'express'
async= require 'async'

###
Методы API для работы c аутентифицированным игроком.
###
app= module.exports= do express



###
Отдает аутентифицированного игрока.
###
app.get '/', (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query "
                SELECT * FROM player WHERE id = ?
                "
            ,   [req.user.id]
            ,   (err, resp) ->
                    player= do resp.shift if not err
                    return done err, conn, player

    ],  (err, conn, player) ->
            do conn.end if conn
            return next err if err
            return res.render 'play/player',
                player: player



###
Пополняет счет аутетифицированного игрока.
###
app.post '/donate', (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            conn.query "
                UPDATE player
                SET balance = balance + #{conn.escape(req.query.amount)}
                WHERE id = ?
                "
            ,   [req.user.id]
            ,   (err, resp) ->
                    return done err, conn

        (conn, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn

    ],  (err, conn) ->
            do conn.end if conn
            return next err if err
