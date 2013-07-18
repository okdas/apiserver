async= require 'async'

module.exports= class PackageFactory

    constructor: (@db, @q, @table) ->

    query: (done) ->
        @db.getConnection (err, connection) =>
            query= @q.select().from(@table).build()
            connection.query query, (err, pkgs) =>
                if err
                    do connection.end
                    process.nextTick ->
                        return done err
                else
                    async.map pkgs
                    ,   (pkg, done) =>
                            id= pkg.packageId
                            query= @q.select().from('store-package-items').where({packageId:id}).build()
                            connection.query query, (err, items) ->
                                if not err
                                    pkg.items= items
                                done err, pkg
                    ,   (err, pkgs) ->
                            do connection.end
                            process.nextTick ->
                                done err, pkgs

    create: (data, done) ->
        pkg=
            title: data.title
        @db.getConnection (err, connection) =>
            query= @q.insert().into(@table).set(pkg).build()
            connection.query query, (err, res) =>
                if err
                    do connection.end
                    process.nextTick ->
                        return done err
                else
                    query= @q.select().from(@table).where({packageId: res.insertId}).build()
                    connection.query query, (err, pkgs) =>
                        do connection.end
                        if not err
                            pkg= do pkgs.shift
                        process.nextTick ->
                            done err, pkg