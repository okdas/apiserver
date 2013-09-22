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
                titleRuPlural: 'Блоки'
            }, {
                id: 2,
                name: 'materials',
                titleRuPlural: 'Материалы'
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

                done err, server



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
                server= null

                if not err and rows.length
                    server= new @ rows[0]

                done err, server




    @update: (serverId, server, maria, done) ->
        return done 'not a Server' if not (server instanceof @)

        delete server.id if server.id

        maria.query '
            UPDATE
                ??
            SET
                ?
            WHERE
                id = ?'
        ,   [@table, server, serverId]
        ,   (err, res) ->

                if not err and res.affectedRows != 1
                    err= 'server update error'

                done err, server



    @delete: (serverId, maria, done) ->
        maria.query '
            DELETE
            FROM
                ??
            WHERE
                id = ?'
        ,   [@table, serverId]
        ,   (err, res) ->

                if not err and res.affectedRows != 1
                    err= 'server delete error'

                done err
