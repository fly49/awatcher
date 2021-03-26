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

import {Socket} from "phoenix"
import LiveSocket from "phoenix_live_view"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}})

// Connect if there are any LiveViews on the page
liveSocket.connect()

// Expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
// The latency simulator is enabled for the duration of the browser session.
// Call disableLatencySim() to disable:
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

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
        top: document.getElementById("nav").offsetTop,
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
