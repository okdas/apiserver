express= require 'express'
async= require 'async'
fs= require 'fs'



class Db
    @syncTables: (conn, cb) ->
        async.waterfall [

            (done) ->
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

            (conn, done) ->
                dumpTables= fs.readFileSync 'node/db/sql/apiserver.sql'
                console.log dumpTables
                #conn.query dd, (err, resp) ->
                    #return done err, conn

            (conn, done) ->
                conn.query 'COMMIT', (err) ->
                    return done err

        ],  (err) ->
                return cb err



    @syncMaterial: (conn, cb) ->
        async.waterfall [

            (done) ->
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

            (conn, done) ->
                dumpMaterials= fs.readFileSync 'app/node/db/sql/materials.sql', 'encoding':'utf-8'

                conn.query dumpMaterials, (err, resp) ->
                    return done err, conn

            (conn, done) ->
                conn.query 'COMMIT', (err) ->
                    return done err

        ],  (err) ->
                return cb err




module.exports= Db
