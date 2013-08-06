app= angular.module 'management.project'
,   ['project.servers', 'project.store', 'project.players']
,   ($routeProvider) ->

        $routeProvider.otherwise
            redirectTo: '/'





app.factory '$socket', ($q, $rootScope) ->
    dfd= do $q.defer

    socket= do io.connect
    socket.on 'connect', () ->
        console.log 'connected to channel', arguments

        $rootScope.$on '$destroy', () ->
            do socket.removeAllListeners

        $socket=
            on: (evt, done) ->
                socket.on evt, () ->
                    args= arguments
                    $rootScope.$apply () ->
                        done.apply socket, args

        dfd.resolve $socket

    dfd.promise





###

Ресурсы

###


app.factory 'CurrentUser', ($resource) ->
    $resource '/api/v1/user/:action', {},
        logout: {method:'post', params:{action:'logout'}}





###

Контроллеры

###


app.controller 'ViewCtrl', ($scope, $location, $http, $window, $socket) ->
        $scope.view= {}

        $scope.dialog= {overlay:false}
        $scope.showDialog= (type) ->
            $scope.dialog.overlay= type
        $scope.hideDialog= () ->
            $scope.dialog.overlay= false

        $socket.then () ->
            console.log 'connected'


app.controller 'CurrentUserCtrl', ($scope, $window, CurrentUser) ->
        $scope.dropdown=
            isOpen: false

        $scope.toggleDropdown= () ->
            $scope.dropdown.isOpen= !$scope.dropdown.isOpen

        $scope.user= CurrentUser.get () ->
            console.log 'пользователь получен', arguments

        $scope.logout= () ->
            CurrentUser.logout $scope.user, () ->
                do $window.location.reload





###

Директивы

###


app.directive 'bSortable', ($parse) ->
    controller: bSortable= ($scope) ->
        $scope.bSortable= {}

        $scope.bSortableUpdate= ->
            list= $scope.bSortable.getter $scope
            sorted= []

            $scope.bSortable.element.children().each ->
                id= $(this).attr 'id'

                angular.forEach list, (item, i) ->
                    sorted.push item if id == item.id


            console.log sorted
            angular.forEach list, (item, i) ->
                list[i]= sorted[i]

            console.log list
            do $scope.$digest

    link: ($scope, $e, $a) ->
        $scope.bSortable.getter= $parse $a.bSortable
        $scope.bSortable.element= $e


app.directive 'bSortableItem', ->
    require: '^bSortable'
    link: ($scope, $e, $a) ->
        $scope.bSortable.element.sortable(
            axis: 'y'
            helper: 'clone'
            forceHelperSize: false
            forcePlaceholderSize: false
            tolerance: 'pointer'
        ).off('sortupdate').on 'sortupdate', (evt, target) ->
            do $scope.bSortableUpdate
