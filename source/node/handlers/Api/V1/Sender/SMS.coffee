express= require 'express'



###
Методы API для рассылки SMS
###
app= module.exports= do express



###
Отсылает сообщение на кучу номеров
###
app.get '/', (req, res, next) ->
    res.send 200

