async= require 'async'

module.exports= (db, done) ->

    async.parallel

        User: (done) ->
            User= require './User'
            User db, done

        Store: (done) ->
            Store= require './Store'
            Store db, done

    do done