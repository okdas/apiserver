express= require 'express'
async= require 'async'

###
Методы API для работы c форумом
###
app= module.exports= do express



###
Отдает список форумов и секций
###
app.get '/list', (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query '
                SELECT * FROM forum;
                SELECT * FROM forum_section;'
            ,   (err, rows) ->
                    forums= []
                    rows[0].map (forum, i) ->
                        forum=
                            id: forum.id
                            title: forum.title
                            sections: []

                        rows[1].map (section, i) ->
                            if section.forumId == forum.id
                                forum.sections.push section

                        forums.push forum

                    return done err, conn, forums

    ],  (err, conn, forums) ->
            do conn.end if conn

            return next err if err
            return res.json 200, forums



###
Отдает форум.
###
app.get '/:forumId', (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn

        (conn, done) ->
            conn.query '
                SELECT * FROM forum WHERE id = ?;
                SELECT * FROM forum_section WHERE forumId = ?'
            ,   [req.params.forumId, req.params.forumId]
            ,   (err, rows) ->
                    forum=
                        id: rows[0][0].id
                        title: rows[0][0].title
                        sections: rows[1]

                    return done err, conn, forum

    ],  (err, conn, forum) ->
            do conn.end if conn

            return next err if err
            return res.json 404, null if not forum
            return res.json 200, forum



###
Изменяет инстанс
###
app.put '/:forumId', (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            conn.query 'UPDATE forum SET ? WHERE id = ?'
            ,   [req.body, req.params.forumId]
            ,   (err, resp) ->
                    forum= req.body
                    forum.id= req.params.forumId
                    return done err, conn, forum

        (conn, forum, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn, forum

    ],  (err, conn, forum) ->
            do conn.end if conn

            return next err if err
            return res.json 200, forum



###
Удаляет форум
###
app.delete '/:forumId', (req, res, next) ->
    async.waterfall [

        (done) ->
            req.db.getConnection (err, conn) ->
                return done err, conn if err
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

        (conn, done) ->
            conn.query 'DELETE FROM forum WHERE id = ?'
            ,   [req.params.forumId]
            ,   (err, resp) ->
                    return done err, conn

        (conn, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn

    ],  (err, conn) ->
            do conn.end if conn

            return next err if err
            return res.json 200

