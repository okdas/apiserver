module.exports= ->
    Log= require 'log'

    logger= new Log 'debug'
    global.logger= logger

    logger.info 'Logger was started'
    
