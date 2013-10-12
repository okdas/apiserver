app= angular.module 'project.content', ['ngResource','ngRoute'], ($routeProvider) ->

    # Bukkit
    $routeProvider.when '/content',
        templateUrl: 'partials/content/', controller: 'BukkitDashboardCtrl'


    # Bukkit. Материалы
    $routeProvider.when '/content/materials/list',
        templateUrl: 'partials/content/materials/', controller: 'BukkitMaterialListCtrl'

    $routeProvider.when '/content/materials/material/create',
        templateUrl: 'partials/content/materials/material/form/', controller: 'BukkitMaterialFormCtrl'

    $routeProvider.when '/content/materials/material/update/:materialId',
        templateUrl: 'partials/content/materials/material/form/', controller: 'BukkitMaterialFormCtrl'


    # Bukkit. Чары
    $routeProvider.when '/content/enchantments/list',
        templateUrl: 'partials/content/enchantments/', controller: 'BukkitEnchantmentCtrl'

    $routeProvider.when '/content/enchantments/enchantment/create',
        templateUrl: 'partials/content/enchantments/enchantment/form/', controller: 'BukkitEnchantmentFormCtrl'

    $routeProvider.when '/content/enchantments/enchantment/update/:enchantmentId',
        templateUrl: 'partials/content/enchantments/enchantment/form/', controller: 'BukkitEnchantmentFormCtrl'


    # Теги
    $routeProvider.when '/content/tag/list',
        templateUrl: 'partials/content/tags/', controller: 'ContentTagListCtrl'

    $routeProvider.when '/content/tag/create',
        templateUrl: 'partials/content/tags/tag/form/', controller: 'ContentTagFormCtrl'

    $routeProvider.when '/content/tag/update/:tagId',
        templateUrl: 'partials/content/tags/tag/form/', controller: 'ContentTagFormCtrl'





###

Ресурсы

###
# Модель материала.
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



# Модель чар.
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



# Модель тега
app.factory 'Tag', ($resource) ->
    $resource '/api/v1/tags/:tagId', {},
        create:
            method: 'post'

        update:
            method: 'put'
            params:
                tagId: '@id'

        delete:
            method: 'delete'
            params:
                tagId: '@id'



# Список серверов
app.factory 'ServerList', ($resource) ->
    $resource '/api/v1/servers/server'





###

Контроллеры

###
# Контроллер панели управления.
app.controller 'BukkitDashboardCtrl', ($scope) ->
    $scope.state= 'loaded'



# Контроллер материалов баккита
app.controller 'BukkitMaterialListCtrl', ($rootScope, $scope, Material) ->
    load= ->
        $scope.materials= Material.query ->
            $scope.state= 'loaded'
        , (res) ->
            $rootScope.error= res

    do load

    $scope.reload= ->
        do load



# Контроллер формы материала.
app.controller 'BukkitMaterialFormCtrl', ($rootScope, $scope, $location, Material) ->
    if $route.current.params.materialId
        $scope.material= Material.get $route.current.params, ->
            $scope.state= 'loaded'
            $scope.action= 'update'
        , (res) ->
            $rootScope.error= res
    else
        $scope.material= new Material
        $scope.state= 'loaded'
        $scope.action= 'create'

    # Действия
    $scope.create= ->
        $scope.material.$create ->
            $location.path '/store/materials/list'
        , (res) ->
            $rootScope.error= res

    $scope.update= ->
        $scope.material.$update ->
            $location.path '/store/materials/list'
        , (res) ->
            $rootScope.error= res

    $scope.delete= ->
        $scope.material.$delete ->
            $location.path '/store/materials/list'
        , (res) ->
            $rootScope.error= res



# Контроллер чар баккита
app.controller 'BukkitEnchantmentCtrl', ($rootScope, $scope, $location, Enchantment) ->
    load= ->
        $scope.enchantments= Enchantment.query ->
            $scope.state= 'loaded'
        , (res) ->
            $rootScope.error= res

    do load

    $scope.reload= ->
        do load



# Контроллер формы чара.
app.controller 'BukkitEnchantmentFormCtrl', ($rootScope, $scope, $location, Enchantment) ->
    if $route.current.params.enchantmentId
        $scope.enchantment= Enchantment.get $route.current.params, ->
            $scope.state= 'loaded'
            $scope.action= 'update'
        , (res) ->
            $rootScope.error= res
    else
        $scope.enchantment= new Enchantment
        $scope.state= 'loaded'
        $scope.action= 'create'

    # Действия
    $scope.create= ->
        $scope.enchantment.$create ->
            $location.path '/store/enchantments/list'
        , (res) ->
            $rootScope.error= res

    $scope.update= ->
        $scope.enchantment.$update ->
            $location.path '/store/enchantments/list'
        , (res) ->
            $rootScope.error= res

    $scope.delete= ->
        $scope.enchantment.$delete ->
            $location.path '/store/enchantments/list'
        , (res) ->
            $rootScope.error= res



# Контроллер списка тегов.
app.controller 'ContentTagListCtrl', ($rootScope, $scope, Tag) ->
    load= ->
        $scope.tags= Tag.query ->
            $scope.state= 'loaded'
        , (res) ->
            $rootScope.error= res

    do load

    $scope.reload= ->
        do load



# Контроллер формы тега.
app.controller 'ContentTagFormCtrl', ($rootScope, $scope, $location, Tag) ->
    if $route.current.params.tagId
        $scope.tag= Tag.get $route.current.params, ->
            $scope.tags= Tag.query ->
                $scope.state= 'loaded'
                $scope.action= 'update'
            , (res) ->
                $rootScope.error= res
        , (res) ->
            $rootScope.error= res
    else
        $scope.tag= new Tag
        $scope.tags= Tag.query ->
            $scope.state= 'loaded'
            $scope.action= 'create'
        , (res) ->
            $rootScope.error= res

    $scope.filterTag= (tag) ->
        show= true
        if $scope.tag.parentTags
            $scope.tag.parentTags.map (t) ->
                if t.id == tag.id
                    show= false

        return show

    $scope.addTag= (tag) ->
        newTag= JSON.parse angular.copy tag
        $scope.tag.parentTags= [] if not $scope.tag.parentTags
        $scope.tag.parentTags.push newTag

    $scope.removeTag= (tag) ->
        remPosition= null
        $scope.tag.parentTags.map (tg, i) ->
            if tg.id == tag.id
                $scope.tag.parentTags.splice i, 1

    # Действия
    $scope.create= ->
        $scope.tag.$create ->
            $location.path '/content/tag/list'
        , (res) ->
            $rootScope.error= res

    $scope.update= ->
        $scope.tag.$update ->
            $location.path '/content/tag/list'
        , (res) ->
            $rootScope.error= res

    $scope.delete= ->
        $scope.tag.$delete ->
            $location.path '/content/tag/list'
        , (res) ->
            $rootScope.error= res
