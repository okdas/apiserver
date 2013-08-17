app= angular.module 'project.store', ['ngResource','ngRoute'], ($routeProvider) ->

    # Магазин

    $routeProvider.when '/store',
        templateUrl: 'partials/store/', controller: 'StoreDashboardCtrl'

    # Магазин. История покупок

    $routeProvider.when '/store/orders/list',
        templateUrl: 'partials/store/orders/', controller: 'StoreOrderListCtrl'

    # Магазин. Предметы

    $routeProvider.when '/store/items/list',
        templateUrl: 'partials/store/items/', controller: 'StoreItemListCtrl'

    $routeProvider.when '/store/items/item/create',
        templateUrl: 'partials/store/items/item/forms/create/', controller: 'StoreItemFormCtrl'

    $routeProvider.when '/store/items/item/update/:itemId',
        templateUrl: 'partials/store/items/item/forms/update/', controller: 'StoreItemFormCtrl'

    # Магазин. Чары

    $routeProvider.when '/store/enchantments/list',
        templateUrl: 'partials/store/enchantments/', controller: 'StoreEnchantmentCtrl'

    $routeProvider.when '/store/enchantments/enchantment/create',
        templateUrl: 'partials/store/enchantments/enchantment/forms/create', controller: 'StoreEnchantmentFormCtrl'

    $routeProvider.when '/store/enchantments/enchantment/update/:enchantmentId',
        templateUrl: 'partials/store/enchantments/enchantment/forms/update', controller: 'StoreEnchantmentFormCtrl'





###

Ресурсы

###


###
Модель заказа.
###
app.factory 'Order', ($resource) ->
    $resource '/api/v1/store/orders/:orderId',
        orderId:'@id'


###
Модель предмета.
###
app.factory 'Item', ($resource) ->
    $resource '/api/v1/store/items/:itemId',
        itemId:'@id'
    ,

        create:
            method:'post'

        update:
            method:'put'
            params:
                itemId:'@id'

        delete:
            method:'delete'
            params:
                itemId:'@id'


###
Модель формы предмета.
###
app.factory 'ItemForm', ($q, Item, Enchantment, Server) ->

    @loadEnchantments= () ->
        dfd= do $q.defer
        Enchantment.query (enchantments) ->
            dfd.resolve enchantments
        dfd.promise

    @loadServers= () ->
        dfd= do $q.defer
        Server.query (servers) ->
            dfd.resolve servers
        dfd.promise

    @load= () =>
        dfd= do $q.defer
        result= $q.all [
            @loadEnchantments()
            @loadServers()
        ]
        result.then (data) ->
            data=
                enchantments: data[0]
                servers: data[1]
            dfd.resolve data
        dfd.promise

    @


###
Модель чар.
###
app.factory 'Enchantment', ($resource) ->
    $resource '/api/v1/store/enchantments/:enchantmentId',
        enchantmentId:'@id'
    ,

        create:
            method:'post'

        update:
            method:'patch'
            params:
                enchantmentId:'@id'

        delete:
            method:'delete'
            params:
                enchantmentId:'@id'





###

Фильтры

###

###
Фильтр чар в редакторе для предмета.
###
app.filter 'filterItemEnchantment', ->
    (enchantments, item) ->
        filtered= []
        angular.forEach enchantments, (enchantment) ->
            found= false
            angular.forEach item.enchantments, (e) ->
                found= true if e.id == enchantment.id

            filtered.push enchantment if not found
        filtered





###

Контроллеры

###


###
Контроллер панели управления.
###
app.controller 'StoreDashboardCtrl', ($scope) ->
    $scope.state= 'loaded'


###
Контроллер списка покупок.
###
app.controller 'StoreOrderListCtrl', ($scope, $location, Order) ->
    $scope.state= 'load'

    load= ->
        $scope.orders= Order.query (orders) ->
            $scope.state= 'loaded'
            console.log 'Заказы загружены', orders

    do load


