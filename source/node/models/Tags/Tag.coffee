module.exports= class Tag
    @table: 'tag'
    @originalServerTag: 'server_tag'



    constructor: (data) ->
        @id= data.id if data.id
        @name= data.name
        @titleRuSingular= data.titleRuSingular if data.titleRuSingular
        @titleRuPlural= data.titleRuPlural if data.titleRuPlural
        @titleEnSingular= data.titleEnSingular if data.titleEnSingular
        @titleEnPlural= data.titleEnPlural if data.titleEnPlural
        @descRu= data.descRu if data.descRu
        @descEn= data.descEn if data.descEn





    @create: (tag, maria, done) ->
        return done 'not a Tag' if not (tag instanceof @)

        delete tag.id if tag.id


        maria.query '
            INSERT
            INTO
                ??
            SET
                ?'
        ,   [@table, tag]
        ,   (err, res) ->
                if not err && res.affectedRows != 1
                    err= 'tag insert error'

                tag.id= res.insertId

                done err, tag



    @query: (maria, done) ->
        maria.query '
            SELECT
                object.id,
                object.name,
                object.titleRuSingular,
                object.titleRuPlural,
                object.titleEnSingular,
                object.titleEnPlural,
                object.descRu,
                object.descEn
            FROM ?? AS object'
        ,   [@table]
        ,   (err, rows) ->
                done err, rows



    @get: (tagId, maria, done) ->
        maria.query '
            SELECT
                object.id,
                object.name,
                object.titleRuSingular,
                object.titleRuPlural,
                object.titleEnSingular,
                object.titleEnPlural,
                object.descRu,
                object.descEn
            FROM ?? AS object
            WHERE id = ?'
        ,   [@table, tagId]
        ,   (err, rows) =>
                tag= null

                if not err and rows.length
                    tag= new @ rows[0]

                done err, tag



    @getWithServerId: (maria, done) ->
        maria.query '
            SELECT
                connection.serverId,
                object.id,
                object.name,
                object.titleRuSingular,
                object.titleRuPlural,
                object.titleEnSingular,
                object.titleEnPlural,
                object.descRu,
                object.descEn
            FROM ?? AS object
            JOIN ?? AS connection
                ON connection.tagId = object.id'
        ,   [@table, @originalServerTag]
        ,   (err, rows) ->
                done err, rows



    @update: (tagId, tag, maria, done) ->
        return done 'not a Tag' if not (tag instanceof @)

        delete tag.id if tag.id

        maria.query '
            UPDATE
                ??
            SET
                ?
            WHERE
                id = ?'
        ,   [@table, tag, tagId]
        ,   (err, res) ->

                if not err and res.affectedRows != 1
                    err= 'tag update error'

                done err, tag



    @delete: (tagId, maria, done) ->
        maria.query '
            DELETE
            FROM
                ??
            WHERE
                id = ?'
        ,   [@table, tagId]
        ,   (err, res) ->

                if not err and res.affectedRows != 1
                    err= 'tag delete error'

                done err
