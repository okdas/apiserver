express= require 'express'



###
Методы API для работы c предметами.
###
app= module.exports= do express
app.on 'mount', (parent) ->
    app.set 'maria', maria= parent.get 'maria'



    app.post '/'
    ,   access
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   createItem(maria.Item)
    ,   createItemServer(maria.ItemServer)
    ,   createItemTag(maria.ItemTag)
    ,   createItemEnchantment(maria.ItemEnchantment)
    ,   maria.transaction.commit()
    ,   (req, res) ->
            res.json 200, req.item

    app.get '/'
    ,   access
    ,   maria(app.get 'db')
    ,   getItems(maria.Item)
    ,   getItemsServer(maria.ItemServer)
    ,   (req, res) ->
            res.json 200, req.items

    app.get '/:itemId(\\d+)'
    ,   access
    ,   maria(app.get 'db')
    ,   getItem(maria.Item)
    ,   getItemServer(maria.ItemServer)
    ,   getItemTag(maria.ItemTag)
    ,   getItemEnchantment(maria.ItemEnchantment)
    ,   (req, res) ->
            res.json 200, req.item

    app.put '/:itemId(\\d+)'
    ,   access
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   updateItem(maria.Item)
    ,   updateItemServer(maria.ItemServer)
    ,   updateItemTag(maria.ItemTag)
    ,   updateItemEnchantment(maria.ItemEnchantment)
    ,   maria.transaction.commit()
    ,   (req, res) ->
            res.json 200, req.item

    app.delete '/:itemId(\\d+)'
    ,   access
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   deleteItem(maria.Item)
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





createItem= (Item) -> (req, res, next) ->
    console.log 'REQ', req.body
    newItem= new Item req.body
    Item.create newItem, req.maria, (err, item) ->
        req.item= item or null
        return next err

createItemServer= (ItemServer) -> (req, res, next) ->
    newItemServer= new ItemServer req.body.servers
    ItemServer.create req.item.id, newItemServer, req.maria, (err, servers) ->
        req.item.servers= servers or null
        return next err

createItemTag= (ItemTag) -> (req, res, next) ->
    newItemTag= new ItemTag req.body.tags
    ItemTag.create req.item.id, newItemTag, req.maria, (err, tags) ->
        req.item.tags= tags or null
        return next err

createItemEnchantment= (ItemEnchantment) -> (req, res, next) ->
    newItemEnchantment= new ItemEnchantment req.body.enchantments
    ItemEnchantment.create req.item.id, newItemEnchantment, req.maria, (err, enchantments) ->
        req.item.enchantments= enchantments or null
        return next err



###
Отдает список серверов.
###
getItems= (Item) -> (req, res, next) ->
    Item.query req.maria, (err, items) ->
        req.items= items or null
        return next err

getItemsServer= (ItemServer) -> (req, res, next) ->
    ItemServer.query req.maria, (err, servers) ->
        req.items.map (item, i) ->
            req.items[i].servers= []

            servers.map (row) ->
                if item.id == row.itemId
                    req.items[i].servers.push row
        return next err

getItemsTag= (ItemTag) -> (req, res, next) ->
    ItemTag.query req.maria, (err, tags) ->
        req.items.map (item, i) ->
            req.items[i].tags= []

            tags.map (row) ->
                if item.id == row.itemId
                    req.items[i].tags.push row
        return next err





###
Отдает айтем.
###
getItem= (Item) -> (req, res, next) ->
    Item.get req.params.itemId, req.maria, (err, item) ->
        req.item= item or null
        return next err

getItemServer= (ItemServer) -> (req, res, next) ->
    ItemServer.get req.params.itemId, req.maria, (err, servers) ->
        req.item.servers= servers
        return next err

getItemTag= (ItemTag) -> (req, res, next) ->
    ItemTag.get req.params.itemId, req.maria, (err, tags) ->
        req.item.tags= tags
        return next err

getItemEnchantment= (ItemEnchantment) -> (req, res, next) ->
    ItemEnchantment.get req.params.itemId, req.maria, (err, enchantments) ->
        req.item.enchantments= enchantments
        return next err



###
Изменяет сервер
###
updateItem= (Item) -> (req, res, next) ->
    newItem= new Item req.body
    Item.update req.params.itemId, newItem, req.maria, (err, item) ->
        req.item= item or null
        return next err

updateItemServer= (ItemServer) -> (req, res, next) ->
    newItemServer= new ItemServer req.body.servers
    ItemServer.create req.params.itemId, newItemServer, req.maria, (err, servers) ->
        req.item.servers= servers or null
        return next err

updateItemTag= (ItemTag) -> (req, res, next) ->
    newItemTag= new ItemTag req.body.tags
    ItemTag.create req.params.itemId, newItemTag, req.maria, (err, tags) ->
        req.item.tags= tags or null
        return next err

updateItemEnchantment= (ItemEnchantment) -> (req, res, next) ->
    newItemEnchantment= new ItemEnchantment req.body.enchantments
    ItemEnchantment.create req.params.itemId, newItemEnchantment, req.maria, (err, enchantments) ->
        req.item.enchantments= enchantments or null
        return next err




###
Удаляет сервер
###
deleteItem= (Item) -> (req, res, next) ->
    Item.delete req.params.itemId, req.maria, (err) ->
        return next err
