app= angular.module 'project.players', ['ngResource'], ($routeProvider) ->

    # Игроки

    $routeProvider.when '/players',
        templateUrl: 'partials/players/', controller: 'PlayersDashboardCtrl'

    $routeProvider.when '/players/player/list',
        templateUrl: 'partials/players/players/', controller: 'PlayersPlayerListCtrl'

    $routeProvider.when '/players/player/:playerId',
        templateUrl: 'partials/players/players/player/', controller: 'PlayersPlayerCtrl'

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
    $resource '/api/v1/players/player/:playerId', {playerId:'@id'}


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
app.controller 'PlayersPlayerListCtrl', ($scope, PlayerList) ->
    $scope.players= {}
    $scope.state= 'load'

    load= ->
        $scope.players= PlayerList.query ->
            $scope.state= 'loaded'
            console.log 'Пользователи загружены'

    do load

    $scope.showDetails= (player) ->
        $scope.dialog.player= player
        $scope.dialog.templateUrl= 'player/dialog/'
        $scope.showDialog true

    $scope.hideDetails= ->
        $scope.dialog.player= null
        do $scope.hideDialog

    $scope.reload= ->
        do load



app.controller 'PlayersSenderMailCtrl', ($scope, $location, PlayerList, PlayerSenderMail) ->
    $scope.players= {}
    $scope.state= 'load'
    $scope.mail= new PlayerSenderMail


    load= ->
        $scope.players= PlayerList.query ->
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



app.controller 'PlayersSenderSmsCtrl', ($scope, $location, PlayerList, PlayerSenderSms) ->
    $scope.players= {}
    $scope.state= 'load'
    $scope.sms= new PlayerSenderSms


    load= ->
        $scope.players= PlayerList.query ->
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
