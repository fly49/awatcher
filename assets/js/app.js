// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"

document.getElementById("sync-btn").addEventListener("click", function() {
  let notice = document.getElementById("sync-notice");
  notice.style.visibility = "visible";
  
  this.className = "sync button outline dark"
  this.disabled = true;
  this.style.pointerEvents = "none";

  httpPut("/sync");

  countdown(10);
}); 

function countdown(remaining) {
  if(remaining === 0){
    sessionStorage.setItem("reloading", "true");
    document.location.reload();
  }
  document.getElementById('remaining').innerHTML = remaining;
  setTimeout(function(){ countdown(remaining - 1); }, 1000);
};

window.onload = function() {
  var reloading = sessionStorage.getItem("reloading");
  if (reloading) {
      sessionStorage.removeItem("reloading");
      scroll({
        top: document.getElementById("list").offsetTop,
        behavior: "smooth"
      });
  }
}

function httpPut(theUrl)
{
    var xmlHttp = new XMLHttpRequest();
    xmlHttp.open( "PUT", theUrl, false ); // false for synchronous request
    xmlHttp.send( null );
    return xmlHttp.responseText;
}
