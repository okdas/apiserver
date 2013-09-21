# создаем и возвращаем приложение из объявленных ранее модулей
app= angular.module 'manage'
,   ['project.servers', 'project.players', 'project.content', 'project.store', 'ngResource', 'ngRoute']
,   ($routeProvider) ->

        $routeProvider.otherwise
            redirectTo: '/'
