module.exports= class Material
    @table: 'bukkit_material'



    constructor: (data) ->
        @id= data.id if data.id
        @titleRu= data.titleRu if data.titleRu
        @titleEn= data.titleEn if data.titleEn
        @imageUrl= data.imageUrl if data.imageUrl
        @enchantability= data.enchantability if data.enchantability



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
    @create: (material, maria, done) ->
        return done 'not a Material' if not (material instanceof @)

        maria.query '
            INSERT
            INTO
                ??
            SET
                ?'
        ,   [@table, material]
        ,   (err, res) ->
                if not err && res.affectedRows != 1
                    err= 'material insert error'

                material.id= res.insertId

                done err, material



    @query: (maria, done) ->
        maria.query '
            SELECT
                object.id,
                object.titleRu,
                object.titleEn,
                object.imageUrl,
                object.enchantability
            FROM
                ?? AS object'
        ,   [@table]
        ,   (err, rows) =>
                done err, rows



    @get: (materialId, maria, done) ->
        maria.query '
            SELECT
                object.id,
                object.titleRu,
                object.titleEn,
                object.imageUrl,
                object.enchantability
            FROM
                ?? AS object
            WHERE
                id = ?'
        ,   [@table, materialId]
        ,   (err, rows) =>
                material= null

                if not err and rows.length
                    material= new @ rows[0]

                done err, material



    @update: (materialId, material, maria, done) ->
        return done 'not a Material' if not (material instanceof @)

        delete material.id if material.id

        maria.query '
            UPDATE
                ??
            SET
                ?
            WHERE
                id = ?'
        ,   [@table, material, materialId]
        ,   (err, res) ->

                if not err and res.affectedRows != 1
                    err= 'material update error'

                done err, material



    @delete: (materialId, maria, done) ->
        maria.query '
            DELETE
            FROM
                ??
            WHERE
                id = ?'
        ,   [@table, materialId]
        ,   (err, res) ->

                if not err and res.affectedRows != 1
                    err= 'material delete error'

                done err
