module.exports= (db, done) ->


    ###
    Группа пользователей.
    ###
    Group= db.define 'Group',

        name:
            required: true
            type: 'text'
            size: 50


    ###
    Пользователь.
    ###
    User= db.define 'User',

        name:
            required: true
            type: 'text'
            size: 50

        pass:
            required: true
            type: 'text'
            size: 64

        group:
            type: 'text'
            size: 50


    ###
    Роль.
    ###
    Role= db.define 'Role',

        name:
            required: true
            type: 'text'
            size: 50


    # Группа имеет несколько пользователей.
    Group.hasMany 'users', User

    # Группа имеет несколько ролей.
    Group.hasMany 'roles', Role


    do done
