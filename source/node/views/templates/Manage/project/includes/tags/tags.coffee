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
            $scope.state= 'loaded'
            $scope.action= 'update'
    else
        $scope.tag= new Tag
        $scope.state= 'loaded'
        $scope.action= 'create'

    # Действия

    ###
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
