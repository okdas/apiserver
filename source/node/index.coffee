express= require 'express'

###
Приложение
###
app= module.exports= do express

###
Конфигурация приложения. Инициализация прослоек
###
app.configure ->

    app.use do express.compress

    # Публичные файлы
    app.use express.static __dirname+'/views/assets'

    app.use do express.bodyParser

    app.use do express.cookieParser

    app.use do express.methodOverride

    # Шаблоны вида
    app.set 'views', __dirname + '/views/templates'
    app.set 'view engine', 'jade'