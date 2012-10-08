var YoolkXDM = function(){

  // A few vars used in non-awesome browsers.
  var interval_id,
    last_hash,
    cache_bust = 1,
    
    // A var used in awesome browsers.
    rm_callback,
    
    // A few convenient shortcuts.
    window = this,
    FALSE = !1,
    
    // Reused internal strings.
    postMessage = 'postMessage',
    addEventListener = 'addEventListener',
    
    p_receiveMessage,
    
    has_postMessage = window[postMessage];

  var target_url = YOOLK_URL,
    source_origin,
    iframe;

  var init = function (source) {
    source_origin = source;
  };

  var postMessage = function( message ) {
    if ( has_postMessage && target_url ) {
      parent.postMessage( message, target_url.replace( /([^:]+:\/\/[^\/]+).*/, '$1' ) ); 
    } else if ( target_url ) {
      target.location = target_url.replace( /#.*$/, '' ) + '#' + (+new Date) + (cache_bust++) + '&' + message;
    }
  };

  var _renderIframe =  function () {
    iframe = document.createElement("iframe");
    iframe.setAttribute("name", "yoolk_iframe_canvas");
    iframe.id = "yoolk_iframe_canvas";
    iframe.src = target_url.replace( /([^:]+:\/\/[^\/]+).*/, '$1' );
    document.body.appendChild(iframe);

    return iframe;
  };
  
  var receiveMessage = p_receiveMessage = function( callback, source_origin, delay ) {
    if ( has_postMessage ) {
      
      if ( callback ) {
        rm_callback && p_receiveMessage();
        
        rm_callback = function(e) {
          if ( ( typeof source_origin === 'string' && e.origin !== source_origin )
            || ( $.isFunction( source_origin ) && source_origin( e.origin ) === FALSE ) ) {
            return FALSE;
          }
          callback( e );
        };
      }
      
      if ( window[addEventListener] ) {
        window[ callback ? addEventListener : 'removeEventListener' ]( 'message', rm_callback, FALSE );
      } else {
        window[ callback ? 'attachEvent' : 'detachEvent' ]( 'onmessage', rm_callback );
      }
      
    } else {
      
      interval_id && clearInterval( interval_id );
      interval_id = null;
      
      if ( callback ) {
        delay = typeof source_origin === 'number'
          ? source_origin
          : typeof delay === 'number'
            ? delay
            : 100;
        
        interval_id = setInterval(function(){
          var hash = document.location.hash,
            re = /^#?\d+&/;
          if ( hash !== last_hash && re.test( hash ) ) {
            last_hash = hash;
            callback({ data: hash.replace( re, '' ) });
          }
        }, delay );
      }
    }
  };

  return {
    init: init,
    postMessage: postMessage,
    receiveMessage: receiveMessage
  };
  
}();

var Yoolk = typeof Yoolk === "object" ? Yoolk : {};

Yoolk = {
  _getWindowsHeight: function () {
    var self = this;
    var x, y, b = document.body, wi = window.innerHeight, ws = window.scrollMaxY;

    if (wi && ws) {
        y = wi + ws;
    } else if (b.scrollHeight > b.offsetHeight) {
        y = b.scrollHeight;
    } else {
        y = b.offsetHeight;
    }

    var w, h, d = document.documentElement;
    if (self.innerHeight) {
        h = self.innerHeight;
    } else if (d && d.clientHeight) {
        h = d.clientHeight;
    } else if (b) {
        h = b.clientHeight;
    }

    var pH = (y < h) ? h : y;

    return pH;
  },

  _iHeight: function () {
    var w, h, d = document.documentElement;
      if (self.innerHeight) {
          h = self.innerHeight;
      } else if (d && d.clientHeight) {
          h = d.clientHeight;
      } else if (b) {
          h = b.clientHeight;
      }

      return h;
  },

  autoResize: function () {
    var height = Yoolk._getWindowsHeight(),
      newHeight = 0,
      self = this;

    YoolkXDM.postMessage("{\"height\": " + height + "}");

    window.setInterval(function() {
      newHeight = Yoolk._getWindowsHeight();

      if (height !== newHeight) {
        height = newHeight;

        YoolkXDM.postMessage("{\"height\": " + height + "}");
      }
    }, 1000);
  }
};

if (window.addEventListener) {
  window.addEventListener('load', Yoolk.autoResize, false);
} else if (window.attachEvent) { 
  window.attachEvent('onload', Yoolk.autoResize);
}