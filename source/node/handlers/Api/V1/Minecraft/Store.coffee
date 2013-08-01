express= require 'express'
async= require 'async'

###
Методы API для работы c магазином.
###
app= module.exports= do express



###
Отдает аутентифицированному игроку.
###
app.get '/', (req, res, next) ->
    setTimeout ->
        res.json
            servers: [
                {
                    id: 1
                    name: 'sandbox'
                    storage: {
                        items: [

                        ]
                    }
                    store: {
                        items: [
                            {id:10, title:'Камень', imgUrl:'http://media-mcw.cursecdn.com/ru/3/3b/Grid_%D0%9A%D0%B0%D0%BC%D0%B5%D0%BD%D1%8C.png', price:0.5}
                            {id:20, title:'Трава', imgUrl:'http://media-mcw.cursecdn.com/ru/0/08/Grid_%D0%A2%D1%80%D0%B0%D0%B2%D0%B0.png', price:0.7}
                            {id:30, title:'Земля', imgUrl:'http://media-mcw.cursecdn.com/ru/c/c8/Grid_%D0%97%D0%B5%D0%BC%D0%BB%D1%8F.png', price:0.3}
                        ]
                    }
                },{
                    id: 2
                    name: 'sandbox'
                    storage: {
                        items: [

                        ]
                    }
                    store: {
                        items: [
                            {id:10, title:'Камень', imgUrl:'http://media-mcw.cursecdn.com/ru/3/3b/Grid_%D0%9A%D0%B0%D0%BC%D0%B5%D0%BD%D1%8C.png', price:0.5}
                            {id:20, title:'Трава', imgUrl:'http://media-mcw.cursecdn.com/ru/0/08/Grid_%D0%A2%D1%80%D0%B0%D0%B2%D0%B0.png', price:0.7}
                            {id:30, title:'Земля', imgUrl:'http://media-mcw.cursecdn.com/ru/c/c8/Grid_%D0%97%D0%B5%D0%BC%D0%BB%D1%8F.png', price:0.3}
                            {id:9000, title:'Ракетный ранец', imgUrl:'http://media-mcw.cursecdn.com/ru/c/c8/Grid_%D0%97%D0%B5%D0%BC%D0%BB%D1%8F.png', price:100}
                        ]
                    }
                },{
                    id: 3
                    name: 'magik'
                    storage: {
                        items: [

                        ]
                    }
                    store: {
                        items: [
                            {id:10, title:'Камень', imgUrl:'http://media-mcw.cursecdn.com/ru/3/3b/Grid_%D0%9A%D0%B0%D0%BC%D0%B5%D0%BD%D1%8C.png', price:0.5}
                            {id:20, title:'Трава', imgUrl:'http://media-mcw.cursecdn.com/ru/0/08/Grid_%D0%A2%D1%80%D0%B0%D0%B2%D0%B0.png', price:0.7}
                            {id:30, title:'Земля', imgUrl:'http://media-mcw.cursecdn.com/ru/c/c8/Grid_%D0%97%D0%B5%D0%BC%D0%BB%D1%8F.png', price:0.3}
                        ]
                    }
                }
            ]
    ,   500



###
Выставляет счет на покупку переданных предметов аутентифицированному игроку.
###
app.post '/order', (req, res, next) ->
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
                playerId: req.user.id
            conn.query 'INSERT INTO store_order SET ?'
            ,   [data]
            ,   (err, resp) ->
                    id= resp.insertId if not err
                    return done err, conn, id

        (conn, id, done) ->
            bulk= []
            for server in req.body.servers
                for item in server.items
                    bulk.push [req.user.id, server.id, id, item.id, item.amount]
            conn.query 'INSERT INTO storage_item (`playerId`, `serverId`, `orderId`, `itemId`, `amount`) VALUES ?'
            ,   [bulk]
            ,   (err, resp) ->
                    done err, conn

        (conn, done) ->
            conn.query 'COMMIT', (err) ->
                return done err, conn

    ],  (err, conn) ->
            do conn.end if conn
            return next err if err