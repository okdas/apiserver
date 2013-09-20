module.exports= class ServerTag
    @table: 'server_tag'
    @original: 'tag'


    ###
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
    ###
    constructor: (data) ->
        @tags= []

        if data.length
            data.map (val) =>
                @tags.push
                    id: val.id



    @create: (serverId, serverTag, maria, done) ->
        if not serverTag.tags.length or not serverId
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

                bulk= []
                for tag in serverTag.tags
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
                            err= 'server tags insert error'

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
