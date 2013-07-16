module.exports= class Server

    constructor: (@db) ->

    query: (done) ->
        @db.getConnection (err, conn) ->
            conn.query 'SELECT * FROM server', (err, rows) ->
                process.nextTick ->
                    done err, rows
                do conn.end