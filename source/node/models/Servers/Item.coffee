module.exports= class Item
    @table: 'item'



    constructor: (data) ->
        @id= data.id if data.id
        @material= data.serverId if data.serverId
        @amount= data.host if data.host
        @price= data.price if data.price
        @name= data.name if data.name
        @titleRu= data.titleRu if data.titleRu
        @titleEn= data.titleEn if data.titleEn
        @imageUrl= data.imageUrl if data.imageUrl



    @create: (item, maria, done) ->
        return done 'not a Item' if not (item instanceof @)

        delete item.id if item.id

        maria.query '
            INSERT
            INTO
                ??
            SET
                ?'
        ,   [@table, item]
        ,   (err, res) ->
                if not err && res.affectedRows != 1
                    err= 'item insert error'

                item.id= res.insertId

                done err, item



    @query: (maria, done) ->
        maria.query '
            SELECT
                object.id,
                object.material,
                object.amount,
                object.price,
                object.name,
                object.titleRu,
                object.titleEn,
                object.imageUrl
            FROM ?? AS object'
        ,   [@table]
        ,   (err, rows) =>
                done err, rows



    @get: (itemId, maria, done) ->
        maria.query '
            SELECT
                object.id,
                object.material,
                object.amount,
                object.price,
                object.name,
                object.titleRu,
                object.titleEn,
                object.imageUrl
            FROM
                ?? AS object
            WHERE
                id = ?'
        ,   [@table, itemId]
        ,   (err, rows) =>
                item= null

                if not err and rows.length
                    item= new @ rows[0]

                done err, item




    @update: (itemId, item, maria, done) ->
        return done 'not a Item' if not (item instanceof @)

        delete item.id if item.id

        maria.query '
            UPDATE
                ??
            SET
                ?
            WHERE
                id = ?'
        ,   [@table, item, itemId]
        ,   (err, res) ->

                if not err and res.affectedRows != 1
                    err= 'item update error'

                done err, item



    @delete: (itemId, maria, done) ->
        maria.query '
            DELETE
            FROM
                ??
            WHERE
                id = ?'
        ,   [@table, itemId]
        ,   (err, res) ->

                if not err and res.affectedRows != 1
                    err= 'item delete error'

                done err
