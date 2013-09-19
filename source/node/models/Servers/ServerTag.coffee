module.exports= class ServerTag
    @table: 'server_tags'



    ###
    data: [
        '' //tagId
    ]
    ###
    constructor: (serverId, tags) ->
        @tags= []

        if tags.length
            data.map (val) ->
                @tags.push val.id



    @create: (serverId, serverTag, maria, done) ->
        return done null if not serverTag.tags.length

        maria.query '
            DELETE
            FROM
                ??
            WHERE
                serverId = ?'
        ,   [@serverTags, serverId]
        ,   (err, res) ->
                if not err and res.affectedRows != 1
                    err= 'server tags delete error'
                    return done err


                bulk= []
                for tag in tags
                    bulk.push [serverId, tag.id]

                conn.query '
                    INSERT
                    INTO
                        ??
                        (`serverId`, `tagId`)
                    VALUES
                        ?'
                ,   [@serverTags, bulk]
                ,   (err, res) ->
                        if not err and res.affectedRows != 1
                            err= 'server tags insert error'
                            return done err
