module.exports= class ItemEnchantment
    @table: 'player_server_item_enchantment'



    @query: (itemIds, maria, done) ->
        maria.query '
            SELECT
                itemId AS id,
                enchantmentId,
                level
            FROM
                ??
            WHERE
                itemId IN (?)'
        ,   [@table, itemIds]
        ,   (err, rows) =>
                done err, rows
