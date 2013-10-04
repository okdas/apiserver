module.exports= class ItemTag
    @table: 'item_tag'
    @original: 'tag'



    constructor: (data) ->
        @tags= []
        if data
            for tag in data
                @tags.push
                    id: tag.id



    @create: (itemId, itemTag, maria, done) ->
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
                return done null, null if not itemTag.tags.length


                bulk= []
                itemTag.tags.map (tag) ->
                    bulk.push [itemId, tag.id]

                maria.query '
                    INSERT
                    INTO
                        ??
                        (`itemId`, `tagId`)
                    VALUES
                        ?'
                ,   [@table, bulk]
                ,   (err, res) ->
                        return done err, itemTag



    @query: (maria, done) ->
        maria.query '
            SELECT
                connection.itemId,
                tag.id,
                tag.name,
                tag.titleRuSingular
            FROM ?? AS connection
            JOIN ?? AS tag
                ON tag.id = connection.tagId'
        ,   [@table, @original]
        ,   (err, rows) ->
                return done err, rows



    @get: (itemId, maria, done) ->
        maria.query '
            SELECT
                connection.itemId,
                tag.id,
                tag.name,
                tag.titleRuSingular
            FROM ?? AS connection
            JOIN ?? AS tag
                ON tag.id = connection.tagId
            WHERE connection.itemId = ?'
        ,   [@table, @original, itemId]
        ,   (err, rows) ->
                return done err, rows
