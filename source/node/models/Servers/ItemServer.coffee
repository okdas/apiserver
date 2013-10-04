module.exports= class ItemServer
    @table: 'server_item'
    @original: 'server'



    constructor: (data) ->
        @servers= []
        if data
            for server in data
                @servers.push
                    id: server.id



    @create: (itemId, itemServer, maria, done) ->
        if not itemId
            return done 'arguments is not validate'

        maria.query '
            DELETE
            FROM
                ??
            WHERE
                itemId = ?'
        ,   [@table, itemId]
        ,   (err, res) =>
                return done err if err
                return done null, null if not itemServer.servers.length


                bulk= []
                itemServer.servers.map (server) ->
                    bulk.push [itemId, server.id]

                maria.query '
                    INSERT
                    INTO
                        ??
                        (`itemId`, `serverId`)
                    VALUES
                        ?'
                ,   [@table, bulk]
                ,   (err, res) ->
                        return done err, itemServer



    @query: (maria, done) ->
        maria.query '
            SELECT
                connection.itemId,
                server.id,
                server.name,
                server.title
            FROM ?? AS connection
            JOIN ?? AS server
                ON server.id = connection.serverId'
        ,   [@table, @original]
        ,   (err, rows) ->
                return done err, rows



    @get: (itemId, maria, done) ->
        maria.query '
            SELECT
                connection.itemId,
                server.id,
                server.name,
                server.title
            FROM ?? AS connection
            JOIN ?? AS server
                ON server.id = connection.serverId
            WHERE connection.itemId = ?'
        ,   [@table, @original, itemId]
        ,   (err, rows) ->
                return done err, rows
