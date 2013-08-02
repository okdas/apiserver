### Приложение ###
app= angular.module 'management', ['ngResource'], ($routeProvider) ->

    # Игроки

    $routeProvider.when '/players',
        templateUrl: 'project/players/', controller: 'PlayersDashboardCtrl'

    $routeProvider.when '/players/player/list',
        templateUrl: 'project/players/players/', controller: 'PlayersPlayerListCtrl'

    $routeProvider.when '/players/player/:playerId',
        templateUrl: 'project/players/players/player/', controller: 'PlayersPlayerCtrl'

    $routeProvider.when '/players/group/list',
        templateUrl: 'project/players/group/list/', controller: 'PlayersGroupListCtrl'

    $routeProvider.when '/players/permission/list',
        templateUrl: 'project/players/permission/list/', controller: 'PlayersPermissionListCtrl'



    # Серверы

    $routeProvider.when '/servers',
        templateUrl: 'project/servers/', controller: 'ServerListCtrl'

    $routeProvider.when '/servers/server/list',
        templateUrl: 'project/servers/servers/', controller: 'ServersServerListCtrl'

    $routeProvider.when '/servers/server/create',
        templateUrl: 'project/servers/servers/server/forms/create', controller: 'ServersServerFormCtrl'

    $routeProvider.when '/servers/server/update/:serverId',
        templateUrl: 'project/servers/servers/server/forms/update', controller: 'ServersServerFormCtrl'


    # Серверы. Инстансы
    
    $routeProvider.when '/servers/instance/list',
        templateUrl: 'project/servers/instances/', controller: 'ServersInstanceListCtrl'

    $routeProvider.when '/servers/instance/create',
        templateUrl: 'project/servers/instances/instance/forms/create', controller: 'ServersInstanceFormCtrl'

    $routeProvider.when '/servers/instance/update/:instanceId',
        templateUrl: 'project/servers/instances/instance/forms/update', controller: 'ServersInstanceFormCtrl'
    




    # Магазин

    $routeProvider.when '/store',
        templateUrl: 'project/store/', controller: 'StoreViewCtrl'

    # Магазин. Предметы

    $routeProvider.when '/store/items',
        templateUrl: 'project/store/items/', controller: 'StoreItemsCtrl'

    $routeProvider.when '/store/items/create',
        templateUrl: 'project/store/items/item/forms/create/', controller: 'StoreItemsFormCtrl'

    $routeProvider.when '/store/items/:itemId',
        templateUrl: 'project/store/items/item/forms/update/', controller: 'StoreItemsFormCtrl'



    # Магазин. Чары

    $routeProvider.when '/store/enchantments',
        templateUrl: 'project/store/enchantments/', controller: 'StoreEnchantmentsCtrl'

    $routeProvider.when '/store/enchantments/create',
        templateUrl: 'project/store/enchantments/enchantment/forms/create', controller: 'StoreEnchantmentsFormCtrl'

    $routeProvider.when '/store/enchantments/:enchantmentId',
        templateUrl:'project/store/enchantments/enchantment/forms/update', controller:'StoreEnchantmentsFormCtrl'



    $routeProvider.otherwise
        redirectTo: '/'



### Контроллеры ###

app.controller 'ViewCtrl', ($scope, $location, $http, $window) ->
        $scope.view= {}

        $scope.dialog= {overlay:false}
        $scope.showDialog= (type) ->
            $scope.dialog.overlay= type
        $scope.hideDialog= () ->
            $scope.dialog.overlay= false


app.factory 'CurrentUser'
,   ($resource) ->
        $resource '/api/v1/user/:action', {},
            logout:
                method:'post'
                params:
                    action:'logout'

app.controller 'CurrentUserCtrl'
,   ($scope, $window, CurrentUser) ->
        $scope.dropdown=
            isOpen: false

        $scope.toggleDropdown= () ->
            $scope.dropdown.isOpen= !$scope.dropdown.isOpen

        $scope.user= $scope.locals.user or CurrentUser.get () ->
            console.log 'пользователь получен', arguments

        $scope.logout= () ->
            CurrentUser.logout $scope.user, () ->
                do $window.location.reload



###

Игроки.

###

app.factory 'PlayerList', ($resource) ->
    $resource '/api/v1/players', {}

app.factory 'Player', ($resource) ->
    $resource '/api/v1/players/player/:playerId', {playerId:'@id'}

app.factory 'PlayerGroupList', ($resource) ->
    $resource '/api/v1/players/groups', {}

app.service 'loadPlayers', ($q, PlayerList, PlayerGroupList) ->
    d= do $q.defer
    return d.promise

