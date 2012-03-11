unit uGeoLocation;

interface

const
  GoogleMapHTMLStr: AnsiString =
    '<html> '+
    '<head> '+
    '<meta name="viewport" content="initial-scale=1.0, user-scalable=yes" /> '+
    '<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=true&language=%LANG%&libraries=panoramio"></script> '+
    '<script type="text/javascript"> '+
    ''+

    ''+
    '  var geocoder; '+
    '  var map;  '+
    '  var markersArray = [];'+
    '  var infoWindow;'+
    ''+
    ''+
    '  function initialize() { '+
    '    geocoder = new google.maps.Geocoder();'+
    '    var latlng = new google.maps.LatLng(0, 0); '+
    '    var myOptions = { '+
    '      zoom: 20, '+
    '      center: latlng, '+
    '      mapTypeId: google.maps.MapTypeId.SATELLITE '+
    '    }; '+
    '    map = new google.maps.Map(document.getElementById("map_canvas"), myOptions); '+
    '    map.set("streetViewControl", false);'+
    '    google.maps.event.addListener(map, "click", '+
    '         function(event) '+
    '                        {'+
    '                         markerClick(event.latLng.lat(), event.latLng.lng()); '+
    '                         PutMarker(event.latLng.lat(), event.latLng.lng(), ""); '+
    '                        } '+
    '    ); '+


    '    google.maps.event.addListener(map, "bounds_changed", function() { '+
    '      document.getElementById("MapLat").value = map.getCenter().lat() + "";'+
    '      document.getElementById("MapLng").value = map.getCenter().lng() + "";'+
    '      document.getElementById("MapZoom").value = map.getZoom() + "";'+
    '    }); '+
    '    infoWindow = new google.maps.InfoWindow();'+



    '    google.maps.event.addListener(infoWindow, "domready", function () { '+
    '      external.UpdateEmbed(); '+
    '    }); '+

    '    document.getElementById("MapIsReady").value = "1";'+
    '  } '+
    ''+

    '  function GotoLatLng(Lat, Lang) { '+
    '   var latlng = new google.maps.LatLng(Lat,Lang);'+
    '   map.setCenter(latlng);'+
    '  }'+
    ''+

    '  function SetMapBounds(Lat, Lang, Zoom) { '+
    '   var latlng = new google.maps.LatLng(Lat,Lang);'+
    '   map.setCenter(latlng);'+
    '   map.setZoom(Zoom);'+
    '  }'+
    ''+

    ' var panoramioLayer = null; '+
    ' function showPanaramio() { '+
    '     if (panoramioLayer == null) { '+
    '        panoramioLayer = new google.maps.panoramio.PanoramioLayer(); '+
    '     } '+
    '     panoramioLayer.setMap(map); '+
    ' } '+

    ' function hidePanaramio() { '+
    '     if (panoramioLayer != null) { '+
    '        panoramioLayer.setMap(null); '+
    '     } '+
    ' } '+

    ' function markerClick(lat, lng) { '+
    '    document.getElementById("LatValue").value = lat + ""; '+
    '    document.getElementById("LngValue").value = lng + ""; '+
    ' } '+
    ''+

    ' function clearPosition(lat, lng) { '+
    '    document.getElementById("LatValue").value = ""; '+
    '    document.getElementById("LngValue").value = ""; '+
    ' } '+
    ''+

    'function ClearMarkers() {  '+
    '  if (markersArray) {        '+
    '    for (i in markersArray) {  '+
    '      markersArray[i].setMap(null); '+
    '    } '+
    '  } '+
    '}  '+
    ''+

    'function PutMarker(Lat, Lang, Msg) { '+
    '   ClearMarkers(); '+

    '   var html = document.getElementById("googlePopup").innerHTML;'+
    '   html = html.replace(/%NAME%/g, Msg);'+
    '   html = html.replace(/imageClass/g, "image");'+

    '   var latlng = new google.maps.LatLng(Lat, Lang); '+
    '   var options = { '+
    '               position: latlng, '+
    '               map: map, '+
    '               icon: "http://www.google.com/mapfiles/marker.png", '+
    '               title: Msg+" ("+Lat+","+Lang+")", '+
    '               content: html '+
    '           }; '+

    '   var marker = new google.maps.Marker({ map: map });'+
    '   marker.setOptions(options); '+
    '   infoWindow.setOptions(options); '+
    '   infoWindow.open(map, marker); '+
    '   google.maps.event.addListener(marker, "click", function () { '+
    '          infoWindow.setOptions(options); '+
    '          infoWindow.open(map, marker); '+
    '       '+
    '  }); '+

    '  markersArray.push(marker); '+
    '  setTimeout("external.UpdateEmbed()", 1); '+
    '}'+
    ''+

    'function FindLocation(address) {  '+
    'geocoder.geocode( { "address": address}, function(results, status) { '+
    '    if (status == google.maps.GeocoderStatus.OK) { '+
    '      map.setCenter(results[0].geometry.location); '+
    '      if (results[0].geometry.bounds) '+
    '        map.fitBounds(results[0].geometry.bounds); '+
    '    }  '+
    '   });' +
	  '}'+
    ''+

    '</script> '+
    '</head> '+
    ''+
    '<body onload="initialize()" style="margin:0; padding:0; overflow: hidden"> '+
    '  <div id="map_canvas" style="width:100%; height:100%"></div> '+
    '  <input type="hidden" id="LatValue">'+
    '  <input type="hidden" id="LngValue">'+
    '  <input type="hidden" id="MapLat">'+
    '  <input type="hidden" id="MapLng">'+
    '  <input type="hidden" id="MapZoom">'+
    '  <input type="hidden" id="MapIsReady" value="0">'+
    '  </div>  '+
    '  <div id="googlePopup" style="display: none;"> '+
    '	   <div style="height: 120px; width: 205px;"> '+
    '       <p style="color: #000000; margin: 0 0 10px;"><span>%NAME%</span> '+
    '         <br />x '+
    '         <embed class="imageClass" width="120" height="100"></embed> '+
    '         <br />y '+
    '       </p> '+
    '     </div> '+
    '  </div> '+
    '</body> '+
    '</html> ';

implementation

end.
