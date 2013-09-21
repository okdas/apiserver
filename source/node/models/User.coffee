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



    @create: (user, maria, done) ->
        return done 'not a User' if not (user instanceof @)

        delete user.id if user.id


        maria.query '
            INSERT
            INTO
                ??
            SET
                ?'
        ,   [@table, user]
        ,   (err, res) ->
                if not err && res.affectedRows != 1
                    err= 'user insert error'

                user.id= res.insertId

                done err, user



    @query: (maria, done) ->
        maria.query '
            SELECT
                object.id,
                object.name,
                object.pass
            FROM ?? AS object'
        ,   [@table]
        ,   (err, rows) =>
                done err, rows



    @get: (userId, maria, done) ->
        maria.query '
            SELECT
                object.id,
                object.name,
                object.pass
            FROM ?? AS object
            WHERE id = ?'
        ,   [@table, userId]
        ,   (err, rows) =>
                user= null

                if not err and rows.length
                    user= new @ rows[0]

                done err, user



    @update: (userId, user, maria, done) ->
        return done 'not a User' if not (user instanceof @)

        delete user.id if user.id

        maria.query '
            UPDATE
                ??
            SET
                ?
            WHERE
                id = ?'
        ,   [@table, user, userId]
        ,   (err, res) ->

                if not err and res.affectedRows != 1
                    err= 'user update error'

                done err, user



    @delete: (userId, maria, done) ->
        maria.query '
            DELETE
            FROM
                ??
            WHERE
                id = ?'
        ,   [@table, userId]
        ,   (err, res) ->

                if not err and res.affectedRows != 1
                    err= 'server delete error'

                done err
