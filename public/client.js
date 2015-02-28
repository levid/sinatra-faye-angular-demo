// Load THINGS data immediately
// 
var FayeServerURL = 'https://desolate-anchorage-8775.herokuapp.com/faye'
var app = angular.module('myApp', ['ngRoute']);

app.config(['$routeProvider', '$locationProvider', function ($routeProvider, $locationProvider) {
  $locationProvider.html5Mode(true);
  $routeProvider.otherwise({redirectTo:'/'});
}]);

app.run(['$rootScope', function($rootScope) {
  // Get the current user when the application starts
  // (in case they are still logged in from a previous session)
}]);

// Simple Faye service
app.factory('Faye', ['$rootScope', function($rootScope) {
  var client = new Faye.Client(FayeServerURL, {timeout: 120});
  client.disable('websocket');

  return {
    publish: function(channel, message, callback) {
      var publication = client.publish(channel, message);

      publication.then(function(msg) {
        console.log('Message received by server!');
      }, function(error) {
        console.log('There was a problem: ' + error.message);
      });
      // return client;
    },

    subscribe: function(channel, callback) {
      client.subscribe(channel, callback);
      // return client;
    }
  }
}]);

app.controller('FayeCtrl', ['$scope', '$http', 'Faye', '$timeout', '$interval', '$q', function($scope, $http, Faye, $timeout, $interval, $q) {
  $scope.messages = [];
  $scope.things = [];

  $scope.messages.add = function(direction, message) {
    this.push( { direction: direction, text: message });
  }
    
  // Listen to data coming from the server via Faye
  Faye.subscribe('/fromserver', function(msg) {
    $scope.$apply(function() {
      $scope.messages.add('incoming', msg);
    });
  });

  Faye.subscribe('/fromclient', function(msg) {
    $scope.$apply(function() {
      $scope.messages.add('outgoing', msg);
    });
  });

  Faye.subscribe('/things/new', function(res) {
    var res = JSON.parse(res);
    $scope.things.unshift(res);
  });

  Faye.subscribe('/things/all', function(res) {
    var data = JSON.parse(res);
    data.forEach(function (d) {
      console.log(d);
      $('#things-index').append("<p><strong>" + d.title + "</strong>: " + d.description + "</p>");
    });
  });

  // Send data to server via Faye
  $scope.sendClient = function() {
    Faye.publish('/fromclient', $scope.message);
    // $scope.messages.add('outgoing', $scope.message);
    $scope.message = '';
  };

  // Post the data to the server and have it send to us
  $scope.sendServer = function() {
    $http.post('/', { foo: 'asd', message: $scope.message })
      .success(function() {
        $scope.message = '';
      })
      .error(function(data, status) {
        $scope.messages.add('error', "Error doing POST to server: " + status);
      });
  };

  $scope.getThings = function(){
    $http.get('api/things')
      .success(function(res) {
        $scope.things = res;
      })
      .error(function(data, status) {
        alert(status);
      });
  };

  $scope.createThing = function(){
    $http.post('api/things', { title: $scope.title, description: $scope.description })
      .success(function(res) {
        // $scope.things.unshift(res);
      })
      .error(function(data, status) {
        alert(status);
      });
  };

  $scope.createChart = function(){
    var data = getRandomData();
    data.unshift('things');

    $scope.chart = c3.generate({
      bindto: '#chart',
      data: {
        columns: [
          data
        ]
      }
    });
  };

  $scope.loadChartData = function(){
    // var data = getRandomData();
    // $.shuffle(data);
    // data.unshift('things2');

    $http.get('api/chart-data')

    // $scope.chart.load({
    //   columns: [
    //     data
    //   ],
    //   unload: ['things']
    // });
  };

  // Listen to data coming from the server via Faye
  Faye.subscribe('/chart-data/update', function(msg) {
    var data = JSON.parse(msg);
    // console.log(data);
    data.unshift('things2');
    $scope.chart.load({
      columns: [
        data
      ],
      unload: ['things']
    });
  });

  $scope.getThings();
  $scope.createChart();
  
  // $interval(function(){
  //   $scope.loadChartData();
  // }, 2000);

  function getRandomData(){
    var data = [];
    var rand = Math.floor((Math.random() * 200) + 1);
    
    for(var i = 0; i < rand; i++){
      data.push(i);
    }
    data = $.shuffle(data);
    return data;
  }
}]);

/*
 * jQuery shuffle
 *
 * Copyright (c) 2008 Ca-Phun Ung <caphun at yelotofu dot com>
 * Dual licensed under the MIT (MIT-LICENSE.txt)
 * and GPL (GPL-LICENSE.txt) licenses.
 *
 * http://yelotofu.com/labs/jquery/snippets/shuffle/
 *
 * Shuffles an array or the children of a element container.
 * This uses the Fisher-Yates shuffle algorithm <http: //jsfromhell.com/array/shuffle [v1.0]>
 */
 
(function($){
 
    $.fn.shuffle = function() {
        return this.each(function(){
            var items = $(this).children().clone(true);
            return (items.length) ? $(this).html($.shuffle(items)) : this;
        });
    }
 
    $.shuffle = function(arr) {
        for(var j, x, i = arr.length; i; j = parseInt(Math.random() * i), x = arr[--i], arr[i] = arr[j], arr[j] = x);
        return arr;
    }
 
})(jQuery);