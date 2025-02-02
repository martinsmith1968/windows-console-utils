var read        = require('read-data');
var printObject = require('print-object');
var parser      = require('json-parser');
var format      = require('string-format');
var fs          = require('fs');

// Usage
function Usage() {
  console.error(format("Usage: {0} [filename]", process && process.argv && process.argv[1]));
  console.error();
}

function Abort(text) {
  throw new Error(text);
}

// Variables

// Parameters
var fileName = '';
if (process && process.argv && process.argv.length > 2) {
  fileName = process.argv[2];
}

// Validate
if (!fileName) {
  Usage();
  Abort('Invalid or unspecified File Name');
}

// Read file
var contents = '';
fs.readFile(fileName, 'utf8', function (err,data) {
  if (err) {
    return console.error(format('Error: {0}', err));
  }
  
  var contents = data;

  var object = JSON.parse(contents);

  return reformat(object);
});

function reformat(object) {
  console.log(JSON.stringify(object, null, '  '));
}
