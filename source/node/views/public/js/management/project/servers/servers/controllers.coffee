app= angular.module 'project.servers'



app.controller 'ServersViewCtrl', ($scope, $q) ->
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


    $scope.reloadServers= ->
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

