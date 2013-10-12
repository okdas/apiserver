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
app.factory 'Server', ($resource) ->
    $resource '/api/v1/servers/server/:serverId'


# Модель сервера.
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


# Модель инстанса.
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



# Cписок тегов
app.factory 'TagList', ($resource) ->
    $resource '/api/v1/tags'





###
Контроллеры
###
# Контроллер панели управления.
app.controller 'ServersDashboardCtrl', ($scope) ->
    $scope.state= 'loaded'



# Контроллер списка серверов.
app.controller 'ServersServerListCtrl', ($rootScope, $scope, Server) ->
    load= ->
        $scope.servers= Server.query ->
            $scope.state= 'loaded'
        , (res) ->
            $rootScope.error= res

    do load

    $scope.reload= ->
        do load



# Контроллер формы сервера.
app.controller 'ServersServerFormCtrl', ($rootScope, $scope, $location, Server, TagList) ->
    if $route.current.params.serverId
        $scope.server= Server.get $route.current.params, ->
            console.log 'serv', $scope.server

            #$scope.tags= TagList.query ->
            console.log 'tags', $scope.tags
            #$scope.state= 'loaded'
            $scope.action= 'update'
        , (res) ->
            $rootScope.error= res
    else
        $scope.tags= TagList.query ->
            $scope.server= new Server
            $scope.state= 'loaded'
            $scope.action= 'create'
        , (res) ->
            $rootScope.error= res

    $scope.filterTag= (tag) ->
        show= true
        if $scope.server.tags
            $scope.server.tags.map (t) ->
                if t.id == tag.id
                    show= false

        return show

    $scope.addTag= (tag) ->
        newTag= JSON.parse angular.copy tag
        $scope.server.tags= [] if not $scope.server.tags
        $scope.server.tags.push newTag


    $scope.removeTag= (tag) ->
        remPosition= null
        $scope.server.tags.map (tg, i) ->
            if tg.id == tag.id
                $scope.server.tags.splice i, 1

    # Действия
    $scope.create= ->
        $scope.server.$create ->
            $location.path '/servers/server/list'
        , (res) ->
            $rootScope.error= res

    $scope.update= ->
        $scope.server.$update ->
            $location.path '/servers/server/list'
        , (res) ->
            $rootScope.error= res

    $scope.delete= ->
        $scope.server.$delete ->
            $location.path '/servers/server/list'
        , (res) ->
            $rootScope.error= res



# Контроллер инстанса.
app.controller 'ServersInstanceListCtrl', ($rootScope, $scope, Instance) ->
    load= ->
        $scope.instances= Instance.query ->
            $scope.state= 'loaded'
        , (res) ->
            $rootScope.error= res

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



# Контроллер формы инстанса.
app.controller 'ServersInstanceFormCtrl', ($rootScope, $scope, $location, Instance, Serverq) ->
    Server = Serverq
    if $route.current.params.instanceId
        $scope.instance= Instance.get $route.current.params, ->
            $scope.state= 'loaded'
            $scope.action= 'update'
        , (res) ->
            $rootScope.error= res
    else
        $scope.instance= new Instance
        $scope.state= 'loaded'
        $scope.action= 'create'


    $scope.servers= Server.query ->
        null
    , (res) ->
            $rootScope.error= res



    # Действия
    $scope.create= ->
        $scope.instance.$create ->
            $location.path '/servers/instance/list'
        , (res) ->
            $rootScope.error= res

    $scope.update= ->
        $scope.instance.$update ->
            $location.path '/servers/instance/list'
        , (res) ->
            $rootScope.error= res

    $scope.delete= ->
        $scope.instance.$delete ->
            $location.path '/servers/instance/list'
        , (res) ->
            $rootScope.error= res
