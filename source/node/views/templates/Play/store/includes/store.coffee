app= angular.module 'play', ['ngAnimate', 'ngRoute', 'ngResource'], ($routeProvider) ->

    $routeProvider.when '/',
        templateUrl: 'partials/', controller: 'StoreCtrl', resolve:
            serverList: (StoreServer) ->
                serverList= do StoreServer.query
                serverList.$promise

    $routeProvider.when '/servers/:serverId',
        templateUrl: 'partials/servers/', controller: 'StoreServerCtrl'


app.factory 'StoreServer', ($resource) ->
    $resource '/api/v1/store/servers/:serverId', {serverId:'@id'},
        query: {method:'GET', isArray:true, cache:true}
        get: {method:'GET', cache:true, params:{serverId:'@id'}}

app.factory 'StoreServerOrder', ($resource) ->
    $resource '/api/v1/store/servers/:serverId/order/:orderId'
    ,
        serverId: '@serverId'
        orderId: '@orderId'
    ,
        create: {method:'post'}


app.controller 'ViewCtrl', ($scope, $rootScope, $location, $window, Player, StoreServer, $log) ->

    $rootScope.player= Player.get () ->

    $rootScope.logout= () ->
        $rootScope.player.$logout () ->
            $window.location.href= '/'


    $scope.dialog=
        overlay: null

    $scope.showDialog= () ->
        $scope.dialog.overlay= true

    $scope.hideDialog= () ->
        $scope.dialog.overlay= null


    $rootScope.store=
        servers: StoreServer.query ->
            $log.info 'список серверов получен'

    $rootScope.storage=
        servers: []



app.factory 'Player', ($resource) ->
    $resource '/api/v1/player/:action', {},
        login: {method:'post', params:{action:'login'}}
        logout: {method:'post', params:{action:'logout'}}


app.controller 'PlayerCtrl', ($scope, $route, Player) ->
    $scope.player= Player.get () ->
            $scope.state= 'ready'
    ,   (err) ->
            $scope.state= 'error'
            $scope.error=
                error: err
                title: 'Не удалось загрузить пользователя'


app.controller 'StoreCtrl', ($scope, serverList) ->
    $scope.state= 'ready'
    $scope.store=
        servers: serverList



app.controller 'StoreServerCtrl', ($scope, $rootScope, $routeParams, $q, StoreServer) ->
    $scope.state= null

    $scope.store.server= StoreServer.get $routeParams, ->

    promise= $q.all [
        $rootScope.player.$promise
        $scope.store.servers.$promise
        $scope.store.server.$promise
    ]
    promise.then (resources) ->
            $scope.state= 'ready'
            for server in $scope.store.servers
                if server.id == $scope.store.server.id
                    $scope.cart= server
                    $scope.cart.items= [] if not $scope.cart.items
    ,   (error) ->
            $scope.state= 'error'


app.controller 'StoreServerItemCtrl', ($scope, $rootScope) ->
    $scope.amount= 1

    $scope.buyItem= (item) =>
        return if not $scope.amount

        found= null
        for itm in $scope.cart.items
            if not found and itm.id == item.id
                found= itm

        if not found
            found= angular.copy item
            found.amount= 0
            $scope.cart.items.push found

        amount= (found.amount|0) + ($scope.amount|0)
        found.amount= if amount > 99999 then 99999 else amount
        #$scope.amount= 1



app.controller 'StoreServerCartCtrl', ($scope, $rootScope, StoreServerOrder) ->
    $scope.cart.total= 0

    $scope.$watchCollection 'cart.items', (items) ->
        $scope.cart.total= 0
        angular.forEach items, (item) ->
            $scope.updateTotal item.price * item.amount

    $scope.updateTotal= (value) =>
        $scope.cart.total= Math.round(($scope.cart.total + value) * 100) / 100

    $scope.order= (cart) ->
        console.log 'купить', cart
        StoreServerOrder.create
            serverId: cart.id
            items: cart.items
        ,   () ->
                console.log arguments


app.controller 'StoreServerCartItemCtrl', ($scope, $rootScope) ->
    $scope.$watch 'item.amount', (newVal, oldVal) =>
        return if (newVal= newVal|0) == (oldVal= oldVal|0)
        $scope.updateTotal $scope.item.price * (newVal - oldVal)

    $scope.remItem= (item) ->
        items= $scope.cart.items
        angular.forEach items, (itm, i) ->
            items.splice i, 1 if item.id == itm.id



#app.controller 'StorageCtrl', ['$scope', '$route', 'StoreOrder', ($scope, $route, StoreOrder) ->
#    $scope.state= 'load'
#
#    $scope.orders= StoreOrder.query () ->
#        $scope.state= 'loaded'
#
#    $scope.server= null
#    $scope.store.$then () ->
#        for server in $scope.store.servers
#            if server.name == $route.current.params.server
#                $scope.server= server
#                break
#
#]
#
#
#app.controller 'StoreOrderCtrl', ['$scope', '$route', 'StoreOrder', ($scope, $route, StoreOrder) ->
#    $scope.state= 'load'
#    $scope.order= StoreOrder.get $route.current.params, (order) ->
#        $scope.state= 'loaded'
#]
#