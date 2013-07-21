async= require 'async'

module.exports= (db, done) ->

    async.series

        User: (done) ->
            User= require './User'
            User db, done

        Store: (done) ->
            Store= require './Store'
            Store db, done

        Storage: (done) ->
            Storage= require './Storage'
            Storage db, done

    do done
