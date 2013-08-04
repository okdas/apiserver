### Приложение ###
app= angular.module 'project.store', ['ngResource']



app.config ($routeProvider) ->
    # Магазин

    $routeProvider.when '/store',
        templateUrl: 'project/store/', controller: 'StoreDashboardCtrl'



    # Магазин. Предметы

    $routeProvider.when '/store/items/list',
        templateUrl: 'project/store/items/', controller: 'StoreItemsListCtrl'

    $routeProvider.when '/store/items/item/create',
        templateUrl: 'project/store/items/item/forms/create/', controller: 'StoreItemsFormCtrl'

    $routeProvider.when '/store/items/item/update/:itemId',
        templateUrl: 'project/store/items/item/forms/update/', controller: 'StoreItemsFormCtrl'



    # Магазин. Чары

    $routeProvider.when '/store/enchantments/list',
        templateUrl: 'project/store/enchantments/', controller: 'StoreEnchantmentsCtrl'

    $routeProvider.when '/store/enchantments/create',
        templateUrl: 'project/store/enchantments/enchantment/forms/create', controller: 'StoreEnchantmentsFormCtrl'

    $routeProvider.when '/store/enchantments/:enchantmentId',
        templateUrl:'project/store/enchantments/enchantment/forms/update', controller:'StoreEnchantmentsFormCtrl'





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



### Модель чар.
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


### Фильтр чар в редакторе для предмета.
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





app.controller 'StoreDashboardCtrl', ($scope, Item) ->
    $scope.state= 'loaded'



app.controller 'StoreItemsListCtrl', ($scope, $location, Item) ->
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



### Контроллер редактора предмета.
###
app.controller 'StoreItemsFormCtrl', ($scope, $route, $location, Item, Enchantment) ->
    $scope.errors= {}

    if $route.current.params.itemId
        $scope.item= Item.get $route.current.params, () ->
            console.log arguments
    else
        $scope.item= new Item
        $scope.item.enchantments= []

    # Чары предмета

    $scope.enchantments= Enchantment.query () ->

    $scope.addEnchantment= () ->
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
        $scope.item.$create () ->
            $location.path '/store/items'
        ,   (err) ->
                $scope.errors= err.data.errors
                if 400 == err.status
                    angular.forEach err.data.errors, (error, input) ->
                        ItemForm[input].$setValidity error.error, false

    $scope.update= (ItemForm) ->
        $scope.item.$update () ->
            $location.path '/store/items'
        , (err) ->
                $scope.errors= err.data.errors
                if 400 == err.status
                    angular.forEach err.data.errors, (error, input) ->
                        ItemForm[input].$setValidity error.error, false

    $scope.delete= () ->
        $scope.item.$delete () ->
            $location.path '/store/items'






### Контроллер списка чар.
###
app.controller 'StoreEnchantmentsCtrl', ($scope, $location, Enchantment) ->
    $scope.enchantments= Enchantment.query () ->


### Контроллер редактора чар.
###
app.controller 'StoreEnchantmentsFormCtrl', ($scope, $route, $location, Enchantment) ->
    $scope.errors= {}

    # Чары

    if $route.current.params.enchantmentId
        $scope.enchantment= Enchantment.get $route.current.params, () ->
    else
        $scope.enchantment= new Enchantment

    # Действия

    $scope.create= (Form) ->
        $scope.enchantment.$create () ->
            $location.path '/store/enchantments'
        ,  (err) ->
            $scope.errors= err.data.errors
            if 400 == err.status
                angular.forEach err.data.errors, (error, input) ->
                    Form[input].$setValidity error.error, false

    $scope.update= (Form) ->
        $scope.enchantment.$update () ->
            $location.path '/store/enchantments'
        ,  (err) ->
                $scope.errors= err.data.errors
                if 400 == err.status
                    angular.forEach err.data.errors, (error, input) ->
                        Form[input].$setValidity error.error, false

    $scope.delete= () ->
        $scope.enchantment.$delete () ->
            $location.path '/store/enchantments'
        ,   () ->


