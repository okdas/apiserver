express= require 'express'
async= require 'async'

access= (req, res, next) ->
    return next 401 if do req.isUnauthenticated
    return do next

###
Методы API для работы c игроками.
###
app= module.exports= do express
app.on 'mount', (parent) ->
    app.set 'maria', maria= parent.get 'maria'



    app.post '/'
    ,   access
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   createPlayer(maria.Player)
    ,   createPlayerBalance(maria.PlayerBalance)
    ,   maria.transaction.commit()
    ,   (req, res) ->
            res.json 200, req.player

    app.get '/'
    ,   access
    ,   maria(app.get 'db')
    ,   getPlayers(maria.Player)
    ,   (req, res) ->
            res.json 200, req.players

    app.get '/:playerId(\\d+)'
    ,   access
    ,   maria(app.get 'db')
    ,   getPlayer(maria.Player)
    ,   getPlayerBalance(maria.PlayerBalance)
    ,   (req, res) ->
            res.json 200, req.player

    app.put '/:playerId(\\d+)'
    ,   access
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   updatePlayer(maria.Player)
    ,   maria.transaction.commit()
    ,   (req, res) ->
            res.json 200, req.player

    app.get '/activate/:playerId(\\d+)'
    ,   access
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   activatePlayer(maria.Player)
    ,   maria.transaction.commit()
    ,   (req, res) ->
            res.json 200

    app.get '/deactivate/:playerId(\\d+)'
    ,   access
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   deactivatePlayer(maria.Player)
    ,   maria.transaction.commit()
    ,   (req, res) ->
            res.json 200

    app.delete '/:playerId(\\d+)'
    ,   access
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   deletePlayer(maria.Player)
    ,   maria.transaction.commit()
    ,   (req, res) ->
            res.json 200





access= (req, res, next) ->
    err= null

    if do req.isUnauthenticated
        res.status 401
        err=
            message: 'user not authenticated'

    return next err



createPlayer= (Player) -> (req, res, next) ->
    console.log 'req', req.body
    newPlayer= new Player req.body
    Player.create newPlayer, req.maria, (err, player) ->
        req.player= player or null
        return next err

createPlayerBalance= (PlayerBalance) -> (req, res, next) ->
    PlayerBalance.create req.player.id, req.maria, (err) ->
        return next err



getPlayers= (Player) -> (req, res, next) ->
    Player.query req.maria, (err, players) ->
        req.players= players or null
        return next err



getPlayer= (Player) -> (req, res, next) ->
    Player.get req.params.playerId, req.maria, (err, player) ->
        req.player= player or null
        return next err

getPlayerBalance= (PlayerBalance) -> (req, res, next) ->
    PlayerBalance.get req.params.playerId, req.maria, (err, balance) ->
        req.player.balance= balance or null
        return next err



updatePlayer= (Player) -> (req, res, next) ->
    newPlayer= new Player req.body
    Player.update req.params.playerId, newPlayer, req.maria, (err, player) ->
        req.player= player or null
        return next err



activatePlayer= (Player) -> (req, res, next) ->
    Player.activate req.params.playerId, req.maria, (err) ->
        return next err



deactivatePlayer= (Player) -> (req, res, next) ->
    Player.deactivate req.params.playerId, req.maria, (err) ->
        return next err



deletePlayer= (Player) -> (req, res, next) ->
    Player.delete req.params.playerId, req.maria, (err) ->
        return next err





















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
                    player.email,
                    player.phone,
                    player.createdAt,
                    player.enabledAt
                FROM player AS player'
            ,   (err, rows) ->
                    return done err, conn, rows

    ],  (err, conn, players) ->
            do conn.end if conn

            return next err if err
            return res.json 200, players




app.get '/:playerId(\\d+)', access, (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query '
                SELECT
                    player.id,
                    player.name,
                    player.email,
                    player.phone,
                    balance.amount,
                    player.createdAt,
                    player.enabledAt
                FROM player AS player
                JOIN player_balance AS balance
                    ON balance.playerId = player.id
                WHERE id = ?'
            ,   [req.params.playerId]
            ,   (err, resp) ->
                    console.log 'err', err
                    console.log 'player', player
                    player= do resp.shift if not err
                    return done err, conn, player

    ],  (err, conn, player) ->
            do conn.end if conn

            return next err if err
            return res.json 404, null if not player
            return res.json 200, player



app.put '/:playerId(\\d+)', access, (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            data=
                name: req.body.name
                email: req.body.email
                phone: req.body.phone

            conn.query 'UPDATE player SET ? WHERE id = ?'
            ,   [data, req.params.playerId]
            ,   (err, resp) ->
                    return done err, conn

        (conn, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn

    ],  (err, conn) ->
            do conn.end if conn

            return next err if err
            return res.json 200



app.delete '/:playerId(\\d+)', access, (req, res, next) ->
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



app.get '/activate/:playerId(\\d+)', access, (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            conn.query 'UPDATE player SET enabledAt = NOW() WHERE id = ?'
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



app.get '/deactivate/:playerId(\\d+)', access, (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            conn.query 'UPDATE player SET enabledAt = NULL WHERE id = ?'
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
###
