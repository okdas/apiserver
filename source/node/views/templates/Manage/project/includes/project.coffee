# создаем и возвращаем приложение из объявленных ранее модулей
app= angular.module 'manage'
,   ['project.servers', 'project.store', 'project.players', 'ngResource', 'ngRoute']
,   ($routeProvider) ->

        $routeProvider.otherwise
            redirectTo: '/'
