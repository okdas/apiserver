app= angular.module 'project.servers'

app.config ($routeProvider) ->
    # Серверы

    $routeProvider.when '/servers',
        templateUrl: 'project/servers/', controller: 'ServersViewCtrl'

    $routeProvider.when '/servers/server/list',
        templateUrl: 'project/servers/servers/', controller: 'ServersServerListCtrl'

    $routeProvider.when '/servers/server/create',
        templateUrl: 'project/servers/servers/server/forms/create', controller: 'ServersServerFormCtrl'

    $routeProvider.when '/servers/server/update/:serverId',
        templateUrl: 'project/servers/servers/server/forms/update', controller: 'ServersServerFormCtrl'





    # Серверы. Инстансы

    $routeProvider.when '/servers/instance/list',
        templateUrl: 'project/servers/instances/', controller: 'ServersInstanceListCtrl'

    $routeProvider.when '/servers/instance/create',
        templateUrl: 'project/servers/instances/instance/forms/create', controller: 'ServersInstanceFormCtrl'

    $routeProvider.when '/servers/instance/update/:instanceId',
        templateUrl: 'project/servers/instances/instance/forms/update', controller: 'ServersInstanceFormCtrl'

