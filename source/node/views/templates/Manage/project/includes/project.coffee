# создаем и возвращаем приложение из объявленных ранее модулей
app= angular.module 'manage'
,   ['project.servers', 'project.store', 'project.players', 'project.tags', 'ngResource', 'ngRoute']
,   ($routeProvider) ->

        $routeProvider.otherwise
            redirectTo: '/'
