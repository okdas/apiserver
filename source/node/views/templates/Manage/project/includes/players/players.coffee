app= angular.module 'project.players', ['ngResource','ngRoute'], ($routeProvider) ->

    # Игроки

    $routeProvider.when '/players',
        templateUrl: 'partials/players/', controller: 'PlayersDashboardCtrl'



    $routeProvider.when '/players/player/list',
        templateUrl: 'partials/players/players/', controller: 'PlayersPlayerListCtrl'

    $routeProvider.when '/players/player/create',
        templateUrl: 'partials/players/players/player/form/', controller: 'PlayersPlayerFormCtrl'

    $routeProvider.when '/players/player/update/:playerId',
        templateUrl: 'partials/players/players/player/form/', controller: 'PlayersPlayerFormCtrl'

    # Игроки. Группы

    $routeProvider.when '/players/group/list',
        templateUrl: 'partials/players/group/list/', controller: 'PlayersGroupListCtrl'

    # Игроки. Разрешения

    $routeProvider.when '/players/permission/list',
        templateUrl: 'partials/players/permission/list/', controller: 'PlayersPermissionListCtrl'

    # Игроки. Рассылка

    $routeProvider.when '/players/sender/mail',
        templateUrl: 'partials/players/sender/mail/', controller: 'PlayersSenderMailCtrl'

    $routeProvider.when '/players/sender/sms',
        templateUrl: 'partials/players/sender/sms/', controller: 'PlayersSenderSmsCtrl'



###

Ресурсы

###


app.factory 'PlayerList', ($resource) ->
    $resource '/api/v1/players', {}



app.factory 'Player', ($resource) ->
    $resource '/api/v1/players/player/:playerId', {},
        create:
            method: 'post'

        update:
            method: 'put'
            params:
                playerId: '@id'

        delete:
            method: 'delete'
            params:
                playerId: '@id'



app.factory 'PlayerGroupList', ($resource) ->
    $resource '/api/v1/players/groups', {}



app.factory 'PlayerSenderMail', ($resource) ->
    $resource '/api/v1/sender/mail', {},
        send:
            method: 'post'



app.factory 'PlayerSenderSms', ($resource) ->
    $resource '/api/v1/sender/sms', {},
        send:
            method: 'post'





###

Контроллеры

###


###
Контроллер панели управления.
###
app.controller 'PlayersDashboardCtrl', ($scope) ->
    $scope.state= 'loaded'


###
Контроллер списка игроков.
###
app.controller 'PlayersPlayerListCtrl', ($scope, Player) ->
    load= ->
        $scope.players= Player.query ->
            $scope.state= 'loaded'
            console.log 'Пользователи загружены'

    do load

    $scope.reload= ->
        do load




###
Контроллер формы чара.
###
app.controller 'PlayersPlayerFormCtrl', ($scope, $route, $q, $location, Player) ->
    if $route.current.params.playerId
        $scope.player= Player.get $route.current.params, ->
            $scope.state= 'loaded'
            $scope.action= 'update'
    else
        $scope.player= new Player
        $scope.state= 'loaded'
        $scope.action= 'create'

    # Действия

    $scope.create= (PlayerForm) ->
        $scope.player.$create ->
            $location.path '/players/player/list', (err) ->
                $scope.errors= err.data.errors
                if 400 == err.status
                    angular.forEach err.data.errors, (error, input) ->
                        PlayerForm[input].$setValidity error.error, false

    $scope.update= (PlayerForm) ->
        $scope.player.$update ->
            $location.path '/players/player/list', (err) ->
                $scope.errors= err.data.errors
                if 400 == err.status
                    angular.forEach err.data.errors, (error, input) ->
                        PlayerForm[input].$setValidity error.error, false

    $scope.delete= ->
        $scope.player.$delete ->
            $location.path '/players/player/list'



app.controller 'PlayersSenderMailCtrl', ($scope, $location, Player, PlayerSenderMail) ->
    $scope.mail= new PlayerSenderMail


    load= ->
        $scope.players= Player.query ->
            $scope.state= 'loaded'
            console.log 'Пользователи загружены'

    do load


    $scope.togglePlayer= (player) ->
        player.selected= !player.selected


    $scope.send= (MailForm) ->
        $scope.mail.to= []
        $scope.players.map (val, i) ->
            if val.selected == true
                $scope.mail.to.push val.email

        $scope.mail.$send ->
            $location.path '/players/player/list', (err) ->
                $scope.errors= err.data.errors
                if 400 == err.status
                    angular.forEach err.data.errors, (error, input) ->
                        MailForm[input].$setValidity error.error, false


    $scope.reload= ->
        do load



app.controller 'PlayersSenderSmsCtrl', ($scope, $location, Player, PlayerSenderSms) ->
    $scope.players= {}
    $scope.state= 'load'
    $scope.sms= new PlayerSenderSms


    load= ->
        $scope.players= Player.query ->
            $scope.state= 'loaded'
            console.log 'Пользователи загружены'

    do load


    $scope.togglePlayer= (player) ->
        player.selected= !player.selected


    $scope.send= (SmsForm) ->
        $scope.sms.to= []
        $scope.players.map (val, i) ->
            if val.selected == true
                $scope.sms.to.push val.phone

        $scope.sms.$send ->
            $location.path '/players/player/list', (err) ->
                $scope.errors= err.data.errors
                if 400 == err.status
                    angular.forEach err.data.errors, (error, input) ->
                        SmsForm[input].$setValidity error.error, false


    $scope.reload= ->
        do load
