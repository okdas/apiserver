module.exports= (app) ->
    Index= require './Index/'
    Car= require './Car/'
    User= require './User/'
    Auth= require './Auth/'

    app.get '/', Index.index

    app.namespace '/user', ->
        app.get '/register', User.register
        app.get '/change/:id', User.change
        app.get '/delete/:id', User.delete

        app.get '/login', Auth.login app.get('passport')
        app.get '/callback', Auth.callback app.get('passport'),(req, res) -> res.send 'WOOW'



    app.namespace '/car', ->
        app.get '/', Car.all
        app.get '/add', Car.add
        app.get '/:id', Car.one
        app.get '/change/:id', Car.change
        app.get '/delete/:id', Car.delete


