app= angular.module 'project.store'



app.controller 'StoreViewCtrl', ($scope, Item) ->
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


    $scope.reloadItems= ->
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

