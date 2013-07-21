module.exports= (db, done) ->

    StorageItem= db.define 'StorageItem'


    StorageItem.hasOne 'player', db.models.Player

    StorageItem.hasOne 'server', db.models.Server


    do done
