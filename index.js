#!/usr/bin/env node

// building out the node module here.
// thinking and gathering resources

var fs = require('fs')
    , cp = require('child_process')
    , sys = require('sys')
    , path = require('path');


//var argv=process.argv;
//argv.splice(0,2);

//if(argv.length<1){
//    throw new Error("I need project name");
//}
//var name=argv[0];

//var parentPath=argv[1] || process.cwd();
//var projPath=path.join(parentPath,name);

// this creates a unique detached instance of the script.
// this is correctly parsed
//var child = cp.spawn('./bin/./deadsimple.sh',  [uri, fifo], { detached: true, stdio: [ 'ignore', out, err ] });
//child.unref();

module.exports = {
    version: '2.0.1',
};

