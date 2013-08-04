### Приложение ###
app= angular.module 'project.servers', ['ngResource']



#=============Маршруты=============
app.config ($routeProvider) ->
    # Серверы

    $routeProvider.when '/servers',
        templateUrl: 'project/servers/', controller: 'ServersDashboardCtrl'

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





#=============Ресурсы==============
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





#=============Контроллеры==========
app.controller 'ServersDashboardCtrl', ($scope, $q) ->
    $scope.state= 'loaded'



app.controller 'ServersServerListCtrl', ($scope, Server) ->
    $scope.server= {}
    $scope.state= 'load'


    load= ->
        $scope.servers= Server.query ->
            $scope.state= 'loaded'
            console.log 'Сервера загружены'

    do load


    $scope.showDetails= (server) ->
        $scope.dialog.server= server
        $scope.dialog.templateUrl= 'server/dialog/'
        $scope.showDialog true


    $scope.hideDetails= ->
        $scope.dialog.server= null
        do $scope.hideDialog


    $scope.reload= ->
        do load



app.controller 'ServersServerFormCtrl', ($scope, $route, $location, Server) ->
    $scope.errors= {}

    if $route.current.params.serverId
        $scope.server= Server.get $route.current.params, ->
            console.log arguments
    else
        $scope.server= new Server


    # Действия
    $scope.create= (ServerForm) ->
        $scope.server.$create ->
            $location.path '/servers/server/list'
        ,   (err) ->
                $scope.errors= err.data.errors
                if 400 == err.status
                    angular.forEach err.data.errors, (error, input) ->
                        ServerForm[input].$setValidity error.error, false


    $scope.update= (ServerForm) ->
        $scope.server.$update ->
            $location.path '/servers/server/list'
        , (err) ->
                $scope.errors= err.data.errors
                if 400 == err.status
                    angular.forEach err.data.errors, (error, input) ->
                        ServerForm[input].$setValidity error.error, false


    $scope.delete= ->
        $scope.server.$delete ->
            $location.path '/servers/server/list'



### Инстансы ###
app.controller 'ServersInstanceListCtrl', ($scope, Instance) ->
    $scope.instance= {}
    $scope.state= 'load'


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



app.controller 'ServersInstanceFormCtrl', ($scope, $route, $location, Instance, Server) ->
    $scope.errors= {}

    if $route.current.params.instanceId
        $scope.instance= Instance.get $route.current.params, ->
            console.log arguments
    else
        $scope.instance= new Instance


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

