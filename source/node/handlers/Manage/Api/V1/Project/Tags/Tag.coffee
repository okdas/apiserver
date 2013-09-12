express= require 'express'
async= require 'async'




###
Методы API для платежей
###
app= module.exports= do express
app.on 'mount', (parent) ->
    cfg= parent.get 'config'



    app.post '/'
    ,   access
    ,   createTag
    ,   (req, res) ->
            res.json 200

    app.get '/'
    ,   access
    ,   getTags
    ,   (req, res) ->
            res.json 200

    app.get '/server/:serverId(\\d+)'
    ,   access
    ,   getServerTags
    ,   (req, res) ->
            res.json 200

    app.get '/items/:tagId(\\d+)'
    ,   access
    ,   getTagItems
    ,   (req, res) ->
            res.json 200

    app.get '/srv/:tagId(\\d+)'
    ,   access
    ,   getServerItems
    ,   (req, res) ->
            res.json 200

    app.put '/srv/:tagId(\\d+)'
    ,   access
    ,   changeTagConnection
    ,   (req, res) ->
            res.json 200

    app.get '/:tagId(\\d+)'
    ,   access
    ,   getTag
    ,   (req, res) ->
            res.json 200

    app.put '/:tagId(\\d+)'
    ,   access
    ,   changeTag
    ,   (req, res) ->
            res.json 200

    app.delete '/:tagId(\\d+)'
    ,   access
    ,   deleteTag
    ,   (req, res) ->
            res.json 200





access= (req, res, next) ->
    return next 401 if do req.isUnauthenticated
    return do next



createTag= (req, res, next) ->
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
                name: req.body.name
                titleRuSingular: req.body.titleRuSingular
                titleRuPlural: req.body.titleRuPlural
                titleEnSingular: req.body.titleEnSingular
                titleEnPlural: req.body.titleEnPlural

            conn.query 'INSERT INTO tag SET ?'
            ,   [data]
            ,   (err, resp) ->
                    tag= req.body
                    tag.id= resp.insertId

                    return done err, conn, tag

        (conn, tag, done) ->
            # а есть ли сервера
            if not req.body.inheritTags
                return done null, conn

            bulk= []
            for tagInh in req.body.inheritTags
                bulk.push [tag.id, tagInh.id]
            conn.query "
                INSERT INTO tag_tags
                    (`tagId`, `childId`)
                VALUES ?
                "
            ,   [bulk]
            ,   (err, resp) ->
                    return done err, conn, tag

        (conn, tag, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn, tag

    ],  (err, conn, tag) ->
            do conn.end if conn

            return next err if err
            return res.json 200, tag



getTags= (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query '
                SELECT * FROM tag'
            ,   (err, rows) ->
                    return done err, conn, rows

        (conn, tags, done) ->
            conn.query '
                SELECT
                    *
                FROM tag_tags AS connection
                JOIN tag AS tag
                    ON connection.childId = tag.id'
            ,   (err, rows) ->
                    tags.map (tag, i) ->
                        tags[i].inheritTags= []

                        rows.map (r) ->
                            if tag.id == r.tagId
                                tags[i].inheritTags.push
                                    id: r.id
                                    name: r.name

                    return done err, conn, tags

    ],  (err, conn, rows) ->
            do conn.end if conn

            return next err if err
            return res.json 200, rows



getServerTags= (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query '
                SELECT * FROM tag AS tag
                JOIN server_tag AS server
                    ON server.tagId = tag.id
                WHERE server.serverId = ?'
            ,   [req.params.serverId]
            ,   (err, rows) ->
                    return done err, conn, rows

    ],  (err, conn, rows) ->
            do conn.end if conn

            return next err if err
            return res.json 200, rows


