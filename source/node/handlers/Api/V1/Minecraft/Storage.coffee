express= require 'express'
async= require 'async'

###
Методы API для работы c серверами.
###
app= module.exports= do express



###
Список товаров игрока
###
app.get '/:playerName/list', (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query '
                SELECT
                    player.name as playerName,
                    si.title as itemTitle,
                    si.name as itemName,
                    si.material as itemMaterial,
                    si.amount as itemAmount
                FROM player as player
                JOIN storage_item AS si
                    ON si.playerId = player.id AND si.serverId = ?
                WHERE player.name = ?'
            ,   [req.server.id,req.params.playerName]
            ,   (err, rows) ->
                    return done err, conn, rows

        (conn, rows, done) ->
            player=
                playerName: ''
                items: []

            for row in rows
                player.playerName= row.playerName

                player.items.push
                    materialId: row.itemMaterial
                    title: row.itemTitle
                    amount: row.itemAmount


            return done null, conn, player

    ],  (err, conn, rows) ->
            do conn.end if conn

            return next err if err
            return res.json 200, rows



###
Открывает шипмент
###
app.get '/:playerName/shipment/open', (req, res, next) ->
    # сначала смотрим запрошенные товары

    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            conn.query 'SELECT * FROM server'
            ,   (err, rows) ->
                    return done err, conn, rows

        (conn, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn


    ],  (err, conn, rows) ->
            do conn.end if conn

            return next err if err
            return res.json 200, rows



###
Отдает сервер.
###
app.get '/:serverId', (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query 'SELECT * FROM server WHERE id = ?'
            ,   [req.params.serverId]
            ,   (err, resp) ->
                    server= do resp.shift if not err
                    return done err, conn, server

    ],  (err, conn, server) ->
            do conn.end if conn

            return next err if err
            return res.json 404, null if not server
            return res.json 200, server



###
Изменяет сервер
###
app.put '/:serverId', (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            conn.query 'UPDATE server SET ? WHERE id = ?'
            ,   [req.body, req.params.serverId]
            ,   (err, resp) ->
                    server= req.body
                    server.id= req.params.serverId
                    return done err, conn

        (conn, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn

    ],  (err, conn) ->
            do conn.end if conn

            return next err if err
            return res.json 200



###
Удаляет сервер
###
app.delete '/:serverId', (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            conn.query 'DELETE FROM server WHERE id = ?'
            ,   [req.params.serverId]
            ,   (err, resp) ->
                    return done err, conn

        (conn, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn

    ],  (err, conn) ->
            do conn.end if conn

            return next err if err
            return res.json 200

