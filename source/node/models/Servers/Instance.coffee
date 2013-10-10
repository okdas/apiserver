module.exports= class Instance
    @table: 'server_instance'



    constructor: (data) ->
        @id= data.id if data.id
        @serverId= data.serverId if data.serverId
        @host= data.host if data.host
        @port= data.port if data.port



    @create: (instance, maria, done) ->
        return done 'not a Instance' if not (instance instanceof @)

        delete instance.id if instance.id

        maria.query '
            INSERT
            INTO
                ??
            SET
                ?'
        ,   [@table, instance]
        ,   (err, res) ->
                if not err && res.affectedRows != 1
                    err= 'instance insert error'

                instance.id= res.insertId

                done err, instance



    @query: (maria, done) ->
        maria.query '
            SELECT
                instance.id,
                instance.serverId,
                instance.host,
                instance.port
            FROM ?? AS instance'
        ,   [@table]
        ,   (err, rows) =>
                done err, rows



    @get: (instanceId, maria, done) ->
        maria.query '
            SELECT
                instance.id,
                instance.serverId,
                instance.host,
                instance.port
            FROM ?? AS instance
            WHERE id = ?'
        ,   [@table, instanceId]
        ,   (err, rows) =>
                instance= null

                if not err and rows.length
                    instance= new @ rows[0]

                done err, instance




    @update: (instanceId, instance, maria, done) ->
        return done 'not a Server' if not (instance instanceof @)

        delete instance.id if instance.id

        maria.query '
            UPDATE
                ??
            SET
                ?
            WHERE
                id = ?'
        ,   [@table, instance, instanceId]
        ,   (err, res) ->

                if not err and res.affectedRows != 1
                    err= 'instance update error'

                done err, instance



    @delete: (instanceId, maria, done) ->
        maria.query '
            DELETE
            FROM
                ??
            WHERE
                id = ?'
        ,   [@table, instanceId]
        ,   (err, res) ->

                if not err and res.affectedRows != 1
                    err= 'instance delete error'

                done err
