app= angular.module 'project.servers'

app.factory 'Server', ($resource) ->
    $resource '/api/v1/servers/:serverId', {},
        create:
            method: 'post'

        update:
            method: 'put'
            params:
                serverId: '@id'

        delete:
            method: 'delete'
            params:
                serverId: '@id'

