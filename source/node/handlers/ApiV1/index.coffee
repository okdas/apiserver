async= require 'async'



###
Отдает список предметов магазина.
###
exports.listItems= (req, res, next) ->
    # загрузить предметы из базы данных
    req.models.Item.find (err, items) ->
        return next err if err
        return res.json 200, items


###
Добавляет переданный предмет в магазин.
###
exports.addItem= (req, res, next) ->
    item:
        title: req.body.title

    # сохранить новый предмет в базе данных
    item= new req.models.Item item
    item.save (err) ->
        return next err if err
        return res.json 201, item


###
Изменяет указанный предмет в магазине.
###
exports.changeItem= (req, res, next) ->
    id= req.param 'itemId'

    # загрузить предмет из базы данных
    req.models.Item.get id, (err, item) ->
        return next err if err

        # применить изменения
        if req.body.title
            item.title= req.body.title

        # сохранить предмет в базе данных
        item.save (err) ->
            return next err if err
            return res.json 201, item


###
Удаляет указанный предмет из магазина.
###
exports.deleteItem= (req, res, next) ->
    id= req.param 'itemId'

    # загрузить предмет из базы данных
    req.models.Item.get id, (err, item) ->
        return next err if err

        item.remove (err) ->
            return next err if err
            return res.json 200, item



###
Отдает список пакетов магазина.
###
exports.listPackages= (req, res, next) ->
    # загрузить предметы из базы данных
    req.models.Package.find (err, pkgs) ->
        async.map pkgs
        ,   (pkg, done) ->

                async.parallel

                    items: (done) ->
                        pkg.getItems (err, items) ->
                            return done err, items

                    servers: (done) ->
                        pkg.getServers (err, servers) ->
                            return done err, servers

                ,   (err, result) ->
                        pkg.items= result.items
                        pkg.servers= result.servers
                        return done err, pkg

        ,   (err, pkgs) ->
                return next err if err
                return res.json 200, pkgs
