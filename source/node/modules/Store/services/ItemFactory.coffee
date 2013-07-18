async= require 'async'

module.exports= class ItemFactory

    constructor: (@db, @q, @table) ->

    query: (done) ->
        @db.getConnection (err, connection) =>
            query= @q.select().from(@table).build()
            connection.query query, (err, items) ->
                do connection.end
                process.nextTick ->
                    return done err, items

    create: (data, done) ->
        item=
            title: data.title
        @db.getConnection (err, connection) =>
            query= @q.insert().into(@table).set(item).build()
            connection.query query, (err, res) =>
                if err
                    do connection.end
                    process.nextTick ->
                        return done err
                else
                    query= @q.select().from(@table).where({itemId: res.insertId}).build()
                    connection.query query, (err, items) =>
                        do connection.end
                        if not err
                            item= do items.shift
                        process.nextTick ->
                            done err, item

    update: (id, data, done) ->
        item=
            title: data.title
        @db.getConnection (err, connection) =>
            query= @q.update().into(@table).set(item).where({itemId:id}).build()
            connection.query query, (err, res) =>
                if err
                    do connection.end
                    process.nextTick ->
                        return done err
                else
                    query= @q.select().from(@table).where({itemId: id}).build()
                    connection.query query, (err, items) =>
                        do connection.end
                        if not err
                            item= do items.shift
                        process.nextTick ->
                            done err, item

    delete: (id, done) ->
        @db.getConnection (err, connection) =>
            query= @q.remove().from(@table).where({itemId:id}).build()
            connection.query query, (err, res) =>
                do connection.end
                if not err
                    item=
                        itemId: id
                        deleted: true
                process.nextTick ->
                    return done err, item