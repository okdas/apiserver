app= angular.module 'play', ['ngResource'], ($routeProvider) ->

    $routeProvider.when '/',
        templateUrl: 'partials/', controller: 'PlayerCtrl'

    $routeProvider.when '/store',
        templateUrl: 'partials/store/', controller: 'StoreCtrl'

    $routeProvider.when '/store/:server',
        templateUrl: 'partials/store/server/', controller: 'StoreServerCtrl'

    $routeProvider.when '/store/order/:orderId',
        templateUrl: 'partials/store/order/', controller: 'StoreOrderCtrl'

    $routeProvider.when '/storage',
        templateUrl: 'partials/storage/', controller: 'StorageCtrl'


app.factory 'Player', ($resource) ->
    $resource '/api/v1/player/:action', {},
        login: {method:'post', params:{action:'login'}}
        logout: {method:'post', params:{action:'logout'}}


app.factory 'Store', ($resource) ->
    $resource '/api/v1/player/store'


app.factory 'StoreOrder', ($resource) ->
    $resource '/api/v1/player/store/order/:orderId'
    ,
        orderId: '@id'
    ,
        create: {method:'post'}


app.controller 'ViewCtrl', ($scope, $location, $window, Player, Store, StoreOrder) ->
    $scope.dialog=
        overlay: null

    $scope.player= Player.get () ->
    $scope.logout= () ->
        $scope.player.$logout () ->
            $window.location.href= '../'


    $scope.showDialog= () ->
        $scope.dialog.overlay= true

    $scope.hideDialog= () ->
        $scope.dialog.overlay= null

    $scope.state= 'load'

    $scope.total= 0
    $scope.store= Store.get () ->
        $scope.state= 'loaded'

    $scope.updateTotal= (value) =>
        $scope.total= 0
        for server in $scope.store.servers
            total= server.storage.total
            $scope.total= Math.round(($scope.total + total) * 100) / 100

    $scope.order= () ->
        order=
            servers: []
        for server in $scope.store.servers
            continue if not server.storage
            continue if not server.storage.items or not server.storage.items.length
            order.servers.push
                id: server.id
                items: server.storage.items
        StoreOrder.create order, (order) ->
            $location.path "/store/order/#{order.id}"


app.controller 'PlayerCtrl', ($scope, Player) ->


app.controller 'StoreCtrl', ['$scope', '$location', 'Store', 'StoreOrder', ($scope, $location, Store, StoreOrder) ->

]


app.controller 'StoreServerCtrl', ['$scope', '$route', 'Store', ($scope, $route, Store) ->
    $scope.server= null
    $scope.store.$then () ->
        for server in $scope.store.servers
            if server.name == $route.current.params.server
                $scope.server= server
                break

]


app.controller 'ServerStorageCtrl', ['$scope', ($scope) ->
    $scope.server.storage.total= 0

    $scope.$watch 'server.storage.total', () ->
        do $scope.$parent.updateTotal

    $scope.$watchCollection 'server.storage.items', (items) ->
        $scope.server.storage.total= 0
        angular.forEach items, (item) ->
            $scope.updateTotal item.price * item.amount

    $scope.updateTotal= (value) =>
        $scope.server.storage.total= Math.round(($scope.server.storage.total + value) * 100) / 100
]


app.controller 'ServerStorageItemCtrl', ['$scope', ($scope) ->

    $scope.$watch 'item.amount', (newVal, oldVal) =>
        return if (newVal= newVal|0) == (oldVal= oldVal|0)
        $scope.updateTotal $scope.item.price * (newVal - oldVal)


    $scope.remItem= (item) ->
        items= $scope.server.storage.items
        angular.forEach items, (itm, i) ->
            items.splice i, 1 if item.id == itm.id
]


app.controller 'ServerStoreCtrl', ['$scope', ($scope) ->

]


app.controller 'ServerStoreItemCtrl', ['$scope', ($scope) ->
    $scope.amount= 1

    $scope.buyItem= (item) =>
        return if not $scope.amount
        found= null
        items= $scope.server.storage.items
        angular.forEach items, (itm) =>
            if not found and item.id == itm.id
                found= itm

        if not found
            found= angular.copy item
            found.amount= 0
            items.push found

        amount= (found.amount|0) + ($scope.amount|0)
        found.amount= if amount > 99999 then 99999 else amount
        #$scope.amount= 1
]


app.controller 'StorageCtrl', ['$scope', '$route', 'StoreOrder', ($scope, $route, StoreOrder) ->
    $scope.state= 'load'

    $scope.orders= StoreOrder.query () ->
        $scope.state= 'loaded'

    $scope.server= null
    $scope.store.$then () ->
        for server in $scope.store.servers
            if server.name == $route.current.params.server
                $scope.server= server
                break

]


app.controller 'StoreOrderCtrl', ['$scope', '$route', 'StoreOrder', ($scope, $route, StoreOrder) ->
    $scope.state= 'load'
    $scope.order= StoreOrder.get $route.current.params, (order) ->
        $scope.state= 'loaded'
]
