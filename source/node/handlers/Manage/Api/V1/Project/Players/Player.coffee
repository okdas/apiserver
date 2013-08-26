express= require 'express'
async= require 'async'

access= (req, res, next) ->
    return next 401 if do req.isUnauthenticated
    return do next

###
Методы API для работы c игроками.
###
app= module.exports= do express



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
                    return done err, conn

        (conn, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn

    ],  (err, conn) ->
            do conn.end if conn

            return next err if err
            return res.json 200



###
Отдает список игроков.
###
app.get '/', access, (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query '
                SELECT
                    player.id,
                    player.name,
                    player.balance,
                    player.email,
                    player.phone
                FROM player AS player'
            ,   (err, rows) ->
                    return done err, conn, rows

    ],  (err, conn, players) ->
            do conn.end if conn

            return next err if err
            return res.json 200, players



###
Отдает игрока.
###
app.get '/:playerId', access, (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query '
                SELECT
                    player.id,
                    player.name,
                    player.balance,
                    player.email,
                    player.phone
                FROM player AS player
                WHERE id = ?'
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
Обновляет игрока.
###
app.put '/:playerId', access, (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            conn.query 'UPDATE player SET ? WHERE id = ?'
            ,   [req.body, req.params.playerId]
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
Удаляет игрока.
###
app.delete '/:playerId', access, (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            conn.query 'DELETE FROM player WHERE id = ?'
            ,   [req.params.playerId]
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
Отдает список разрешений.
###
app.get '/permissions', access, (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            q= "
            SELECT pe.`name`, pe.`type`, pe.`default`, pi.`parent`, p.`value` as weight
            FROM permissions_entity as pe
            LEFT OUTER JOIN permissions_inheritance as pi ON pe.name = pi.child
            LEFT OUTER JOIN server_permissions as p ON pe.name = p.name AND p.permission = 'weight'
            ORDER BY weight
            "
            conn.query q
            ,   (err, rows) ->
                    return done err, conn, rows

        (conn, rows, done) ->
            permissions= {players:[], groups:[]}

            entities= {}
            for row in rows
                entity= entities[row.name]
                if not entity
                    entity= entities[row.name]=
                        name: row.name
                        groups: []

                    if row.type == 1
                        permissions.players.push entity
                    else
                        permissions.groups.push entity

                entity.default= !!row.default if row.default
                entity.weight= parseInt row.weight if row.weight
                entity.groups.push row.parent if row.parent

            for name in Object.keys entities
                entity= entities[name]

                groups= []
                for name in entity.groups
                    groups.push entities[name]

                entity.groups= groups.sort (a, b) ->
                    console.log a.weight, b.weight
                    return 1 if not a.weight
                    return a.weight - b.weight

            return done null, conn, permissions

    ],  (err, conn, entities) ->
            do conn.end if conn

            return next err if err
            return res.json 200, entities

