module.exports= class Server
    @table: 'server'



    constructor: (data) ->
        @id= data.id if data.id
        @title= data.title if data.title
        @name= data.name if data.name
        @key= data.key if data.key



    ###
    {
        title: 'qqq',
        name: 'qqq',
        key: 'qqq',
        tags: [
            {
                id: 1,
                name: 'blocks',
                titleRuPlural: 'Блоки',
                titleRuSingular: 'Блок',
                titleEnPlural: 'Blocks',
                titleEnSingular: 'Block',
                descRu: null,
                descEn: null,
                updatedAt: '2013-09-16T13:57:07.000Z',
                serverId: 5,
                parentTags: [Object]
            }, {
                id: 2,
                name: 'materials',
                titleRuPlural: 'Материалы',
                titleRuSingular: 'Материал',
                titleEnPlural: 'Materials',
                titleEnSingular: 'Material',
                descRu: null,
                descEn: null,
                updatedAt: '2013-09-16T13:57:07.000Z',
                serverId: 5,
                parentTags: [Object]
            }
        ]
    }
    ###
    @create: (server, maria, done) ->
        return done 'not a Server' if not (server instanceof @)

        delete server.id if server.id


        maria.query '
            INSERT
            INTO
                ??
            SET
                ?'
        ,   [@table, server]
        ,   (err, res) ->
                if not err && res.affectedRows != 1
                    err= 'server insert error'

                server.id= res.insertId

                return done err, server



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



    @get: (serverId, maria, done) ->
        maria.query '
            SELECT
                server.id,
                server.title,
                server.name,
                server.key
            FROM ?? AS server
            WHERE id = ?'
        ,   [@table, serverId]
        ,   (err, rows) =>
                player= null

                if not err and rows.length
                    player= new @ rows[0]

                done err, player




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
