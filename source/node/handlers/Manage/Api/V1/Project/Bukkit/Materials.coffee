express= require 'express'



###
Методы API для работы c чарами.
###
app= module.exports= do express
app.on 'mount', (parent) ->
    app.set 'maria', maria= parent.get 'maria'



    app.post '/'
    ,   access
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   createMaterial(maria.Material)
    ,   maria.transaction.commit()
    ,   (req, res) ->
            res.json 200, req.material

    app.get '/'
    ,   access
    ,   maria(app.get 'db')
    ,   getMaterials(maria.Material)
    ,   (req, res) ->
            res.json 200, req.materials

    app.get '/:materialId(\\d+)'
    ,   access
    ,   maria(app.get 'db')
    ,   getMaterial(maria.Material)
    ,   (req, res) ->
            res.json 200, req.material

    app.put '/:materialId(\\d+)'
    ,   access
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   updateMaterial(maria.Material)
    ,   maria.transaction.commit()
    ,   (req, res) ->
            res.json 200, req.material

    app.delete '/:materialId(\\d+)'
    ,   access
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   deleteMaterial(maria.Material)
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



###
Добавляет материал.
###
createMaterial= (Material) -> (req, res, next) ->
    newMaterial= new Material req.body
    Material.create newMaterial, req.maria, (err, material) ->
        req.material= material or null
        return next err



getMaterials= (Material) -> (req, res, next) ->
    Material.query req.maria, (err, materials) ->
        req.materials= materials or null
        return next err



getMaterial= (Material) -> (req, res, next) ->
    Material.get req.params.materialId, req.maria, (err, material) ->
        req.material= material or null
        return next err



updateMaterial= (Material) -> (req, res, next) ->
    newMaterial= new Material req.body
    Material.update req.params.materialId, newMaterial, req.maria, (err, material) ->
        req.material= material or null
        return next err



deleteMaterial= (Material) -> (req, res, next) ->
    Material.delete req.params.materialId, req.maria, (err) ->
        return next err