###
Контроллер списка предметов.
###
app.controller 'StoreItemListCtrl', ($scope, $location, Item) ->
    $scope.items= {}
    $scope.state= 'load'

    load= ->
        $scope.items= Item.query ->
            $scope.state= 'loaded'
            console.log 'Предметы загружены'

    do load

    $scope.showDetails= (item) ->
        $scope.dialog.item= item
        $scope.dialog.templateUrl= 'item/dialog/'
        $scope.showDialog true

    $scope.hideDetails= ->
        $scope.dialog.item= null
        do $scope.hideDialog

    $scope.reload= ->
        do load


###
Контроллер формы предмета.
###
app.controller 'StoreItemFormCtrl', ($scope, $route, $q, $location, Item, Enchantment, ItemForm) ->
    $scope.errors= {}
    $scope.enchantment= {}
    $scope.state= 'load'

    $scope.form= do ItemForm.load
    $scope.form.then (form) ->
        console.log 'form loaded', form

        $scope.enchantments= form.enchantments
        $scope.servers= form.servers

        if $route.current.params.itemId
            $scope.item= Item.get $route.current.params, ->
                $scope.state= 'loaded'
        else
            $scope.item= new Item
            $scope.item.enchantments= []
            $scope.state= 'loaded'

    # Чары предмета

    $scope.addEnchantment= (enchantment) ->
        return if not $scope.enchantment
        enchantment= angular.copy $scope.enchantment
        $scope.enchantment= null
        enchantment.level= 1
        $scope.item.enchantments.push enchantment

    $scope.remEnchantment= (enchantment) ->
        enchantments= []
        angular.forEach $scope.item.enchantments, (e) ->
            enchantments.push e if enchantment != e
        $scope.item.enchantments= enchantments

    # Действия

    $scope.create= (ItemForm) ->
        $scope.item.$create ->
            $location.path '/store/items/list', (err) ->
                $scope.errors= err.data.errors
                if 400 == err.status
                    angular.forEach err.data.errors, (error, input) ->
                        ItemForm[input].$setValidity error.error, false

    $scope.update= (ItemForm) ->
        $scope.item.$update ->
            $location.path '/store/items/list', (err) ->
                $scope.errors= err.data.errors
                if 400 == err.status
                    angular.forEach err.data.errors, (error, input) ->
                        ItemForm[input].$setValidity error.error, false

    $scope.delete= ->
        $scope.item.$delete ->
            $location.path '/store/items/list'


###
Контроллер списка чар.
###
app.controller 'StoreEnchantmentCtrl', ($scope, $location, Enchantment) ->
    $scope.enchantments= {}
    $scope.state= 'load'


    load= ->
        $scope.enchantments= Enchantment.query ->
            $scope.state= 'loaded'
            console.log 'Чары загружены'

    do load


    $scope.showDetails= (enchantment) ->
        $scope.dialog.enchantment= enchantment
        $scope.dialog.templateUrl= 'enchantment/dialog/'
        $scope.showDialog true


    $scope.hideDetails= ->
        $scope.dialog.enchantment= null
        do $scope.hideDialog


    $scope.reload= ->
        do load


###
Контроллер формы чар.
###
app.controller 'StoreEnchantmentFormCtrl', ($scope, $route, $location, Enchantment) ->
    $scope.errors= {}
    $scope.state= 'load'

    # Чары

    if $route.current.params.enchantmentId
        $scope.enchantment= Enchantment.get $route.current.params, ->
            $scope.state= 'loaded'
    else
        $scope.enchantment= new Enchantment
        $scope.state= 'loaded'

    # Действия

    $scope.create= (EnchantmentForm) ->
        $scope.enchantment.$create ->
            $location.path '/store/enchantments/list'
        ,  (err) ->
            $scope.errors= err.data.errors
            if 400 == err.status
                angular.forEach err.data.errors, (error, input) ->
                    EnchantmentForm[input].$setValidity error.error, false

    $scope.update= (EnchantmentForm) ->
        $scope.enchantment.$update ->
            $location.path '/store/enchantments/list'
        ,  (err) ->
                $scope.errors= err.data.errors
                if 400 == err.status
                    angular.forEach err.data.errors, (error, input) ->
                        EnchantmentForm[input].$setValidity error.error, false

    $scope.delete= ->
        $scope.enchantment.$delete ->
            $location.path '/store/enchantments/list'
        ,   () ->
