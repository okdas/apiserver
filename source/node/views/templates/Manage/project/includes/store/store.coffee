app= angular.module 'project.store', ['project.content'], ($routeProvider) ->

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
        templateUrl: 'partials/store/items/item/form/', controller: 'StoreItemFormCtrl'

    $routeProvider.when '/store/items/item/update/:itemId',
        templateUrl: 'partials/store/items/item/form/', controller: 'StoreItemFormCtrl'





###

Ресурсы

###



###
Модель предмета.
###
app.factory 'Item', ($resource) ->
    $resource '/api/v1/servers/item/:itemId', {},
        create:
            method: 'post'

        update:
            method: 'put'
            params:
                itemId: '@id'

        delete:
            method: 'delete'
            params:
                itemId: '@id'

###
Модель материала.
###
app.factory 'Material', ($resource) ->
    $resource '/api/v1/bukkit/materials/:materialId', {},
        create:
            method: 'post'

        update:
            method: 'put'
            params:
                materialId: '@id'

        delete:
            method: 'delete'
            params:
                materialId: '@id'

###
Модель чар.
###
app.factory 'Enchantment', ($resource) ->
    $resource '/api/v1/bukkit/enchantments/:enchantmentId', {},
        create:
            method: 'post'

        update:
            method: 'put'
            params:
                enchantmentId: '@id'

        delete:
            method: 'delete'
            params:
                enchantmentId: '@id'

###
Модель сервера.
###
app.factory 'Server', ($resource) ->
    $resource '/api/v1/servers/server'

###
Модель тега.
###
app.factory 'Tag', ($resource) ->
    $resource '/api/v1/tags/'





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
    load= ->
        $scope.orders= Order.query (orders) ->
            $scope.state= 'loaded'
            console.log 'Заказы загружены', orders

    do load



###
Контроллер списка предметов.
###
app.controller 'StoreItemListCtrl', ($scope, $location, Item) ->
    load= ->
        $scope.items= Item.query (items) ->
            $scope.state= 'loaded'
            for item in items
                for server in item.servers
                    server.abbr= 'L'

    do load

    $scope.showDetails= (item) ->
        $scope.view.dialog.item= item
        $scope.showViewDialog 'item'

    $scope.hideDetails= ->
        $scope.view.dialog.item= null
        do $scope.hideViewDialog

    $scope.reload= ->
        do load



###
Контроллер формы предмета.
###
app.controller 'StoreItemDialogCtrl', ($scope, $route, $q, $location, Item, Material, Enchantment, Server, Tag) ->

    $scope.materials= Material.query ->
    $scope.enchantments= Enchantment.query ->
    $scope.servers= Server.query ->
    $scope.tags= Tag.query ->

    promise= $q.all
        materials: $scope.materials.$promise
        enchantments: $scope.enchantments.$promise
        servers: $scope.servers.$promise
        tags: $scope.tags.$promise
    promise.then (resolved) ->
            console.log 'resolved', resolved
            $scope.state= 'none'
    ,   (error) ->
            $scope.state= 'fail'
            $scope.error= error

    $scope.filterServer= (server) ->
        isThere= true
        if $scope.item.servers
            $scope.item.servers.map (srv) ->
                if srv.id == server.id
                    isThere= false

        return isThere


    # ищем теги подходящие выбранным серверам
    $scope.filterTag= (tag) ->
        isThere= false
        if $scope.item.servers
            $scope.item.servers.map (server) ->
                if tag.serverId == server.id
                    isThere= true

        if $scope.item.tags
            $scope.item.tags.map (t) ->
                if t.id == tag.id
                    isThere= false

        return isThere



    $scope.changeMaterial= (material) ->
        $scope.item.titleRu= JSON.parse(material).titleRu
        $scope.item.titleEn= JSON.parse(material).titleEn


    $scope.addEnchantment= (enchantment) ->
        newEnchantment= JSON.parse angular.copy enchantment
        newEnchantment.level= 1
        $scope.item.enchantments= [] if not $scope.item.enchantments
        $scope.item.enchantments.push newEnchantment


    $scope.removeEnchantment= (enchantment) ->
        remPosition= null
        $scope.item.enchantments.map (ench, i) ->
            if ench.id == enchantment.id
                $scope.item.enchantments.splice i, 1


    $scope.addServer= (server) ->
        newServer= JSON.parse angular.copy server
        $scope.item.servers= [] if not $scope.item.servers
        $scope.item.servers.push newServer


    $scope.removeServer= (server) ->
        remPosition= null
        $scope.item.servers.map (srv, i) ->
            if srv.id == server.id
                $scope.item.servers.splice i, 1


    $scope.addTag= (tag) ->
        newTag= JSON.parse angular.copy tag
        $scope.item.tags= [] if not $scope.item.tags
        $scope.item.tags.push newTag


    $scope.removeTag= (tag) ->
        remPosition= null
        $scope.item.tags.map (t, i) ->
            if t.id == tag.id
                $scope.item.tags.splice i, 1





    # Действия

    $scope.create= (ItemForm) ->
        $scope.item.material= JSON.parse($scope.item.material).id
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
