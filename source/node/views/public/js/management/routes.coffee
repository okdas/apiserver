app= angular.module 'management'

app.config ($routeProvider) ->
    $routeProvider.otherwise
        redirectTo: '/'

