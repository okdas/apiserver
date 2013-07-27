express= require 'express'



###
Методы API для аутентифицированного пользователя
###
app= module.exports= do express



###
Отдает список пользователей.
###
app.get '/', (req, res, next) ->
    User= req.resources.Users.User
    User.query req.query, (err, users) ->
        return next err if err and not (err instanceof User.query.Error)
        return res.json 200, users



###
Добавляет пользователя в список.
###
app.post '/', (req, res, next) ->
    User= req.resources.Users.User
    User.create req.body, (err, user) ->
        return next err if err and not (err instanceof User.create.Error)
        return res.json 400, err if (err instanceof User.create.ValidateError)
        return res.json 201, user



###
Отдает пользователя.
###
app.get '/user/:userId', (req, res, next) ->
    User= req.resources.Users.User
    User.find (req.param 'userId'), (err, user) ->
        return next err if err and not (err instanceof User.find.Error)
        return res.json 404, err if not user
        return res.json 200, user



###
Обновляет пользователя.
###
app.patch '/user/:userId', (req, res, next) ->
    User= req.resources.Users.User
    User.update (req.param 'userId'), req.body, (err, user) ->
        return next err if err and not (err instanceof User.update.Error)
        return res.json 400, err if (err instanceof User.update.ValidateError)
        return res.json 404, err if (err instanceof User.update.NotFoundError)
        return res.json 200, user



###
Удаляет пользователя.
###
app.delete '/user/:userId', (req, res, next) ->
    User= req.resources.Users.User
    User.delete (req.param 'userId'), (err, user) ->
        return next err if err and not (err instanceof req.resources.Users.User.delete.Error)
        return res.json 404, err if (err instanceof User.delete.NotFoundError)
        return res.json 200, user
