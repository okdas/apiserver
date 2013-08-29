app= angular.module 'project.servers', ['ngResource','ngRoute'], ($routeProvider) ->

    # Серверы

    $routeProvider.when '/servers',
        templateUrl: 'partials/servers/', controller: 'ServersDashboardCtrl'

    $routeProvider.when '/servers/server/list',
        templateUrl: 'partials/servers/servers/', controller: 'ServersServerListCtrl'

    $routeProvider.when '/servers/server/create',
        templateUrl: 'partials/servers/servers/server/form/', controller: 'ServersServerFormCtrl'

    $routeProvider.when '/servers/server/update/:serverId',
        templateUrl: 'partials/servers/servers/server/form/', controller: 'ServersServerFormCtrl'

    # Серверы. Инстансы

    $routeProvider.when '/servers/instance/list',
        templateUrl: 'partials/servers/instances/', controller: 'ServersInstanceListCtrl'

    $routeProvider.when '/servers/instance/create',
        templateUrl: 'partials/servers/instances/instance/form/', controller: 'ServersInstanceFormCtrl'

    $routeProvider.when '/servers/instance/update/:instanceId',
        templateUrl: 'partials/servers/instances/instance/form/', controller: 'ServersInstanceFormCtrl'





###

Ресурсы

###


###
Модель сервера.
###
app.factory 'Server', ($resource) ->
    $resource '/api/v1/servers/server/:serverId', {},
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


###
Модель инстанса.
###
app.factory 'Instance', ($resource) ->
    $resource '/api/v1/servers/instance/:instanceId', {},
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





###

Контроллеры

###


###
Контроллер панели управления.
###
app.controller 'ServersDashboardCtrl', ($scope, $q) ->
    console.log 'ffffffffffffffffffff'
    $scope.state= 'loaded'


###
Контроллер списка серверов.
###
app.controller 'ServersServerListCtrl', ($scope, Server) ->
    load= ->
        $scope.servers= Server.query ->
            $scope.state= 'loaded'
            console.log 'Сервера загружены'

    do load

    $scope.reload= ->
        do load


###
Контроллер формы сервера.
###
app.controller 'ServersServerFormCtrl', ($scope, $route, $location, Server) ->
    if $route.current.params.serverId
        console.log $route.current.params.serverId
        $scope.server= Server.get $route.current.params, ->
            $scope.state= 'loaded'
            $scope.action= 'update'

    else
        $scope.server= new Server
        $scope.state= 'loaded'
        $scope.action= 'create'

    # Действия

    $scope.create= (ServerForm) ->
        $scope.server.$create ->
            $location.path '/servers/server/list', (err) ->
                $scope.errors= err.data.errors
                if 400 == err.status
                    angular.forEach err.data.errors, (error, input) ->
                        ServerForm[input].$setValidity error.error, false

    $scope.update= (ServerForm) ->
        $scope.server.$update ->
            $location.path '/servers/server/list', (err) ->
                $scope.errors= err.data.errors
                if 400 == err.status
                    angular.forEach err.data.errors, (error, input) ->
                        ServerForm[input].$setValidity error.error, false

    $scope.delete= ->
        $scope.server.$delete ->
            $location.path '/servers/server/list'


###
Контроллер инстанса.
###
app.controller 'ServersInstanceListCtrl', ($scope, Instance) ->
    load= ->
        $scope.instances= Instance.query ->
            $scope.state= 'loaded'
            console.log 'Инстансы загружены'

    do load

    $scope.showDetails= (instance) ->
        $scope.dialog.instance= instance
        $scope.dialog.templateUrl= 'instance/dialog/'
        $scope.showDialog true

    $scope.hideDetails= ->
        $scope.dialog.instance= null
        do $scope.hideDialog

    $scope.reload= ->
        do load


###
Контроллер формы инстанса.
###
app.controller 'ServersInstanceFormCtrl', ($scope, $route, $location, Instance, Server) ->
    if $route.current.params.instanceId
        $scope.instance= Instance.get $route.current.params, ->
            $scope.state= 'loaded'
            $scope.action= 'update'
    else
        $scope.instance= new Instance
        $scope.state= 'loaded'
        $scope.action= 'create'

    $scope.servers= Server.query ->

    # Действия
    $scope.create= (InstanceForm) ->
        $scope.instance.$create ->
            $location.path '/servers/instance/list'
        ,   (err) ->
                $scope.errors= err.data.errors
                if 400 == err.status
                    angular.forEach err.data.errors, (error, input) ->
                        InstanceForm[input].$setValidity error.error, false

    $scope.update= (InstanceForm) ->
        $scope.instance.$update ->
            $location.path '/servers/instance/list'
        , (err) ->
                $scope.errors= err.data.errors
                if 400 == err.status
                    angular.forEach err.data.errors, (error, input) ->
                        InstanceForm[input].$setValidity error.error, false

    $scope.delete= ->
        $scope.instance.$delete ->
            $location.path '/servers/instance/list'
