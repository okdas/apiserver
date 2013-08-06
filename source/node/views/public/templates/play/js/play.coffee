app= angular.module 'play', ['ngResource'], ($routeProvider) ->

    $routeProvider.when '/',
        templateUrl: 'partials/', controller: 'PlayCtrl'

    $routeProvider.when '/login',
        templateUrl: 'partials/', controller: 'PlayCtrl'

    $routeProvider.when '/store/order',
        templateUrl: 'partials/store/order/:orderId', controller: 'StoreOrderCtrl'


app.factory 'Store', ($resource) ->
    $resource '/api/v1/player/store'

app.factory 'StoreOrder', ($resource) ->
    $resource '/api/v1/player/store/order/:orderId'
    ,
        orderId: '@id'
    ,
        create: {method:'post'}


app.controller 'ViewCtrl', ($scope, $location) ->
        $scope.dialog=
            overlay: null

        $scope.showDialog= () ->
            $scope.dialog.overlay= true

        $scope.hideDialog= () ->
            $location.path '/'
            $scope.dialog.overlay= null


app.factory 'Player', ($resource) ->
    $resource '/api/v1/player/:action', {},
        login: {method:'post', params:{action:'login'}}


app.controller 'PlayCtrl', ($scope, $location, Player) ->

    $scope.player= new Player

    init= () ->
        path= do $location.path
        switch path
            when '/login'
                $scope.dialog.templateUrl= 'partials/login/dialog/'
                $scope.dialog.player= $scope.player
                $scope.showDialog 'login'
            else
                do $scope.hideDialog
                $scope.dialog.templateUrl= null
                $scope.dialog.player= null

    $scope.$on '$locationChangeSuccess', init

    do init


app.controller 'PlayerLoginDialogCtrl', ($scope, $window) ->
    console.log 'login dialog ctrl', $scope.dialog.player
    $scope.player= $scope.dialog.player

    $scope.login= () ->
        $scope.player.$login () ->
                do $scope.hideDialog
                $window.location.href= 'player/'
        ,   () ->
                $scope.player.pass= ''


app.controller 'StoreCtrl', ['$scope', '$location', 'Store', 'StoreOrder', ($scope, $location, Store, StoreOrder) ->
    $scope.total= 0
    $scope.store= Store.get () ->

    $scope.updateTotal= (value) =>
        $scope.total= Math.round(($scope.total + value) * 100) / 100

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
            console.log 'заказ создан'
            $location.path "/store/order/#{order.id}"
]


app.controller 'ServerStorageCtrl', ['$scope', ($scope) ->
    $scope.server.storage.total= 0

    $scope.$watch 'server.storage.total', (newVal, oldVal) ->
        $scope.$parent.updateTotal newVal - oldVal

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
