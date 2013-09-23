express= require 'express'
async= require 'async'

access= (req, res, next) ->
    return next 401 if do req.isUnauthenticated
    return do next

###
Методы API для работы c игроками.
###
app= module.exports= do express
app.on 'mount', (parent) ->
    app.set 'maria', maria= parent.get 'maria'



    app.post '/'
    ,   access
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   createPlayer(maria.Player)
    ,   createPlayerBalance(maria.PlayerBalance)
    ,   maria.transaction.commit()
    ,   (req, res) ->
            res.json 200, req.player

    app.get '/'
    ,   access
    ,   maria(app.get 'db')
    ,   getPlayers(maria.Player)
    ,   (req, res) ->
            res.json 200, req.players

    app.get '/:playerId(\\d+)'
    ,   access
    ,   maria(app.get 'db')
    ,   getPlayer(maria.Player)
    ,   getPlayerBalance(maria.PlayerBalance)
    ,   (req, res) ->
            res.json 200, req.player

    app.put '/:playerId(\\d+)'
    ,   access
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   updatePlayer(maria.Player)
    ,   maria.transaction.commit()
    ,   (req, res) ->
            res.json 200, req.player

    app.get '/activate/:playerId(\\d+)'
    ,   access
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   activatePlayer(maria.Player)
    ,   maria.transaction.commit()
    ,   (req, res) ->
            res.json 200

    app.get '/deactivate/:playerId(\\d+)'
    ,   access
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   deactivatePlayer(maria.Player)
    ,   maria.transaction.commit()
    ,   (req, res) ->
            res.json 200

    app.delete '/:playerId(\\d+)'
    ,   access
    ,   maria(app.get 'db')
    ,   maria.transaction()
    ,   deletePlayer(maria.Player)
    ,   maria.transaction.commit()
    ,   (req, res) ->
            res.json 200





access= (req, res, next) ->
    err= null

    if do req.isUnauthenticated
        res.status 401
        err=
            message: 'user not authenticated'

    return next err



createPlayer= (Player) -> (req, res, next) ->
    console.log 'req', req.body
    newPlayer= new Player req.body
    Player.create newPlayer, req.maria, (err, player) ->
        req.player= player or null
        return next err

createPlayerBalance= (PlayerBalance) -> (req, res, next) ->
    PlayerBalance.create req.player.id, req.maria, (err) ->
        return next err



getPlayers= (Player) -> (req, res, next) ->
    Player.query req.maria, (err, players) ->
        req.players= players or null
        return next err



getPlayer= (Player) -> (req, res, next) ->
    Player.get req.params.playerId, req.maria, (err, player) ->
        req.player= player or null
        return next err

getPlayerBalance= (PlayerBalance) -> (req, res, next) ->
    PlayerBalance.get req.params.playerId, req.maria, (err, balance) ->
        req.player.balance= balance or null
        return next err



updatePlayer= (Player) -> (req, res, next) ->
    newPlayer= new Player req.body
    Player.update req.params.playerId, newPlayer, req.maria, (err, player) ->
        req.player= player or null
        return next err



activatePlayer= (Player) -> (req, res, next) ->
    Player.activate req.params.playerId, req.maria, (err) ->
        return next err



deactivatePlayer= (Player) -> (req, res, next) ->
    Player.deactivate req.params.playerId, req.maria, (err) ->
        return next err



deletePlayer= (Player) -> (req, res, next) ->
    Player.delete req.params.playerId, req.maria, (err) ->
        return next err
