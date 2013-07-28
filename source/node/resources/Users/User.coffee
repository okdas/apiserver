Model= require 'resource/Model'

crypto= require 'crypto'
sha1= (string) ->
    hash= crypto.createHash 'sha1'
    hash.update string
    return hash.digest 'hex'

###
Модель пользователя
###
module.exports= class UserModel extends Model


    @properties:

        username:
            type: String
            required: true

        password:
            type: String
            required: true
            validate: (value) ->
                return sha1 value

        createdAt:
            type: Date

        updatedAt:
            type: Date

        deletedAt:
            type: Date



    @identity: 'id'



    @indexies:

        username:
            unique: true