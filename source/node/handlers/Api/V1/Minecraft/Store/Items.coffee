express= require 'express'
async= require 'async'


###
Методы API для работы c предметами.
###
app= module.exports= do express



###
Отдает список предметов.
###
app.get '/', (req, res, next) ->
    req.db.getConnection (err, connection) ->
        return next err if err

        connection.query 'SELECT * FROM store_item'
        ,   (err, rows) ->
                do connection.end

                return next err if err
                return res.json 200, rows



###
Добавляет предмет.
###
app.post '/', (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            data=
                title: req.body.title
                imageUrl: req.body.imageUrl
                material: req.body.material
            conn.query 'INSERT INTO store_item SET ?'
            ,   [data]
            ,   (err, resp) ->
                    return done err, conn, resp

        (conn, resp, done) ->
            enchantments= req.body.enchantments
            async.reduce enchantments, 1
            ,   (i, enchantment, done) ->
                    data=
                        itemId: resp.insertId
                        enchantmentId: enchantment.id
                        level: enchantment.level
                        order: i
                    conn.query 'INSERT INTO store_item_enchantments SET ?'
                    ,   [data]
                    ,   (err, resp) ->
                            return done err, ++i
            ,   (err) ->
                    return done err, conn

        (conn, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn

    ],  (err, conn) ->
            do conn.end if conn

            return next err if err
            return res.json 201, req.body




###
Отдает предмет.
###
app.get '/:itemId', (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query 'SELECT * FROM store_item WHERE id = ?'
            ,   [req.params.itemId]
            ,   (err, resp) ->
                    item= do resp.shift if not err
                    return done err, conn, item

        (conn, item, done) ->
            conn.query 'SELECT * FROM store_item_enchantments as ie JOIN store_enchantment as e ON ie.enchantmentId = e.id WHERE itemId = ? ORDER BY ie.order'
            ,   [req.params.itemId]
            ,   (err, resp) ->
                    item.enchantments= []
                    if not err
                        resp.map (enchantment) ->
                            item.enchantments.push
                                id: enchantment.id
                                identity: enchantment.identity
                                title: enchantment.title
                                level: enchantment.level
                                levelmax: enchantment.levelmax
                    return done err, conn, item

    ],  (err, conn, item) ->
            do conn.end if conn

            return next err if err
            return res.json 404, null if not item
            return res.json 200, item



###
Обновляет предмет.
###
app.put '/:itemId', (req, res, next) ->

    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            if req.body.enchantments
                (enchantments= req.body.enchantments) and delete req.body.enchantments
            conn.query 'UPDATE store_item SET ? WHERE id = ?'
            ,   [req.body, req.params.itemId]
            ,   (err, resp) ->
                    if enchantments
                        req.body.enchantments= enchantments
                    return done err, conn

        (conn, done) ->
            conn.query 'DELETE FROM store_item_enchantments WHERE itemId = ?'
            ,   [req.params.itemId]
            ,   (err, resp) ->
                    return done err, conn

        (conn, done) ->
            enchantments= req.body.enchantments
            async.reduce enchantments, 1
            ,   (i, enchantment, done) ->
                    data=
                        itemId: req.params.itemId
                        enchantmentId: enchantment.id
                        level: enchantment.level
                        order: i
                    conn.query 'INSERT INTO store_item_enchantments SET ?'
                    ,   [data]
                    ,   (err, resp) ->
                            return done err, ++i
            ,   (err) ->
                    return done err, conn

        (conn, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn

    ],  (err, conn) ->
            do conn.end if conn

            return next err if err
            return res.json 200, req.body



###
Удаляет предмет.
###
app.delete '/:itemId', (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query 'DELETE FROM store_item WHERE id = ?'
            ,   [req.params.itemId]
            ,   (err, resp) ->
                    item= {} if not err
                    return done err, conn, item

    ],  (err, conn, item) ->
            do conn.end if conn

            return next err if err
            return res.json 200, item
