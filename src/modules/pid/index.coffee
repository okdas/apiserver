module.exports= (path) ->
    fs= require 'fs'

    # События процесса
    events= [
        'SIGHUP', 'SIGINT', 'SIGQUIT', 'SIGILL', 'SIGTRAP', 'SIGABRT', 'SIGBUS',
        'SIGFPE', 'SIGUSR1', 'SIGSEGV', 'SIGUSR2', 'SIGPIPE', 'SIGTERM'
    ]

    onkill= (sig) ->
        try
            fs.unlink path, (err) ->
                if err
                    logger.critical err.toString()
                    
                if typeof sig == 'string'
                    logger.info 'Received - terminating Node server ... ' + sig
                    process.exit 1
            logger.info 'Node server stopped.'

    # Пишем pid в файл
    fs.writeFile path, process.pid.toString()+'\n', (err) ->
        if err
            logger.error 'Error create PID'
        else
            logger.info 'PID: '+process.pid.toString()

    process.on 'exit', ->
        onkill()

    events.forEach (element) ->
        process.on element, ->
            onkill element
