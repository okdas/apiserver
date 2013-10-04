module.exports= class ItemEnchantment
    @table: 'item_enchantment'
    @original: 'bukkit_enchantment'



    constructor: (data) ->
        @enchantments= []
        if data
            for ench in data
                @enchantments.push
                    id: ench.id
                    level: ench.level
                    order: ench.order



    @create: (itemId, itemEnchantment, maria, done) ->
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
                return done null, null if not itemEnchantment.enchantments.length


                bulk= []
                itemEnchantment.enchantments.map (ench) ->
                    bulk.push [itemId, ench.id, ench.level, ench.order]

                maria.query '
                    INSERT
                    INTO
                        ??
                        (`itemId`, `enchantmentId`, `level`, `order`)
                    VALUES
                        ?'
                ,   [@table, bulk]
                ,   (err, res) ->
                        return done err, itemEnchantment



    @query: (maria, done) ->
        maria.query '
            SELECT
                connection.itemId,
                ench.id,
                connection.level,
                connection.order,
                ench.titleRu
            FROM ?? AS connection
            JOIN ?? AS ench
                ON ench.id = connection.enchantmentId'
        ,   [@table, @original]
        ,   (err, rows) ->
                return done err, rows



    @get: (itemId, maria, done) ->
        maria.query '
            SELECT
                connection.itemId,
                ench.id,
                connection.level,
                connection.order,
                ench.titleRu
            FROM ?? AS connection
            JOIN ?? AS ench
                ON ench.id = connection.enchantmentId
            WHERE
                connection.itemId = ?'
        ,   [@table, @original, itemId]
        ,   (err, rows) ->
                return done err, rows
