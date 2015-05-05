// phantomjs website screenshot creator
// usage: phantomjs webScreenshot.js https://archiv.gaengeviertel.tk test


var webPage = require('webpage');
var page = webPage.create();
var args = require('system').args;
var address = args[1];
var type = args[3];
page.paperSize = {
  format: "A4",
  orientation: "portrait",
  margin: {left:"2.5cm", right:"2.5cm", top:"1cm", bottom:"1cm"},
  footer: {
    height: "0.9cm",
    contents: phantom.callback(function(pageNum, numPages) {
      return "<div style='text-align:center;'><small>" + pageNum +
        " / " + numPages + "</small></div>";
    })
  }
};
page.viewportSize = {
  width: 1280,
  height: 720
};

if (type == 'pdf') {
    page.zoomFactor = 0.5;
    page.viewportSize = {
        width: 1280,
        height: 720
    };
} else {
    page.zoomFactor = 1;
    page.viewportSize = {
        width: 1280
    };
}


page.open(address , function () {
  // get our local version of jquery directly from node
  page.includeJs("http://localhost/js/lib/jquery-2.1.0.min.js", function() {
    page.evaluate(function() {
        $("link").each(function(i, v) {
            $(v).attr("media", "all");
        });
  });
   window.setTimeout(function () {
            page.render(args[2]+'.'+type);
            phantom.exit();
        },1500);
    });


} );

