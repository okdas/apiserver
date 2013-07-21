async= require 'async'




exports.isInstall= (req, res, next) ->
    config= app.get 'config'

    if config.installed
        return next 404

    return do next






exports.install= (req, res, next) ->
    return res.render 'Management/Install'


exports.db= (req, res, next) ->
    return res.json
        models: Object.keys req.models
        driver:
            name: req.db.driver_name
            config: req.db.driver.config
            options: req.db.driver.opts


exports.dbSync= (req, res, next) ->
    req.db.sync (err) ->
        # ошибка при запиливании базы данных
        return next err if err
        # база данных запилена
        return res.json true


exports.dbDrop= (req, res, next) ->
    req.db.drop (err) ->
        return next err if err
        return res.json true



exports.listModels= (req, res, next) ->
    return res.json Object.keys req.models



exports.getModel= (req, res, next) ->
    modelName= req.param 'modelName'
    return res.json !!req.models[modelName]


exports.modelSync= (req, res, next) ->
    modelName= req.param 'modelName'
    req.models[modelName].sync (err) ->
        return next err if err
        return res.json true



exports.modelDrop= (req, res, next) ->
    modelName= req.param 'modelName'
    req.models[modelName].drop (err) ->
        return next err if err
        return res.json true




