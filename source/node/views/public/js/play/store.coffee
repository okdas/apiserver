app= angular.module 'store', ['ngResource']

app.factory 'Store', ($resource) ->
    $resource '/api/v1/store'


app.controller 'StoreCtrl', ['$scope', 'Store', ($scope, Store) ->
    $scope.total= 0
    $scope.store= Store.get () ->

    $scope.updateTotal= (value) =>
        $scope.total= Math.round(($scope.total + value) * 100) / 100
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