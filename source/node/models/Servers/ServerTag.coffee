module.exports= class ServerTag
    @table: 'server_tag'
    @original: 'tag'


    ###
    tags: [
        {
            id: 1
        }, {
            id: 2
        }
    ]
    ###
    constructor: (data) ->
        @tags= []
        if data
            for tag in data
                @tags.push
                    id: tag.id



    @create: (serverId, serverTag, maria, done) ->
        if not serverId
            return done 'arguments is not validate'

        maria.query '
            DELETE
            FROM
                ??
            WHERE
                serverId = ?'
        ,   [@table, serverId]
        ,   (err, res) =>
                return done err if err
                return done null, null if not serverTag.tags.length


                bulk= []
                serverTag.tags.map (tag) ->
                    bulk.push [serverId, tag.id]

                maria.query '
                    INSERT
                    INTO
                        ??
                        (`serverId`, `tagId`)
                    VALUES
                        ?'
                ,   [@table, bulk]
                ,   (err, res) ->
                        if not err and res.affectedRows != 1
                            err.message= 'server tags insert error'

                        return done err, serverTag



    @query: (maria, done) ->
        maria.query '
            SELECT
                connection.serverId,
                tag.id,
                tag.name,
                tag.titleRuPlural
            FROM ?? AS connection
            JOIN ?? AS tag
                ON tag.id = connection.tagId'
        ,   [@table, @original]
        ,   (err, rows) ->
                return done err, rows



    @get: (serverId, maria, done) ->
        maria.query '
            SELECT
                connection.serverId,
                tag.id,
                tag.name,
                tag.titleRuPlural
            FROM ?? AS connection
            JOIN ?? AS tag
                ON tag.id = connection.tagId
            WHERE connection.serverId = ?'
        ,   [@table, @original, serverId]
        ,   (err, rows) ->
                return done err, rows
