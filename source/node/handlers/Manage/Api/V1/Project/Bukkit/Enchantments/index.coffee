express= require 'express'

access= (req, res, next) ->
    return next 401 if do req.isUnauthenticated
    return do next


###
Методы API для работы c чарами.
###
app= module.exports= do express



###
Добавляет чару.
###
app.post '/', access, (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            con.query 'INSERT INTO bukkit_enchantment SET ?'
            ,   [req.body]
            ,   (err, resp) ->
                    return done err, conn

        (conn, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn

    ],  (err, conn, shipment) ->
            do conn.end if conn

            return res.json 400, req.body if err and err.code= 'ER_DUP_ENTRY'
            return next err if err
            return res.json 201, req.body



###
Отдает список чар.
###
app.get '/', access, (req, res, next) ->
    req.db.getConnection (err, connection) ->
        return next err if err

        connection.query 'SELECT * FROM bukkit_enchantment'
        ,   (err, rows) ->
                do connection.end

                return next err if err
                return res.json 200, rows



###
Отдает чару.
###
app.get '/:enchantmentId', access, (req, res, next) ->
    req.db.getConnection (err, connection) ->
        return next err if err

        connection.query 'SELECT * FROM bukkit_enchantment WHERE id = ?'
        ,   [req.params.enchantmentId]
        ,   (err, rows) ->
                do connection.end

                return next err if err
                return res.json 404, null if not rows.length
                return res.json 200, do rows.shift



###
Обновляет чару.
###
app.put '/:enchantmentId', access, (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            con.query 'UPDATE bukkit_enchantment SET ? WHERE id = ?'
            ,   [req.body, req.params.enchantmentId]
            ,   (err, resp) ->
                    return done err, conn

        (conn, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn

    ],  (err, conn, shipment) ->
            do conn.end if conn

            return next err if err
            return res.json 200, req.body



###
Удаляет чару.
###
app.delete '/:enchantmentId', access, (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            con.query 'DELETE FROM bukkit_enchantment WHERE id = ?'
            ,   [req.params.enchantmentId]
            ,   (err, resp) ->
                    return done err, conn

        (conn, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn

    ],  (err, conn, shipment) ->
            do conn.end if conn

            return next err if err
            return res.json 200, {}
