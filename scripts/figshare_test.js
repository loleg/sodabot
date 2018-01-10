// Description:
//   testing script
//
// Dependencies:
//   None
//
// Configuration:
//   None
//
// Commands:
//   hubot is it weekend ?  - spews stuff to the log

var figshare = require('../figshare.js/.');

module.exports = function(robot) {
    robot.respond(/is it (weekend|holiday)\s?\?/i, function(msg){
        var stream = figshare.Figshare.search({fulltext: 'water'});
        stream.on('data', function (data) {
          console.log(data.items) // each 'data' is a page from the figshare search api
        })
    });
}
