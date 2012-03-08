unit uGeoLocation;

interface

const
(*

geocoder = new google.maps.Geocoder();
geocoder.geocode( { 'address': address}, function(results, status) {
  if (status == google.maps.GeocoderStatus.OK) {
    map.setCenter(results[0].geometry.location);
    var marker = new google.maps.Marker({
    map: map,
    position: results[0].geometry.location
  });


*)

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
    ''+
    ''+
    '  function initialize() { '+
    '    geocoder = new google.maps.Geocoder();'+
    '    var latlng = new google.maps.LatLng(0, 0); '+
    '    var myOptions = { '+
    '      zoom: 23, '+
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
    '    document.getElementById("MapIsReady").value = "1";'+
    '  } '+
    ''+
    ''+
    '  function GotoLatLng(Lat, Lang) { '+
    '   var latlng = new google.maps.LatLng(Lat,Lang);'+
    '   map.setCenter(latlng);'+
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

    'function ClearMarkers() {  '+
    '  if (markersArray) {        '+
    '    for (i in markersArray) {  '+
    '      markersArray[i].setMap(null); '+
    '    } '+
    '  } '+
    '}  '+
    ''+

    '  function PutMarker(Lat, Lang, Msg) { '+
    '   ClearMarkers(); '+
    '   var latlng = new google.maps.LatLng(Lat,Lang);'+
    '   var marker = new google.maps.Marker({'+
    '      position: latlng, '+
    '      map: map,'+
    '      title: Msg+" ("+Lat+","+Lang+")"'+
    '  });'+
    '  markersArray.push(marker); '+
    '  index= (markersArray.length % 10);'+
    '  if (index==0) { index=10 } '+
    '  icon = "http://www.google.com/mapfiles/kml/paddle/"+index+"-lv.png"; '+
    '  marker.setIcon(icon); '+
    '  }'+
    ''+

    '</script> '+
    '</head> '+
    ''+
    '<body onload="initialize()" style="margin:0; padding:0; overflow: hidden"> '+
    '  <div id="map_canvas" style="width:100%; height:100%"></div> '+
    '  <input type="hidden" id="LatValue">'+
    '  <input type="hidden" id="LngValue">'+
    '  <input type="hidden" id="MapIsReady" value="0">'+
    '  </div>  '+
    ''+
    '</body> '+
    '</html> ';

implementation

end.
