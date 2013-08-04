app= angular.module 'project.store'

app.factory 'Item', ($resource) ->
    $resource '/api/v1/store/items/:itemId',
        itemId:'@id'
    ,
        create:
            method:'post'

        update:
            method:'put'
            params:
                itemId:'@id'

        delete:
            method:'delete'
            params:
                itemId:'@id'

