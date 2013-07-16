express= require 'express'

app= module.exports= do express

app.get '/servers', (req, res) ->
    Server= (app.get 'domain').Server
    Server.query (err, servers) ->
        res.json servers