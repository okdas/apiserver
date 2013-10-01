module.exports= class Enchantment
    @table: 'bukkit_enchantment'



    constructor: (data) ->
        @id= data.id if data.id
        @titleRu= data.titleRu if data.titleRu
        @titleEn= data.titleEn if data.titleEn
        @levelMax= data.levelMax if data.levelMax
        @levelMin= data.levelMin if data.levelMin



    @create: (enchantment, maria, done) ->
        return done 'not a Enchantment' if not (enchantment instanceof @)

        maria.query '
            INSERT
            INTO
                ??
            SET
                ?'
        ,   [@table, enchantment]
        ,   (err, res) ->
                if not err && res.affectedRows != 1
                    err= 'enchantment insert error'

                enchantment.id= res.insertId

                done err, enchantment



    @query: (maria, done) ->
        maria.query '
            SELECT
                object.id,
                object.titleRu,
                object.titleEn,
                object.levelMax,
                object.levelMin
            FROM ?? AS object'
        ,   [@table]
        ,   (err, rows) =>
                done err, rows



    @get: (enchantmentId, maria, done) ->
        maria.query '
            SELECT
                object.id,
                object.titleRu,
                object.titleEn,
                object.levelMax,
                object.levelMin
            FROM
                ?? AS object
            WHERE
                id = ?'
        ,   [@table, enchantmentId]
        ,   (err, rows) =>
                enchantment= null

                if not err and rows.length
                    enchantment= new @ rows[0]

                done err, enchantment



    @update: (enchantmentId, enchantment, maria, done) ->
        return done 'not a Enchantment' if not (enchantment instanceof @)

        delete enchantment.id if enchantment.id

        maria.query '
            UPDATE
                ??
            SET
                ?
            WHERE
                id = ?'
        ,   [@table, enchantment, enchantmentId]
        ,   (err, res) ->

                if not err and res.affectedRows != 1
                    err= 'enchantment update error'

                done err, enchantment



    @delete: (enchantmentId, maria, done) ->
        maria.query '
            DELETE
            FROM
                ??
            WHERE
                id = ?'
        ,   [@table, enchantmentId]
        ,   (err, res) ->

                if not err and res.affectedRows != 1
                    err= 'enchantment delete error'

                done err
