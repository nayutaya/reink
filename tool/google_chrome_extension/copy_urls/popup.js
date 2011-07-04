
var popup = {};

popup.onLoad = function() {
  chrome.windows.getCurrent(function(currentWindow) {
    chrome.tabs.getAllInWindow(currentWindow.id, function(tabs) {
      var urls = "";
      for ( var i = 0, len = tabs.length; i < len; i++ )
      {
        urls += "# " + tabs[i].title + "\n";
        urls += tabs[i].url + "\n";
      }

      var textarea = document.getElementById("urls");
      textarea.value = urls;
      textarea.focus();
      textarea.select();
    });
  });
};
