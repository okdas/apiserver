express= require 'express'
async= require 'async'
Db= require '../../../../../../node/db/'

access= (req, res, next) ->
    return next 401 if do req.isUnauthenticated
    return do next

###
Методы API для работы c игроками.
###
app= module.exports= do express



###
Отдает список разрешений.
###
app.get '/db', (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            Db.syncDb conn, (err) ->
                done err, conn

    ],  (err, conn) ->
            do conn.end if conn

            return next err if err
            return res.json 200



###
Отдает список игроков.
###
app.get '/material', access, (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            q= "
            SELECT
                p.`id`,
                p.`name`,
                pi.`parent`,
                p.`email`,
                p.`phone`
            FROM player as p
            LEFT OUTER JOIN permissions_inheritance as pi ON p.name = pi.child
            ORDER BY p.`name`
            "
            conn.query q
            ,   (err, rows) ->
                    return done err, conn, rows

        (conn, rows, done) ->
            players= []
            playersByName= {}
            for row in rows
                player= playersByName[row.name]
                if not player
                    player= playersByName[row.name]=
                        id: row.id
                        name: row.name
                        groups: []
                        email: row.email
                        phone: row.phone

                    players.push player
                player.groups.push row.parent if row.parent
            return done null, conn, players

    ],  (err, conn, players) ->
            do conn.end if conn

            return next err if err
            setTimeout () ->
                return res.json 200, players
            ,   10



###
Отдает игрока.
###
app.get '/:playerId', access, (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query 'SELECT * FROM player WHERE id = ?'
            ,   [req.params.playerId]
            ,   (err, resp) ->
                    player= do resp.shift if not err
                    return done err, conn, player

    ],  (err, conn, player) ->
            do conn.end if conn

            return next err if err
            return res.json 404, null if not player
            return res.json 200, player



###
Добавляет игрока.
###
app.post '/', access, (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            conn.query 'INSERT INTO player SET ?'
            ,   [req.body]
            ,   (err, resp) ->
                    id= resp.insertId if not err
                    return done err, conn, id

        (conn, done) ->
            conn.query 'ROLLBACK', (err) ->
                return done err, conn

    ],  (err, conn) ->
            do conn.end if conn
