app= angular.module 'project.store'


### Модель чар.
###
app.factory 'Enchantment', ($resource) ->
    $resource '/api/v1/store/enchantments/:enchantmentId',
        enchantmentId:'@id'
    ,
        create:
            method:'post'

        update:
            method:'patch'
            params:
                enchantmentId:'@id'

        delete:
            method:'delete'
            params:
                enchantmentId:'@id'

