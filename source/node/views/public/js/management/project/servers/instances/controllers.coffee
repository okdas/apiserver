app= angular.module 'project.servers'



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


    $scope.reloadInstances= ->
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

