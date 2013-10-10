express= require 'express'



###
Методы API для работы c инстансами серверов.
###
app= module.exports= do express
app.on 'mount', (parent) ->
    app.set 'maria', maria= parent.get 'maria'



    app.post '/'
    ,   access
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   createInstance(maria.Instance)
    ,   maria.transaction.commit()
    ,   (req, res) ->
            res.json 200, req.instance

    app.get '/'
    ,   access
    ,   maria(app.get 'db')
    ,   getInstances(maria.Instance)
    ,   (req, res) ->
            res.json 200, req.instances

    app.get '/:instanceId(\\d+)'
    ,   access
    ,   maria(app.get 'db')
    ,   getInstance(maria.Instance)
    ,   (req, res) ->
            res.json 200, req.instance

    app.put '/:instanceId(\\d+)'
    ,   access
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   updateInstance(maria.Instance)
    ,   maria.transaction.commit()
    ,   (req, res) ->
            res.json 200, req.instance

    app.delete '/:instanceId(\\d+)'
    ,   access
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   deleteInstance(maria.Instance)
    ,   maria.transaction.commit()
    ,   (req, res) ->
            res.json 200



access= (req, res, next) ->
    err= null
    if do req.isUnauthenticated
        err=
            status: 401
            message: 'user not authenticated'

    return next err






createInstance= (Instance) -> (req, res, next) ->
    instance= new Instance req.body
    Instance.create instance, req.maria, (err, instance) ->
        req.instance= instance or null
        return next err



###
Отдает список серверов.
###
getInstances= (Instance) -> (req, res, next) ->
    Instance.query req.maria, (err, instances) ->
        req.instances= instances or null
        return next err



###
Отдает сервер.
###
getInstance= (Instance) -> (req, res, next) ->
    Instance.get req.params.instanceId, req.maria, (err, instance) ->
        req.instance= instance or null
        return next err



###
Изменяет сервер
###
updateInstance= (Instance) -> (req, res, next) ->
    instance= new Instance req.body
    Instance.update req.params.instanceId, instance, req.maria, (err, instance) ->
        req.instance= instance or null
        return next err



###
Удаляет сервер
###
deleteInstance= (Instance) -> (req, res, next) ->
    Instance.delete req.params.instanceId, req.maria, (err) ->
        return next err
