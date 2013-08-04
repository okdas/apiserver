app= angular.module 'project.players'

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

