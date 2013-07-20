###

Методы API для работы c группами пользователей

###


###
Отдает список групп.
###
exports.listGroups= (req, res, next) ->
    req.models.Group.find (err, groups) ->
        async.map groups
            , (group, done) ->

                async.parallel

                    roles: (done) ->
                        group.getRoles (err, roles) ->
                            return done err, roles

                    users: (done) ->
                        group.getUsers (err, users) ->
                            return done err, users

                , (err, result) ->
                    groups.roles= result.roles
                    groups.users= result.users
                    return done err, group

            , (err, groups) ->
                return next err if err
                return res.json 200, groups









###
Добавляет переданную группу в список.
###
exports.addGroup= (req, res, next) ->
#    item:
#        title: req.body.title

    # сохранить новый предмет в базе данных
#    item= new req.models.Group group
#    item.save (err) ->
#        if err
            # ошибка при сохранении предмета
#            return next err

        return res.json 201, item






###
Отдает указанную группу.
###
exports.getGroup= (req, res, next) ->
    res.send 200



###

Методы API для работы c пользователями

###


###
Отдает список пользователей.
###
exports.listUsers= (req, res, next) ->
    req.models.User.find (err, users) ->
        async.map users
            , (user, done) ->

                user.getGroups (err, groups) ->
                    user.groups= groups
                    return done err, user

            , (err, users) ->
                return next err if err
                return res.json 200, users




###
Добавляет переданного пользователя в список.
###
exports.addUser= (req, res, next) ->
    res.send 200




###
Отдает указанного пользователя.
###
exports.getUser= (req, res, next) ->
    res.send 200




###
Отдает список групп указанного пользователя.
###
exports.getGroupsOfUser= (req, res, next) ->
    res.send 200




###
Добавляет указанному пользователю переданную группу.
###
exports.addGroupOfUser= (req, res, next) ->
    res.send 200


