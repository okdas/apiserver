app= angular.module 'management'



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

