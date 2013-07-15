config=require 'config.json'
ns= require 'express-namespace'
http= require 'http'
fs= require 'fs'
App= module.exports= require 'express'
app= App()
passport = require('./api/Auth/').config()



require('./modules/log/')()
app.use (req,res,next) ->
    logger.info req.ip + ' - - ' + req.method + ' ' + req.url + ' - - "' + req.headers.referer + '"  "' + req.headers['user-agent'] + '"'
    next()

require('./modules/pid/')(config.pid)




#
# Конфигурация для работы в штатном режиме
#
app.configure ->
    app.use App.compress()

    # статические файлы
    app.use App.static __dirname+'/views/assets'


    # шаблоны вида
    app.set 'views', __dirname + '/views/pages'
    app.set 'view engine', 'jade'
    app.set 'view options',
        layout:false

    # обработка входящих данных
    app.use App.bodyParser()
    app.use App.cookieParser()
    app.use App.methodOverride()

    app.use App.session
        secret: config.auth.session.secret

    app.locals.title= 'APIserver'

    # passport
    app.use passport.initialize()
    app.use passport.session()
    app.set 'passport', passport



#
# Конфигурация для разработки и тестирования
#
app.configure 'development', ->

    app.use App.logger 'tiny'

    app.use App.errorHandler
        dumpExceptions: true
        showStack     : true


#
# Сервер приложения
#
port= config.port

server = http.createServer(app)
server.listen port, ->
    logger.info 'Listening on '+port




# Эйпиай
api= require './api'
api app

