crypto= require 'crypto'

module.exports= class User
    @table: 'users_user'



    constructor: (data) ->
        @id= data.id if data.id
        @name= data.name
        @pass= User.sha1 data.pass





    @login: (user, maria, done) ->
        return done 'not a User' if not (user instanceof @)

        delete user.id if user.id


        maria.query '
            SELECT
                object.id,
                object.name
            FROM
                ?? AS object
            WHERE
                name = ?
                AND
                pass = ?'
        ,   [@table, user.name, user.pass]
        ,   (err, rows) ->
                user= null
                if not err and rows.length
                    user= rows[0]

                done err, user



    @sha1: (string) ->
        hash= crypto.createHash 'sha1'
        hash.update string
        return hash.digest 'hex'










    @query: (maria, done) ->
        maria.query '
            SELECT
                server.id,
                server.title,
                server.name,
                server.key
            FROM ?? AS server'
        ,   [@table]
        ,   (err, rows) =>
                done err, rows



    @get: (serverId, maria, done) ->
        maria.query '
            SELECT
                server.id,
                server.title,
                server.name,
                server.key
            FROM ?? AS server
            WHERE id = ?'
        ,   [@table, serverId]
        ,   (err, rows) =>
                server= null

                if not err and rows.length
                    server= new @ rows[0]

                done err, server




    @update: (serverId, server, maria, done) ->
        return done 'not a Server' if not (server instanceof @)

        delete server.id if server.id

        maria.query '
            UPDATE
                ??
            SET
                ?
            WHERE
                id = ?'
        ,   [@table, server, serverId]
        ,   (err, res) ->

                if not err and res.affectedRows != 1
                    err= 'server update error'

                done err, server



    @delete: (serverId, maria, done) ->
        maria.query '
            DELETE
            FROM
                ??
            WHERE
                id = ?'
        ,   [@table, serverId]
        ,   (err, res) ->

                if not err and res.affectedRows != 1
                    err= 'server delete error'

                done err
