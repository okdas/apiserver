async= require 'async'

module.exports= (req, res, next) ->
    return res.json 400, null if not req.query.key

    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query 'SELECT * FROM server_instance WHERE `key` = ?'
            ,   [req.query.key]
            ,   (err, resp) ->
                    instance= do resp.shift if not err
                    return done err, conn, instance

    ],  (err, conn, instance) ->
            do conn.end if conn

            return res.json 400, err if err
            return res.json 404, null if not instance

            req.instance= instance
            return do next

