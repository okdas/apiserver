PlayerResource= require './Player'
ServerResource= require './Server'

module.exports= (db) ->

    # Игрок
    Player: new PlayerResource db

    # Сервер
    Server: new ServerResource db