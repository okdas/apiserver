#if !angular.module 'manage'
#    app= angular.module 'manage', ['ngAnimate', 'ngResource', 'ngRoute'], ($routeProvider) ->
#        $routeProvider.otherwise
#            redirectTo: '/'
#else
app= angular.module 'manage'





app.factory 'CurrentUser', ($resource) ->
    $resource '/api/v1/user/:action', {},
        login:
            method: 'post'
            params:
                action: 'login'

        logout:
            method: 'post'
            params:
                action: 'logout'





app.controller 'CurrentUserCtrl', ($scope, $window, CurrentUser) ->
    $scope.dropdown=
        isOpen: false

    $scope.toggleDropdown= ->
        $scope.dropdown.isOpen= !$scope.dropdown.isOpen

    $scope.user= CurrentUser.get ->
        console.log 'пользователь получен'

    $scope.logout= ->
        CurrentUser.logout $scope.user, ->
            do $window.location.reload





app.controller 'ViewCtrl', ($scope, $location, $http, $window, CurrentUser) ->
    $scope.referer= do $location.absUrl
    $scope.dialog=
        overlay: false

    $scope.showDialog= (type) ->
        $scope.dialog.overlay= type

    $scope.hideDialog= ->
        $scope.dialog.overlay= false

    $scope.hide= ->
        $location.path '/'

    $scope.$on '$locationChangeSuccess', ->
        switch $location.path()
            when '/login'
                $scope.showDialog 'login'
            else
                $scope.hideDialog()

    $scope.user= new CurrentUser

    $scope.login= (loginForm) ->
        $scope.user.$login (user) ->
            user.pass= loginForm.password.$modelValue
            $window.location.href= 'project/'
        , ->
            $scope.user.pass= ''
