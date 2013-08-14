express= require 'express'
async= require 'async'

crypto= require 'crypto'
sha1= (string) ->
    hash= crypto.createHash 'sha1'
    hash.update string
    return hash.digest 'hex'

access= (req, res, next) ->
    return next 401 if do req.isUnauthenticated
    return do next

###
Методы API для работы c аутентифицированным игроком.
###
app= module.exports= do express



###
Отдает аутентифицированного игрока.
###
app.get '/', access, (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query "
                SELECT
                    p.name,
                    p.balance
                FROM
                    player as p
                WHERE
                    p.id = ?
                "
            ,   [req.user.id]
            ,   (err, resp) ->
                    player= do resp.shift if not err
                    return done err, conn, player

    ],  (err, conn, player) ->
            do conn.end if conn

            return next err if err
            return res.json 400, player if not player
            return res.json 200, player



###
Выполняет вход игрока.
###
app.post '/login', (req, res, next) ->

    name= req.body.name
    pass= sha1 req.body.pass

    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query "
                SELECT
                    p.id,
                    p.name
                FROM
                    player as p
                WHERE
                    p.name = ?
                    AND p.pass = ?
                "
            ,   [name, pass]
            ,   (err, rows) ->
                    player= do rows.shift if not err
                    return done err, conn, player

    ],  (err, conn, player) ->
            do conn.end if conn

            return next err if err
            return res.json 400, player if not player

            req.login player, (err) ->
                return next err if err
                return res.json 200, player



###
Выполняет выход игрока.
###
app.post '/logout', access, (req, res, next) ->
    return res.json 400, null if req.user.name != req.body.name

    do req.logout
    return res.json 200, true



###
Пополняет счет аутетифицированного игрока.
###
app.post '/donate', access, (req, res, next) ->
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
