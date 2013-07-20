async= require 'async'


###

Методы API для работы c группами пользователей

###


###
Отдает список групп.
###
exports.listGroups= (req, res, next) ->
    req.models.Group.find (err, groups) ->
        async.map groups
        ,   (group, done) ->

                async.parallel

                    roles: (done) ->
                        group.getRoles (err, roles) ->
                            return done err, roles

                    users: (done) ->
                        group.getUsers (err, users) ->
                            return done err, users

                ,   (err, result) ->
                        group.roles= result.roles
                        group.users= result.users
                        return done err, group

        ,   (err, groups) ->
                return next err if err
                return res.json 200, groups






###
Добавляет переданную группу в список.
###
exports.addGroup= (req, res, next) ->
    group= req.body

    # сохранить новый предмет в базе данных
    newGroup= new req.models.Group group
    newGroup.save (err) ->
        return next err if err
        return res.json 201, newGroup








###
Отдает указанную группу.
###
exports.getGroup= (req, res, next) ->
    id = req.params.groupId

    req.models.Group.get id, (err, group) ->
        async.parallel
            roles: (done) ->
                group.getRoles (err, roles) ->
                    return done err, roles

            users: (done) ->
                group.getUsers (err, users) ->
                    return done err, users

        ,   (err, result) ->
                group.roles= result.roles
                group.users= result.users
                return next err if err
                return res.json 200, group



        




###

Методы API для работы c пользователями

###


###
Отдает список пользователей.
###
exports.listUsers= (req, res, next) ->
    req.models.User.find (err, users) ->
        async.map users
        ,   (user, done) ->

                user.getGroups (err, groups) ->
                    user.groups= groups
                    return done err, user

        ,   (err, users) ->
                return next err if err
                return res.json 200, users




###
Добавляет переданного пользователя в список.
###
exports.addUser= (req, res, next) ->
    user= req.body

    newUser= new req.models.User user
    newUser.save (err) ->
        return next err if err
        return res.json 201, newUser





###
Отдает указанного пользователя.
###
exports.getUser= (req, res, next) ->
    id = req.params.userId

    req.models.User.get id, (err, user) ->
        return next err if err
        return res.json 200, user





###
Отдает список групп указанного пользователя.
###
exports.getUserGroups= (req, res, next) ->
    id = req.params.userId

    async.waterfall [
        (callback) ->
            req.models.User.get id, (err, user) ->
                callback err, user

    ,   (user, callback) ->
            user.getGroups (err, groups) ->
                callback err, groups
    ]

    ,   (err, result) ->
        return next err if err
        return res.json 200, result








###
Добавляет указанному пользователю переданную группу.
###
exports.addUserGroup= (req, res, next) ->
    res.send 200


