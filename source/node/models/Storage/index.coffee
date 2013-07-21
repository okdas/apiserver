module.exports= (db, done) ->

    ###
    Предмет на складе.
    ###
    StorageItem= db.define 'StorageItem',

        amount:
            type: 'number'
            required: true
            unsigned: true
            rational: false


    ###
    Предмет на складе принадлежит игроку.
    ###
    StorageItem.hasOne 'player', db.models.Player

    ###
    Предмет на складе принадлежит серверу.
    ###
    StorageItem.hasOne 'server', db.models.Server

    ###
    Предмет на складе ссылается на предмет в магазине.
    ###
    StorageItem.hasOne 'item', db.models.Item


    do done
