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
            # а есть ли родительские теги
            if not req.body.parentTags
                return done null, conn, tag

            bulk= []
            for parent in req.body.parentTags
                bulk.push [parent.id, tag.id]

            conn.query '
                INSERT INTO tag_tags
                    (`tagId`, `childId`)
                VALUES ?'
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
                SELECT
                    tag.*,
                    connection.serverId
                FROM tag AS tag
                LEFT JOIN server_tag AS connection
                    ON connection.tagId = tag.id
                GROUP BY tag.id'
            ,   (err, rows) ->
                    return done err, conn, rows

        (conn, tags, done) ->
            conn.query '
                SELECT
                    *
                FROM tag_tags AS connection
                JOIN tag AS tag
                    ON connection.tagId = tag.id'
            ,   (err, rows) ->
                    tags.map (tag, i) ->
                        tags[i].parentTags= []

                        rows.map (r) ->
                            if tag.id == r.childId
                                tags[i].parentTags.push
                                    id: r.id
                                    name: r.name

                    return done err, conn, tags

    ],  (err, conn, rows) ->
            do conn.end if conn

            return next err if err
            return res.json 200, rows



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
                    ON connection.tagId = tag.id
                WHERE connection.childId = ?'
            ,   [req.params.tagId]
            ,   (err, rows) ->
                    tag.parentTags= rows


                    #rows.map (r) ->
                    #    if tag.id == r.tagId
                    #        tag.parentTags.push
                    #            id: r.id
                    #            name: r.name

                    return done err, conn, tag

    ],  (err, conn, tag) ->
            do conn.end if conn

            return next err if err
            return res.json 200, tag



changeTag= (req, res, next) ->
    tagId= req.params.tagId
    delete req.body.id

    tag= req.body

    parentTags= tag.parentTags or []
    delete tag.parentTags

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
                name: tag.name
                titleRuSingular: tag.titleRuSingular
                titleRuPlural: tag.titleRuPlural
                titleEnSingular: tag.titleEnSingular
                titleEnPlural: tag.titleEnPlural

            conn.query 'UPDATE tag SET ? WHERE id = ?'
            ,   [data, req.params.tagId]
            ,   (err, resp) ->
                    tag= req.body
                    tag.id= req.params.tagId
                    return done err, conn, tag

        (conn, tag, done) ->
            conn.query 'DELETE FROM tag_tags WHERE childId = ?'
            ,   [tagId]
            ,   (err, resp) ->
                    return done err, conn, tag if err
                    return done err, conn, tag if not parentTags.length

                    bulk= []
                    for parent in parentTags
                        bulk.push [parent.id, tagId]

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
