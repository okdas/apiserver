# создаем и возвращаем приложение из объявленных ранее модулей
app= angular.module 'manage'
,   ['project.servers', 'project.players', 'project.content', 'project.store', 'ngResource', 'ngRoute']
,   ($routeProvider) ->

        $routeProvider.otherwise
            redirectTo: '/'


app.controller 'AppCtrl', ($rootScope, $scope, $location, $http, $window) ->
    $rootScope.error= ''

    $rootScope.hideError= ->
        $rootScope.error= null
