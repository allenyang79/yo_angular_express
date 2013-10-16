'use strict';
###
angular.module('demo3App', [])
  .config(function ($routeProvider) {
    $routeProvider
      .when('/', {
        templateUrl: 'views/main.html',
        controller: 'MainCtrl'
      })
      .otherwise({
        redirectTo: '/'
      });
});
###


@app=angular.module('demo3App',['ngResource','appier.edash'])
@app.config ['$routeProvider',($routeProvider)->
	$routeProvider.when '/',{
		templateUrl:'views/main.html'
		controller:'MainCtrl'
	}
	$routeProvider.otherwise {
		redirectTo: '/'
	}
]

console.log 'app.js run ok'
