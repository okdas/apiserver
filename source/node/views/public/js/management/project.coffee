###

Игроки.

###

app.factory 'PlayerList', ($resource) ->
    $resource '/api/v1/players', {}

app.factory 'Player', ($resource) ->
    $resource '/api/v1/players/player/:playerId', {playerId:'@id'}

app.factory 'PlayerGroupList', ($resource) ->
    $resource '/api/v1/players/groups', {}

app.service 'loadPlayers', ($q, PlayerList, PlayerGroupList) ->
    d= do $q.defer
    return d.promise

app.controller 'PlayersDashboardCtrl', ($scope, PlayerList) ->
    $scope.state= 'loaded'

app.controller 'PlayersPlayerListCtrl', ($scope, PlayerList) ->
    $scope.state= 'load'

    $scope.players= PlayerList.query () ->
        $scope.state= 'loaded'
        console.log 'Пользователи загружены'

    $scope.showDetails= (player) ->
        $scope.dialog.player= player
        $scope.dialog.templateUrl= 'player/dialog/'
        $scope.showDialog true

    $scope.hideDetails= () ->
        $scope.dialog.player= null
        do $scope.hideDialog

app.controller 'PlayerCtrl', ($scope, $q, Player) ->

app.controller 'PlayersGroupListCtrl', ($scope) ->
    $scope.state= 'loaded'

app.controller 'PlayersPermissionListCtrl', ($scope) ->
    $scope.state= 'loaded'






