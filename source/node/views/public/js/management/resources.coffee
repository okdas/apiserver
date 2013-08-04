app= angular.module 'management'



app.factory 'CurrentUser', ($resource) ->
    $resource '/api/v1/user/:action', {},
        logout:
            method:'post'
            params:
                action:'logout'

