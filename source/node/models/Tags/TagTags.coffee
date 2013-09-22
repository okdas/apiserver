module.exports= class User
    @table: 'tag_tags'
    @original: 'tag'


    constructor: (data) ->
        @tags= []
        if data
            for tag in data
                @tags.push
                    id: tag.id





    @create: (tagId, tagTag, maria, done) ->
        if not tagId
            return done 'arguments is not validate'

        maria.query '
            DELETE
            FROM
                ??
            WHERE
                childId = ?'
        ,   [@table, tagId]
        ,   (err, res) =>
                return done err if err
                return done null, null if not tagTag.tags.length


                bulk= []
                tagTag.tags.map (tag) ->
                    bulk.push [tagId, tag.id]

                maria.query '
                    INSERT
                    INTO
                        ??
                        (`childId`, `tagId`)
                    VALUES
                        ?'
                ,   [@table, bulk]
                ,   (err, res) ->
                        done err, tagTag



    @query: (maria, done) ->
        maria.query '
            SELECT
                connection.childId,
                object.id,
                object.name,
                object.titleRuPlural
            FROM ?? AS connection
            JOIN ?? AS object
                ON object.id = connection.tagId'
        ,   [@table, @original]
        ,   (err, rows) ->
                return done err, rows



    @get: (tagId, maria, done) ->
        maria.query '
            SELECT
                connection.childId,
                object.id,
                object.name,
                object.titleRuPlural
            FROM ?? AS connection
            JOIN ?? AS object
                ON object.id = connection.tagId
            WHERE connection.childId = ?'
        ,   [@table, @original, tagId]
        ,   (err, rows) ->
                return done err, rows
