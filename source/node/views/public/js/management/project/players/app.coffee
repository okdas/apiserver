### Приложение ###
app= angular.module 'project.players', ['ngResource']



app.config ($routeProvider) ->
    # Игроки

    $routeProvider.when '/players',
        templateUrl: 'project/players/', controller: 'PlayersDashboardCtrl'



    $routeProvider.when '/players/player/list',
        templateUrl: 'project/players/players/', controller: 'PlayersPlayerListCtrl'

    $routeProvider.when '/players/player/:playerId',
        templateUrl: 'project/players/players/player/', controller: 'PlayersPlayerCtrl'



    $routeProvider.when '/players/group/list',
        templateUrl: 'project/players/group/list/', controller: 'PlayersGroupListCtrl'




    $routeProvider.when '/players/permission/list',
        templateUrl: 'project/players/permission/list/', controller: 'PlayersPermissionListCtrl'




app.factory 'PlayerList', ($resource) ->
    $resource '/api/v1/players', {}

app.factory 'Player', ($resource) ->
    $resource '/api/v1/players/player/:playerId', {playerId:'@id'}

app.factory 'PlayerGroupList', ($resource) ->
    $resource '/api/v1/players/groups', {}






app.controller 'PlayersDashboardCtrl', ($scope) ->
    $scope.state= 'loaded'


app.controller 'PlayersPlayerListCtrl', ($scope, PlayerList) ->
    $scope.players= {}
    $scope.state= 'load'


    load= ->
        $scope.players= PlayerList.query () ->
            $scope.state= 'loaded'
            console.log 'Пользователи загружены'

    do load


    $scope.showDetails= (player) ->
        $scope.dialog.player= player
        $scope.dialog.templateUrl= 'player/dialog/'
        $scope.showDialog true


    $scope.hideDetails= () ->
        $scope.dialog.player= null
        do $scope.hideDialog


    $scope.reload= ->
        do load
