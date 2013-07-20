module.exports= (db, done) ->


    ###
    Пользователь.
    ###
    User= db.define 'User',

        username:
            required: true
            type: 'text'
            size: 50

        password:
            required: true
            type: 'text'
            size: 64

        group:
            type: 'text'
            size: 50


    ###
    Роль пользователя.
    ###
    Role= db.define 'Role',

        name:
            required: true
            type: 'text'
            size: 50


    # Пользователь имеет множество ролей.
    User.hasMany 'roles', Role


    do done