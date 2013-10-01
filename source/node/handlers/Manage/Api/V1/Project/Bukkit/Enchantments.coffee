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
    ,   createEnchantment(maria.Enchantment)
    ,   maria.transaction.commit()
    ,   (req, res) ->
            res.json 200, req.enchantment

    app.get '/'
    ,   access
    ,   maria(app.get 'db')
    ,   getEnchantments(maria.Enchantment)
    ,   (req, res) ->
            res.json 200, req.enchantments

    app.get '/:enchantmentId(\\d+)'
    ,   access
    ,   maria(app.get 'db')
    ,   getEnchantment(maria.Enchantment)
    ,   (req, res) ->
            res.json 200, req.enchantment

    app.put '/:enchantmentId(\\d+)'
    ,   access
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   updateEnchantment(maria.Enchantment)
    ,   maria.transaction.commit()
    ,   (req, res) ->
            res.json 200, req.enchantment

    app.delete '/:enchantmentId(\\d+)'
    ,   access
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   deleteEnchantment(maria.Enchantment)
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
createEnchantment= (Enchantment) -> (req, res, next) ->
    newEnchantment= new Enchantment req.body
    Enchantment.create newEnchantment, req.maria, (err, enchantment) ->
        req.enchantment= enchantment or null
        return next err



getEnchantments= (Enchantment) -> (req, res, next) ->
    Enchantment.query req.maria, (err, enchantments) ->
        req.enchantments= enchantments or null
        return next err



getEnchantment= (Enchantment) -> (req, res, next) ->
    Enchantment.get req.params.enchantmentId, req.maria, (err, enchantment) ->
        req.enchantment= enchantment or null
        return next err



updateEnchantment= (Enchantment) -> (req, res, next) ->
    newEnchantment= new Enchantment req.body
    Enchantment.update req.params.enchantmentId, newEnchantment, req.maria, (err, enchantment) ->
        req.enchantment= enchantment or null
        return next err



deleteEnchantment= (Enchantment) -> (req, res, next) ->
    Enchantment.delete req.params.enchantmentId, req.maria, (err) ->
        return next err
