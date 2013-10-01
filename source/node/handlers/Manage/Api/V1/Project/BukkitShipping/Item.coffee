express= require 'express'
async= require 'async'

###
Методы API для работы c шипментами.
###
app= module.exports= do express
app.on 'mount', (parent) ->
    app.set 'maria', maria= parent.get 'maria'



    app.get '/:serverKey/:playerName/list'
    ,   maria(app.get 'db')
    ,   server(maria.Server)
    ,   player(maria.Player)
    ,   getItems(maria.BukkitShipping)
    ,   getItemsEnchantment(maria.BukkitShipping)
    ,   (req, res) ->
            res.json 200, req.items

    app.get '/:serverKey/:playerName/shipments/list'
    ,   maria(app.get 'db')
    ,   server(maria.Server)
    ,   player(maria.Player)
    ,   getShipments(maria.BukkitShipping)
    ,   (req, res) ->
            res.json 200, req.shipments

    app.post '/:serverKey/:playerName/shipments/open'
    ,   access
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   server(maria.Server)
    ,   player(maria.Player)
    ,   openShipment(maria.BukkitShipping)
    ,   maria.transaction.commit()
    ,   (req, res) ->
            res.json 200, req.shipment

    app.get '/:serverKey/:playerName/shipments/:shipmentId(\\d+)/close'
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   server(maria.Server)
    ,   player(maria.Player)
    ,   closeShipment(maria.BukkitShipping)
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



server= (Server) -> (req, res, next) ->
    Server.getByKey req.params.serverKey, req.maria, (err, server) ->
        if server
            req.server= server
        else
            err=
                status: 404
                message: 'server not found'
        return next err



player= (Player) -> (req, res, next) ->
    Player.getByName req.params.playerName, req.maria, (err, player) ->
        if player
            req.player= player
        else
            err=
                status: 404
                message: 'player not found'
        return next err



getItems= (BukkitShipping) -> (req, res, next) ->
    BukkitShipping.queryItem req.player.id, req.server.id, req.maria, (err, items) ->
        req.items= items or null
        return next err

getItemsEnchantment= (BukkitShipping) -> (req, res, next) ->
    itemIds= []
    req.items.map (item, i) ->
        req.items[i].enchantments= []
        itemIds.push item.id

    BukkitShipping.queryEnchantment itemIds, req.maria, (err, enchantments) ->
        enchantments.map (ench) ->
            req.items.map (item, i) ->
                if item.id == ench.id
                    req.items[i].enchantments.push ench

        return next err



getShipments= (BukkitShipping) -> (req, res, next) ->
    BukkitShipping.queryShipment req.player.id, req.server.id, req.maria, (err, shipments) ->
        req.shipments= shipments or null
        return next err



checkItems= (BukkitShipping) -> (req, res, next) ->
    itemIds= []
    req.body.map (item) ->
        itemIds.push item.id

    BukkitShipping.getItems itemIds, req.maria, (err, items) ->
        shipment=
            id: ''
            items: []

        items.map (tableItem) ->
            req.body.map (reqItem) ->
                if tableItem.id == parseInt reqItem.id
                    shipment.items.push
                        id: tableItem.id
                        amount: parseInt (if reqItem.amount > tableItem.amount then tableItem.amount else reqItem.amount)

openShipment= (BukkitShipping) -> (req, res, next) ->
    BukkitShipping.closeShipment req.params.playerName, req.maria, (err, items) ->
        req.items= items or null
        return next err

createShipmentItems= (BukkitShipping) -> (req, res, next) ->
    BukkitShipping.closeShipment req.params.playerName, req.maria, (err, items) ->
        req.items= items or null
        return next err



closeShipment= (BukkitShipping) -> (req, res, next) ->
    BukkitShipping.closeShipment req.params.playerName, req.maria, (err, items) ->
        req.items= items or null
        return next err








