app= angular.module 'project.store'



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