###
Получить айтемы определенного тега
###
getTagItems= (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query '
                SELECT
                    tag.id,
                    tag.name,
                    tag.titleRuSingular,
                    tag.titleRuPlural,
                    tag.titleEnSingular,
                    tag.titleEnPlural
                FROM tag AS tag
                WHERE tag.id = ?'
            ,   [req.params.tagId]
            ,   (err, resp) ->
                    tag= do resp.shift if not err

                    return done err, conn, tag

        (conn, tag, done) ->
            conn.query '
                SELECT
                    *
                FROM item_tag AS connection
                LEFT JOIN item AS item
                    ON item.id = connection.itemId
                WHERE connection.tagId = ?'
            ,   [req.params.tagId]
            ,   (err, rows) ->
                    tag.items= rows
                    return done err, conn, tag

    ],  (err, conn, tag) ->
            do conn.end if conn

            return next err if err
            return res.json 200, tag



###
Получить айтемы через жопу
###
getServerItems= (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query '
                SELECT
                    item.*
                FROM server_tag AS serverTag
                JOIN server_item AS serverItem
                    ON serverItem.serverId = serverTag.serverId
                JOIN item AS item
                    ON item.id = serverItem.itemId
                WHERE serverTag.tagId = ?'
            ,   [req.params.tagId]
            ,   (err, rows) ->
                    return done err, conn, rows

    ],  (err, conn, rows) ->
            do conn.end if conn

            return next err if err
            return res.json 200, rows



changeTagConnection= (req, res, next) ->
    tagId= req.params.tagId
    delete req.body.id

    items= req.body.items

    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            conn.query 'DELETE FROM item_tag WHERE tagId = ?'
            ,   [tagId]
            ,   (err, resp) ->
                    return done err, conn if err
                    return done err, conn if not items.length

                    bulk= []
                    for item in items
                        bulk.push [tagId, item.id]
                    conn.query '
                        INSERT INTO item_tag (`tagId`, `itemId`) VALUES ?
                        '
                    ,   [bulk]
                    ,   (err, resp) ->
                            return done err, conn

        (conn, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn

    ],  (err, conn) ->
            do conn.end if conn

            return next err if err
            return res.json 200




getTag= (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query '
                SELECT * FROM tag WHERE id = ?'
            ,   [req.params.tagId]
            ,   (err, resp) ->
                    tag= do resp.shift if not err
                    return done err, conn, tag

        (conn, tag, done) ->
            conn.query '
                SELECT
                    *
                FROM tag_tags AS connection
                JOIN tag AS tag
                    ON connection.childId = tag.id
                WHERE connection.tagId = ?'
            ,   [req.params.tagId]
            ,   (err, rows) ->
                    tag.inheritTags= []

                    rows.map (r) ->
                        if tag.id == r.tagId
                            tag.inheritTags.push
                                id: r.id
                                name: r.name

                    return done err, conn, tag

    ],  (err, conn, tag) ->
            do conn.end if conn

            return next err if err
            return res.json 200, tag



changeTag= (req, res, next) ->
    tagId= req.params.tagId
    delete req.body.id

    tag= req.body

    inheritTags= tag.inheritTags or []
    delete tag.inheritTags

    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            conn.query 'UPDATE tag SET ? WHERE id = ?'
            ,   [tag, req.params.tagId]
            ,   (err, resp) ->
                    tag= req.body
                    tag.id= req.params.tagId
                    return done err, conn, tag

        (conn, tag, done) ->
            conn.query 'DELETE FROM tag_tags WHERE tagId = ?'
            ,   [tagId]
            ,   (err, resp) ->
                    return done err, conn if err
                    return done err, conn if not inheritTags.length

                    bulk= []
                    for inherit in inheritTags
                        bulk.push [tagId, inherit.id]
                    conn.query 'INSERT INTO tag_tags (`tagId`, `childId`) VALUES ?'
                    ,   [bulk]
                    ,   (err, resp) ->
                            return done err, conn, tag

        (conn, tag, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn, tag

    ],  (err, conn, tag) ->
            do conn.end if conn

            return next err if err
            return res.json 200, tag



deleteTag= (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            conn.query 'DELETE FROM tag WHERE id = ?'
            ,   [req.params.tagId]
            ,   (err, resp) ->
                    return done err, conn

        (conn, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn

    ],  (err, conn) ->
            do conn.end if conn

            return next err if err
            return res.json 200
