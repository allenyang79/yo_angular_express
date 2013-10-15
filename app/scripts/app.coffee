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
#
@app=angular.module('demo3App',[])
@app.config ['$routeProvider',($routeProvider)->
	$routeProvider.when '/',{
		templateUrl:'views/main.html'
		controller:'MainCtrl'
	}
	$routeProvider.otherwise {
		redirectTo: '/'
	}
]
console.log "GOGO"
