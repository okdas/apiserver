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


    # Игроки. Рассылка
    $routeProvider.when '/players/sender/mail',
        templateUrl: 'partials/players/sender/mail/', controller: 'PlayersSenderMailCtrl'

    $routeProvider.when '/players/sender/sms',
        templateUrl: 'partials/players/sender/sms/', controller: 'PlayersSenderSmsCtrl'


    # Игроки. Платежи
    $routeProvider.when '/players/payment/list',
        templateUrl: 'partials/players/payments/', controller: 'PlayersPaymentListCtrl'


    # Игроки. Группы
    #$routeProvider.when '/players/group/list',
    #    templateUrl: 'partials/players/group/list/', controller: 'PlayersGroupListCtrl'

    # Игроки. Разрешения
    #$routeProvider.when '/players/permission/list',
    #    templateUrl: 'partials/players/permission/list/', controller: 'PlayersPermissionListCtrl'






###

Ресурсы

###
# Список игроков
app.factory 'PlayerList', ($resource) ->
    $resource '/api/v1/players', {}



# Платежи
app.factory 'Payment', ($resource) ->
    $resource '/api/v1/players/payment/:paymentId', {},
        update:
            method: 'put'
            params:
                paymentId: '@id'



# Игрок
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



# Активация игрока
app.factory 'PlayerActivate', ($resource) ->
    $resource '/api/v1/players/player/activate/:playerId', {},
        activate:
            method: 'get'
            params:
                playerId: '@id'



# Деактивация игрока
app.factory 'PlayerDeactivate', ($resource) ->
    $resource '/api/v1/players/player/deactivate/:playerId', {},
        deactivate:
            method: 'get'
            params:
                playerId: '@id'



# Рассылка почты
app.factory 'PlayerSenderMail', ($resource) ->
    $resource '/api/v1/sender/mail', {},
        send:
            method: 'post'



# Рассылка смс
app.factory 'PlayerSenderSms', ($resource) ->
    $resource '/api/v1/sender/sms', {},
        send:
            method: 'post'





###

Контроллеры

###
# Контроллер панели управления.
app.controller 'PlayersDashboardCtrl', ($scope) ->
    $scope.state= 'loaded'



# Контроллер списка игроков.
app.controller 'PlayersPlayerListCtrl', ($rootScope, $scope, Player, PlayerActivate, PlayerDeactivate) ->
    load= ->
        $scope.players= Player.query ->
            $scope.state= 'loaded'
        , (res) ->
            $rootScope.error= res

    do load

    $scope.activate= (player) ->
        doActivatePlayer= new PlayerActivate player
        doActivatePlayer.$activate ->
            do load
        , (res) ->
            $rootScope.error= res

    $scope.deactivate= (player) ->
        doActivatePlayer= new PlayerDeactivate player
        doActivatePlayer.$deactivate ->
            do load
        , (res) ->
            $rootScope.error= res

    $scope.reload= ->
        do load



# Контроллер формы игрока.
app.controller 'PlayersPlayerFormCtrl', ($rootScope, $scope, $location, Player) ->
    if $route.current.params.playerId
        $scope.player= Player.get $route.current.params, ->
            $scope.state= 'loaded'
            $scope.action= 'update'
        , (res) ->
            $rootScope.error= res

    else
        $scope.player= new Player
        $scope.state= 'loaded'
        $scope.action= 'create'

    # Действия
    $scope.create= ->
        $scope.player.$create ->
            $location.path '/players/player/list'
        , (res) ->
            $rootScope.error= res

    $scope.update= ->
        $scope.player.$update ->
            $location.path '/players/player/list'
        , (res) ->
            $rootScope.error= res

    $scope.delete= ->
        $scope.player.$delete ->
            $location.path '/players/player/list'
        , (res) ->
            $rootScope.error= res



# Контроллер списка платежей.
app.controller 'PlayersPaymentListCtrl', ($rootScope, $scope, Payment) ->
    load= ->
        $scope.payments= Payment.query ->
            $scope.paymentStatuses= [
                'pending'
                'success'
                'failure'
            ]

            $scope.state= 'loaded'
        , (res) ->
            $rootScope.error= res

    do load

    # Дествие
    $scope.change= (payment) ->
        doChangePayment= new Payment payment
        doChangePayment.$update ->
            do load
        , (res) ->
            $rootScope.error= res

    $scope.reload= ->
        do load



# Контроллер рассылки на почту
app.controller 'PlayersSenderMailCtrl', ($rootScope, $scope, $location, Player, PlayerSenderMail) ->
    $scope.mail= new PlayerSenderMail


    load= ->
        $scope.players= Player.query ->
            $scope.state= 'loaded'
        , (res) ->
            $rootScope.error= res

    do load

    $scope.togglePlayer= (player) ->
        player.selected= !player.selected

    # Отправка
    $scope.send= ->
        $scope.mail.to= []
        $scope.players.map (val, i) ->
            if val.selected == true
                $scope.mail.to.push val.email

        $scope.mail.$send ->
            $location.path '/players/player/list'
        , (res) ->
            $rootScope.error= res

    $scope.reload= ->
        do load



# Контроллер рассылки смс
app.controller 'PlayersSenderSmsCtrl', ($rootScope, $scope, $location, Player, PlayerSenderSms) ->
    $scope.players= {}
    $scope.sms= new PlayerSenderSms

    load= ->
        $scope.players= Player.query ->
            $scope.state= 'loaded'
        , (res) ->
            $rootScope.error= res

    do load

    $scope.togglePlayer= (player) ->
        player.selected= !player.selected

    # Отправка
    $scope.send= ->
        $scope.sms.to= []
        $scope.players.map (val, i) ->
            if val.selected == true
                $scope.sms.to.push val.phone

        $scope.sms.$send ->
            $location.path '/players/player/list'
        , (res) ->
            $rootScope.error= res

    $scope.reload= ->
        do load