app.controller 'PlayersDashboardCtrl', ($scope, PlayerList) ->
    $scope.state= 'loaded'

app.controller 'PlayersPlayerListCtrl', ($scope, PlayerList) ->
    $scope.state= 'load'

    $scope.players= PlayerList.query () ->
        $scope.state= 'loaded'
        console.log 'Пользователи загружены'

    $scope.showDetails= (player) ->
        $scope.dialog.player= player
        $scope.dialog.templateUrl= 'player/dialog/'
        $scope.showDialog true

    $scope.hideDetails= () ->
        $scope.dialog.player= null
        do $scope.hideDialog

app.controller 'PlayerCtrl', ($scope, $q, Player) ->

app.controller 'PlayersGroupListCtrl', ($scope) ->
    $scope.state= 'loaded'

app.controller 'PlayersPermissionListCtrl', ($scope) ->
    $scope.state= 'loaded'

app.controller 'StoreViewCtrl', ($scope, Item) ->





###

Сервера

###
app.factory 'Server', ($resource) ->
    $resource '/api/v1/servers/:serverId', {},
        create:
            method: 'post'

        update:
            method: 'put'
            params:
                serverId: '@id'

        delete:
            method: 'delete'
            params:
                serverId: '@id'




app.controller 'ServerListCtrl', ($scope, $q) ->
    $scope.state= 'loaded'



app.controller 'ServersServerListCtrl', ($scope, Server) ->
    $scope.server= {}
    $scope.state= 'load'


    load= ->
        $scope.servers= Server.query ->
            $scope.state= 'loaded'
            console.log 'Сервера загружены'

    do load


    $scope.showDetails= (server) ->
        $scope.dialog.server= server
        $scope.dialog.templateUrl= 'server/dialog/'
        $scope.showDialog true


    $scope.hideDetails= ->
        $scope.dialog.server= null
        do $scope.hideDialog


    $scope.reloadServers= ->
        do load



app.controller 'ServersServerFormCtrl', ($scope, $route, $location, Server) ->
    $scope.errors= {}

    if $route.current.params.serverId
        $scope.server= Server.get $route.current.params, ->
            console.log arguments
    else
        $scope.server= new Server

    # Действия
    $scope.create= (ServerForm) ->
        $scope.server.$create ->
            $location.path '/servers/server/list'
        ,   (err) ->
                $scope.errors= err.data.errors
                if 400 == err.status
                    angular.forEach err.data.errors, (error, input) ->
                        ServerForm[input].$setValidity error.error, false

    $scope.update= (ServerForm) ->
        $scope.server.$update ->
            $location.path '/servers/server/list'
        , (err) ->
                $scope.errors= err.data.errors
                if 400 == err.status
                    angular.forEach err.data.errors, (error, input) ->
                        ServerForm[input].$setValidity error.error, false

    $scope.delete= ->
        $scope.server.$delete ->
            $location.path '/servers/server/list'




app.factory 'Instance', ($resource) ->
    $resource '/api/v1/servers/:instanceId', {},
        create:
            method: 'post'

        update:
            method: 'put'
            params:
                instanceId: '@id'

        delete:
            method: 'delete'
            params:
                instanceId: '@id'


app.controller 'ServersInstanceListCtrl', ($scope, Instance) ->
    $scope.instance= {}
    $scope.state= 'load'


    load= ->
        $scope.instances= Instance.query ->
            $scope.state= 'loaded'
            console.log 'Сервера загружены'

    do load


    $scope.showDetails= (server) ->
        $scope.dialog.instance= instance
        $scope.dialog.templateUrl= 'instance/dialog/'
        $scope.showDialog true


    $scope.hideDetails= ->
        $scope.dialog.instance= null
        do $scope.hideDialog


    $scope.reloadInstances= ->
        do load





###

Магазин. Предметы

###


### Модель предмета.
###
app.factory 'Item'
,   ($resource) ->
        $resource '/api/v1/store/items/:itemId', {itemId:'@id'},
            create:{method:'post'}
            update:{method:'put', params:{itemId:'@id'}}
            delete:{method:'delete', params:{itemId:'@id'}}


### Контроллер списка предмета.
###
app.controller 'StoreItemsCtrl'
,   ($scope, $location, Item) ->
        $scope.items= Item.query () ->


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


###

Магазин. Чары

###


### Модель чар.
###
app.factory 'Enchantment', ($resource) ->
    $resource '/api/v1/store/enchantments/:enchantmentId', {enchantmentId:'@id'},
        create:{method:'post'}
        update:{method:'patch', params:{enchantmentId:'@id'}}
        delete:{method:'delete', params:{enchantmentId:'@id'}}


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
