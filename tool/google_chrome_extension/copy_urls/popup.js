
var popup = {};

popup.onLoad = function() {
  chrome.windows.getCurrent(function(currentWindow) {
    currentWindowId = currentWindow.id;
    //alert("currentWindowId: " + currentWindowId);
  });
};
