express= require 'express'
async= require 'async'
fs= require 'fs'



class Db
    @syncDb: (conn, cb) ->
        async.waterfall [

            (done) ->
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

            (conn, done) ->
                #dumpDb= fs.readFileSync 'node/db/sql/apiserver.sql'
                #console.log dump

                dd = 'CREATE TABLE `apiserver`.`fqqffasd` (`id` INT(10) NOT NULL AUTO_INCREMENT, PRIMARY KEY (`id`))'
                conn.query dd, (err, resp) ->
                    return done err, conn

            (conn, done) ->
                conn.query 'COMMIT', (err) ->
                    return done err

        ],  (err) ->
                cb err



    @syncMaterial: (conn, database, cb) ->
        async.waterfall [

            (done) ->
                conn.query 'SET sql_mode="STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE"', (err) ->
                    return done err, conn if err
                    conn.query 'START TRANSACTION', (err) ->
                        return done err, conn

            (conn, done) ->
                conn.query '
                    USE ?'
                ,   [database]
                ,   (err, resp) ->
                        return done err, conn

            (conn, done) ->
                dumpMaterials= fs.readFileSync './node/db/sql/materials.sql'
                console.log dumpMaterials
                #conn.query dump, (err, resp) ->
                #    return done err, conn, instance

            (conn, done) ->
                conn.query 'COMMIT', (err) ->
                    return done err, conn

        ],  (err, conn) ->
                cb err




module.exports= Db
