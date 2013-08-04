app= angular.module 'management'


app.controller 'ViewCtrl', ($scope, $location, $http, $window) ->
        $scope.view= {}

        $scope.dialog= {overlay:false}
        $scope.showDialog= (type) ->
            $scope.dialog.overlay= type
        $scope.hideDialog= () ->
            $scope.dialog.overlay= false


app.factory 'CurrentUser', ($resource) ->
        $resource '/api/v1/user/:action', {},
            logout:
                method:'post'
                params:
                    action:'logout'


app.controller 'CurrentUserCtrl', ($scope, $window, CurrentUser) ->
        $scope.dropdown=
            isOpen: false

        $scope.toggleDropdown= () ->
            $scope.dropdown.isOpen= !$scope.dropdown.isOpen

        $scope.user= $scope.locals.user or CurrentUser.get () ->
            console.log 'пользователь получен', arguments

        $scope.logout= () ->
            CurrentUser.logout $scope.user, () ->
                do $window.location.reload

