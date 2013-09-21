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

app.factory 'ServerList', ($resource) ->
    $resource '/api/v1/servers/server',

app.factory 'TagServer', ($resource) ->
    $resource '/api/v1/tags/server/:serverId', {},
        get:
            method: 'get'
            isArray: true
            params:
                serverId: '@id'

app.factory 'TagItem', ($resource) ->
    $resource '/api/v1/tags/items/:tagId'

app.factory 'TagItemServer', ($resource) ->
    $resource '/api/v1/tags/srv/:tagId', {},
        get:
            method: 'get'
            isArray: true
            params:
                tagId: '@id'

        update:
            method: 'put'
            params:
                tagId: '@id'




###

Контроллеры

###



###
Контроллер панели управления.
###
app.controller 'BukkitDashboardCtrl', ($scope) ->
    $scope.state= 'loaded'



###
Контроллер материалов баккита
###
app.controller 'BukkitMaterialListCtrl', ($scope, $location, Material) ->
    load= ->
        $scope.materials= Material.query ->
            $scope.state= 'loaded'

    do load

    $scope.reload= ->
        do load

###
Контроллер формы материала.
###
app.controller 'BukkitMaterialFormCtrl', ($scope, $route, $q, $location, Material) ->
    if $route.current.params.materialId
        $scope.material= Material.get $route.current.params, ->
            $scope.state= 'loaded'
            $scope.action= 'update'
    else
        $scope.material= new Material
        $scope.state= 'loaded'
        $scope.action= 'create'

    # Действия

    $scope.create= (MaterialForm) ->
        $scope.material.$create ->
            $location.path '/store/materials/list', (err) ->
                $scope.errors= err.data.errors
                if 400 == err.status
                    angular.forEach err.data.errors, (error, input) ->
                        MaterialForm[input].$setValidity error.error, false

    $scope.update= (MaterialForm) ->
        $scope.material.$update ->
            $location.path '/store/materials/list', (err) ->
                $scope.errors= err.data.errors
                if 400 == err.status
                    angular.forEach err.data.errors, (error, input) ->
                        MaterialForm[input].$setValidity error.error, false

    $scope.delete= ->
        $scope.material.$delete ->
            $location.path '/store/materials/list'



###
Контроллер чар баккита
###
app.controller 'BukkitEnchantmentCtrl', ($scope, $location, Enchantment) ->
    load= ->
        $scope.enchantments= Enchantment.query ->
            $scope.state= 'loaded'

    do load

    $scope.reload= ->
        do load

###
Контроллер формы чара.
###
app.controller 'BukkitEnchantmentFormCtrl', ($scope, $route, $q, $location, Enchantment) ->
    if $route.current.params.enchantmentId
        $scope.enchantment= Enchantment.get $route.current.params, ->
            $scope.state= 'loaded'
            $scope.action= 'update'
    else
        $scope.enchantment= new Enchantment
        $scope.state= 'loaded'
        $scope.action= 'create'

    # Действия

    $scope.create= (EnchantmentForm) ->
        $scope.enchantment.$create ->
            $location.path '/store/enchantments/list', (err) ->
                $scope.errors= err.data.errors
                if 400 == err.status
                    angular.forEach err.data.errors, (error, input) ->
                        EnchantmentForm[input].$setValidity error.error, false

    $scope.update= (EnchantmentForm) ->
        $scope.enchantment.$update ->
            $location.path '/store/enchantments/list', (err) ->
                $scope.errors= err.data.errors
                if 400 == err.status
                    angular.forEach err.data.errors, (error, input) ->
                        EnchantmentForm[input].$setValidity error.error, false

    $scope.delete= ->
        $scope.enchantment.$delete ->
            $location.path '/store/enchantments/list'



###
Контроллер списка тегов.
###
app.controller 'ContentTagListCtrl', ($scope, Tag) ->
    load= ->
        $scope.tags= Tag.query ->
            $scope.state= 'loaded'
            console.log 'Теги загружены'

    do load


    $scope.reload= ->
        do load



###
Контроллер формы тега.
###
app.controller 'ContentTagFormCtrl', ($scope, $route, $q, $location, Tag) ->
    if $route.current.params.tagId
        $scope.tag= Tag.get $route.current.params, ->
            $scope.tags= Tag.query ->
                $scope.state= 'loaded'
                $scope.action= 'update'
    else
        $scope.tag= new Tag
        $scope.tags= Tag.query ->
            $scope.state= 'loaded'
            $scope.action= 'create'


    $scope.filterTag= (tag) ->
        isThere= true
        if $scope.tag.parentTags
            $scope.tag.parentTags.map (t) ->
                if t.id == tag.id
                    isThere= false

        return isThere



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

    $scope.create= (TagForm) ->
        $scope.tag.$create ->
            $location.path '/content/tag/list', (err) ->
                console.log 'err', err

    $scope.update= (TagForm) ->
        $scope.tag.$update ->
            $location.path '/content/tag/list', (err) ->
                console.log 'err', err

    $scope.delete= ->
        $scope.tag.$delete ->
            $location.path '/content/tag/list'
