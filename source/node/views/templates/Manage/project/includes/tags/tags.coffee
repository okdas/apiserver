app= angular.module 'project.tags', ['ngResource','ngRoute'], ($routeProvider) ->

    # Теги

    $routeProvider.when '/tags',
        templateUrl: 'partials/tags/', controller: 'TagsDashboardCtrl'



    $routeProvider.when '/tags/tag/list',
        templateUrl: 'partials/tags/tags/', controller: 'TagsTagListCtrl'

    $routeProvider.when '/tags/tag/create',
        templateUrl: 'partials/tags/tags/tag/form/', controller: 'TagsTagFormCtrl'

    $routeProvider.when '/tags/tag/update/:tagId',
        templateUrl: 'partials/tags/tags/tag/form/', controller: 'TagsTagFormCtrl'



    $routeProvider.when '/tags/servertag/list',
        templateUrl: 'partials/tags/servertags/', controller: 'TagsServerTagListCtrl'

    $routeProvider.when '/tags/servertag/create',
        templateUrl: 'partials/tags/servertags/servertag/form/', controller: 'TagsServerTagFormCtrl'

    $routeProvider.when '/tags/servertag/update/:tagId',
        templateUrl: 'partials/tags/servertags/servertag/form/', controller: 'TagsServerTagFormCtrl'





###

Ресурсы

###
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
app.controller 'TagsDashboardCtrl', ($scope) ->
    $scope.state= 'loaded'


###
Контроллер списка тегов.
###
app.controller 'TagsTagListCtrl', ($scope, Tag) ->
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
app.controller 'TagsTagFormCtrl', ($scope, $route, $q, $location, Tag) ->
    if $route.current.params.tagId
        $scope.tag= Tag.get $route.current.params, ->
            $scope.tags= Tag.query ->
                $scope.state= 'loaded'
                $scope.action= 'update'
    else
        $scope.tag= new Tag
        $scope.state= 'loaded'
        $scope.action= 'create'


    $scope.addTag= (tag) ->
        newTag= JSON.parse angular.copy tag
        $scope.tag.inheritTags= [] if not $scope.tag.inheritTags
        $scope.tag.inheritTags.push newTag


    $scope.removeTag= (tag) ->
        remPosition= null
        $scope.tag.inheritTags.map (tg, i) ->
            if tg.id == tag.id
                $scope.tag.inheritTags.splice i, 1

    # Действия

    $scope.create= (TagForm) ->
        $scope.tag.$create ->
            $location.path '/tags/tag/list', (err) ->
                console.log 'err', err

    $scope.update= (TagForm) ->
        $scope.tag.$update ->
            $location.path '/tags/tag/list', (err) ->
                console.log 'err', err

    $scope.delete= ->
        $scope.tag.$delete ->
            $location.path '/tags/tag/list'





###
Контроллер списка тегов.
###
app.controller 'TagsServerTagListCtrl', ($scope, ServerList, TagServer) ->
    $scope.servers= ServerList.query ->
        $scope.state= 'loaded'
        console.log 'Сервера загружены'


    $scope.changeServer= (serverId) ->
        $scope.tags= TagServer.get
            serverId: serverId
        ,   ->
                $scope.state= 'loaded'
                $scope.action= 'update'



###
Контроллер формы тега.
###
app.controller 'TagsServerTagFormCtrl', ($scope, $route, $q, $location, TagItem, TagItemServer) ->
    if $route.current.params.tagId
        $scope.items= TagItemServer.get $route.current.params, ->
            $scope.tag= TagItem.get $route.current.params, ->
                $scope.state= 'loaded'
                $scope.action= 'update'
    else
        $scope.tag= new Tag
        $scope.state= 'loaded'
        $scope.action= 'create'


    $scope.addItem= (item) ->
        newItem= JSON.parse angular.copy item
        $scope.tag.items= [] if not $scope.tag.items
        $scope.tag.items.push newItem


    $scope.removeItem= (item) ->
        remPosition= null
        $scope.tag.items.map (tg, i) ->
            if tg.id == item.id
                $scope.tag.items.splice i, 1



    $scope.update= (TagForm) ->
        news= new TagItemServer angular.copy $scope.tag
        news.$update ->
            $location.path '/tags/tag/list', (err) ->
                console.log 'err', err
