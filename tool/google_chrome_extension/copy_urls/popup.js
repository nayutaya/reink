
var popup = {};

popup.onLoad = function() {
  chrome.windows.getCurrent(function(currentWindow) {
    currentWindowId = currentWindow.id;
    //alert("currentWindowId: " + currentWindowId);
    chrome.tabs.getAllInWindow(currentWindowId, function(tabs) {
      //alert("tabs: " + tabs);
       //document.getElementById("urls")
      var urls = "";
      for ( var i = 0, len = tabs.length; i < len; i++ )
      {
        urls += tabs[i].url + "\n";
      }
      alert(urls);
    });
  });
};
