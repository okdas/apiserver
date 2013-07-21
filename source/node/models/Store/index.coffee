module.exports= (db, done) ->


    ###
    Игрок.
    ###
    Player= db.define 'Player',

        name:
            required: true
            type: 'text'
            size: 50


    ###
    Сервер.
    ###
    Server= db.define 'Server',

        name:
            required: true
            type: 'text'
            size: 50

        title:
            required: true
            type: 'text'
            size: 255


    ###
    Предмет в магазине.
    ###
    Item= db.define 'Item',

        title:
            required: true
            type: 'text'
            size: 255


    ###
    Пакет в магазине.
    ###
    Package= db.define 'Package',

        title:
            required: true
            type: 'text'
            size: 255


    ###
    Пакет имеет множество предметов.
    ###
    Package.hasMany 'items', Item,
        amount:
            required: true
            type: 'number'
            unsigned: true
            rational: false

    ###
    Пакет имеет множество серверов.
    ###
    Package.hasMany 'servers', Server


    do done
