app= angular.module 'project.servers'

app.factory 'Instance', ($resource) ->
    $resource '/api/v1/instances/:instanceId', {},
        create:
            method: 'post'

        update:
            method: 'put'
            params:
                instanceId: '@id'

        delete:
            method: 'delete'
            params:
                instanceId: '@id'


