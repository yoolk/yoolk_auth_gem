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

    var source_origin,
    iframe;

  var init = function (source) {
    source_origin = source;
  };

  var postMessage = function( message ) {
    // target_url = YOOLK_URL;
    if ( has_postMessage && YOOLK_URL ) {
      parent.postMessage( message, YOOLK_URL.replace( /([^:]+:\/\/[^\/]+).*/, '$1' ) ); 
    } else if ( YOOLK_URL ) {
      target.location = YOOLK_URL.replace( /#.*$/, '' ) + '#' + (+new Date) + (cache_bust++) + '&' + message;
    }
  };

  var _renderIframe =  function () {
    iframe = document.createElement("iframe");
    iframe.setAttribute("name", "yoolk_iframe_canvas");
    iframe.id = "yoolk_iframe_canvas";
    iframe.src = YOOLK_URL.replace( /([^:]+:\/\/[^\/]+).*/, '$1' );
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

  autoResize: function () {
    var height = Yoolk.Util.fullHeight(document.body),
      newHeight = 0,
      self = this;

    YoolkXDM.postMessage("{\"height\": " + height + "}");

    window.setInterval(function() {
      newHeight = Yoolk.Util.fullHeight(document.body);

      if (height !== newHeight) {
        height = newHeight;

        YoolkXDM.postMessage("{\"height\": " + height + "}");
      }
    }, 1000);
  }
};


Yoolk.Util = {
  fullHeight: function( elem ) {

    if ( this.getStyle( elem, 'display' ) != 'none' ){
      return elem.offsetHeight || this.getHeight( elem );
    }

    var old = this.resetCSS( elem, {
      display: '',
      visibility: 'hidden',
      position: 'absolute'
    });

    var h = elem.clientHeight || this.getHeight( elem );
    this.restoreCSS( elem, old );

    return h;
  },


  getStyle: function ( elem, name ) {
    if (elem.style[name]) {
      return elem.style[name];    
    } else if (elem.currentStyle) {
      return elem.currentStyle[name];
    } else if (document.defaultView && document.defaultView.getComputedStyle) {
      name = name.replace(/([A-Z])/g,"-$1");
      name = name.toLowerCase();
      var s = document.defaultView.getComputedStyle(elem,"");
      return s && s.getPropertyValue(name);
    } else {
      return null;
    }
  },

  getHeight: function ( elem ) {
    return parseInt( this.getStyle( elem, 'height' ) );
  },

  resetCSS: function ( elem, prop ) {
    var old = {};

    for ( var i in prop ) {
      old[ i ] = elem.style[ i ];
      elem.style[ i ] = prop[i];
    }

    return old;
  },
  
  restoreCSS: function ( elem, prop ) {
    for ( var i in prop ){
      elem.style[ i ] = prop[ i ];
    }
  }
};

if (window.addEventListener) {
  window.addEventListener('load', Yoolk.autoResize, false);
} else if (window.attachEvent) { 
  window.attachEvent('onload', Yoolk.autoResize);
}