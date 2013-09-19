module.exports= class Server
    @table: 'server'
    @serverTags: 'server_tags'



    constructor: (data) ->
        @id= data.id if data.id
        @title= data.title if data.title
        @name= data.name if data.name
        @key= data.key if data.key



    ###
    {
        'title': '',
        'name': '',
        'key': ''
    }
    ###
    @create: (server, maria, done) ->
        return done 'not a Server' if not (server instanceof @)

        delete server.id if server.id


        conn.query '
            INSERT
            INTO
                ??
            SET
                ?'
        ,   [@table, server]
        ,   (err, res) ->
                if not err and res.affectedRows != 1
                    err= 'server insert error'
                return done err



    @query: (maria, done) ->
        maria.query '
            SELECT
                server.id,
                server.title,
                server.name,
                server.key
            FROM ?? AS server'
        ,   [@table]
        ,   (err, rows) =>
                done err, rows



    @update: (playerId, player, maria, done) ->
        player= new @ player if not (player instanceof @)

        maria.query "
            UPDATE
                ??
               SET
                ?
             WHERE
                id = ?
            "
        ,   [@table, player, playerId]
        ,   (err, res) =>

                if not err and res.affectedRows != 1
                    err= 'player update error'

                done err, player



    @query: (maria, done) ->
        maria.query '
            SELECT
                server.id,
                server.title,
                server.name,
                server.key
            FROM ?? AS server'
        ,   [@table]
        ,   (err, rows) =>
                done err, rows



    @get: (playerId, maria, done) ->
        maria.query "
            SELECT
                Player.id,
                Player.name,
                Player.email,
                Player.phone,
                IFNULL(PlayerBalance.amount, 0) as balance
              FROM
                ?? as Player
              LEFT OUTER JOIN
                ?? as PlayerBalance ON PlayerBalance.playerId = Player.id
            WHERE
                Player.id = ?
            "
        ,   [@table, @tableBalance, playerId]
        ,   (err, rows) =>
                player= null

                if not err and rows.length
                    player= new @ rows[0]

                done err, player



    @getByNameAndPass: (player, maria, done) ->
        player= new @ player if not (player instanceof @)

        maria.query "
            SELECT
                Player.id,
                Player.name,
                Player.email,
                Player.phone
              FROM
                ?? as Player
             WHERE
                Player.name = ?
               AND
                Player.pass = ?
               AND
                Player.enabledAt IS NOT NULL
            "
        ,   ['player', player.name, player.pass]
        ,   (err, rows) =>
                player= null

                if not err and rows.length
                    player= new @ rows[0]

                done err, player
