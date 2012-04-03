unit uGeoLocation;

interface

uses
  ActiveX,
  Variants,
  SHDocVw,
  MSHTML,
  Vcl.OleCtrls;

const
  GoogleMapHTMLStr: string =
    '<html> '+
    '<head> '+
    '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />' +
    '<META HTTP-EQUIV="MSThemeCompatible" CONTENT="Yes">'+
    '<meta name="viewport" content="initial-scale=1.0, user-scalable=yes" /> '+
    '<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=true&language=%LANG%&libraries=panoramio"></script> '+
    '<script type="text/javascript"> '+
    ''+

    ''+
    '  var geocoder; '+
    '  var maxZoomService; '+
    '  var map;  '+
    '  var markersArray = [];'+
    '  var infoWindow;'+
    '  var mapLat;'+
    '  var mapLng;'+
    '  var currentImage;'+
    '  var currentLat;'+
    '  var currentLng;'+
    '  var imageLat;'+
    '  var imageLng;'+
    '  var currentDate;'+
    '  var canSave;'+
    ''+
    ''+
    '  function initialize() { '+
    '    geocoder = new google.maps.Geocoder();'+
    '    var latlng = new google.maps.LatLng(0, 0); '+
    '    var myOptions = { '+
    '      zoom: 19, '+
    '      center: latlng, '+
    '      mapTypeId: google.maps.MapTypeId.SATELLITE '+
    '    }; '+
    '    map = new google.maps.Map(document.getElementById("map_canvas"), myOptions); '+
    '    map.set("streetViewControl", false);'+
    '    google.maps.event.addListener(map, "click", '+
    '         function(event){ '+
    '                          mapLat = event.latLng.lat();' +
    '                          mapLng = event.latLng.lng();' +
    '                          currentLat = mapLat; '+
    '                          currentLng = mapLng; '+
    '                          if (external.CanSaveLocation(mapLat, mapLng, 1) > 0){' +
    '                            canSave = true; '+
    '                            PutMarker(mapLat, mapLng); '+
    '                          } '+
    '                        } '+
    '    ); '+

    '    google.maps.event.addListener(map, "bounds_changed", function() { '+
    '      external.ZoomPan(map.getCenter().lat(), map.getCenter().lng(), map.getZoom()) '+
    '    }); '+
    '    infoWindow = new google.maps.InfoWindow();'+
    '    maxZoomService = new google.maps.MaxZoomService(); '+

    '    google.maps.event.addListener(infoWindow, "domready", function () { '+
    '      external.UpdateEmbed(); '+
    '      if (canSave) ' +
    '        DisplaySave("block"); '+
    '    }); '+

    '    external.MapStarted(); '+
    '  } '+
    ''+

    '  function DisplaySave(Value) { '+
    '    var arr = document.getElementsByTagName("div"); '+
    '    for (i = 0; i < arr.length; i++)  '+
    '       if (arr[i].className == "divSave") '+
    '         arr[i].style.display = Value; '+
    '  } '+

    '  function GotoLatLng(Lat, Lng) { '+
    '    var latlng = new google.maps.LatLng(Lat, Lng);'+
    '    map.setCenter(latlng);'+
    '  }'+
    ''+

    '  function SetMapBounds(Lat, Lang, Zoom) { '+
    '    var latlng = new google.maps.LatLng(Lat,Lang);'+
    '    map.setCenter(latlng);'+
    '    map.setZoom(Zoom);'+
    '  }'+
    ''+

    '  function SaveLocation() { '+
    '    external.SaveLocation(mapLat, mapLng, currentImage);'+
    '  }'+
    ''+

    ' var panoramioLayer = null; '+
    ' function showPanaramio() { '+
    '   if (panoramioLayer == null) { '+
    '        panoramioLayer = new google.maps.panoramio.PanoramioLayer(); '+
    '   } '+
    '   panoramioLayer.setMap(map); '+
    ' } '+

    ' function hidePanaramio() { '+
    '   if (panoramioLayer != null) { '+
    '       panoramioLayer.setMap(null); '+
    '   } '+
    ' } '+

    'function ClearMarkers() {  '+
    '  if (markersArray) {        '+
    '    for (i in markersArray) {  '+
    '      markersArray[i].setMap(null); '+
    '    } '+
    '  } '+
    '}  '+
    ''+

    'function ResetLocation(){' +
    '  canSave = false; ' +
    '  external.CanSaveLocation(0, 0, -1);' +
    '  if ((imageLat != 0) && (imageLng != 0)) {'+
    '    PutMarker(imageLat, imageLng);' +
    '    currentLat = imageLat; '+
    '    currentLng = imageLng; '+
    '  } else {'+
    '    ClearMarkers();' +
    '  }' +
    '} '+

    'function SaveImageInfo(Name, Date){' +
    '   canSave = false; '+
    '   currentImage = Name; '+
    '   currentDate = Date; '+
    '   imageLat = 0; '+
    '   imageLng = 0; '+
    '' +
    '} '+

    'function ShowImageLocation(Lat, Lng, Msg, Date) { '+
    '   canSave = false; '+
    '   currentLat = Lat; '+
    '   currentLng = Lng; '+
    '   imageLat = Lat; '+
    '   imageLng = Lng; '+
    '   currentImage = Msg; '+
    '   currentDate = Date; '+
    '   PutMarker(Lat, Lng); '+
    '}' +

    'function PutMarker(Lat, Lng) { '+
    '   ClearMarkers(); '+
    '   var html = document.getElementById("googlePopup").innerHTML;'+
    '   html = html.replace(/%NAME%/g, currentImage);'+
    '   html = html.replace(/%DATE%/g, currentDate);'+
    '   html = html.replace(/imageClass/g, "image");'+
    '   html = html.replace(/idSave/g, "divSave");'+
    '   if (canSave)' +
    '     html = html.replace(/1111/g, "350");'+
    '   else '+
    '     html = html.replace(/1111/g, "250");'+
    '    '+
    '   if (currentDate == "") '+
    '     html = html.replace(/inline/g, "none");'+
    '   var latlng = new google.maps.LatLng(Lat, Lng); '+
    '   var options = { '+
    '               position: latlng, '+
    '               map: map, '+
    '               icon: "http://www.google.com/mapfiles/marker.png", '+
    '               title: currentImage + " (" + Lat + ", " + Lng + ")", '+
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

    '  function showMaxZoom() { '+
    '    maxZoomService.getMaxZoomAtLatLng(map.getCenter(), function(response) { '+
    '      if (response.status == google.maps.MaxZoomStatus.OK) { '+
    '        map.setZoom(response.zoom); '+
    '      } '+
    '    }); '+
    '  } '+

    'var locationReq = null; ' +
    'function LoadLocation(url) { ' +
    '  locationReq = new ActiveXObject("MSXML2.ServerXMLHTTP.6.0"); ' +
    '	 if (locationReq) {  ' +
    '	 	 locationReq.onreadystatechange = LoadLocationReply; ' +
    '		 locationReq.open("GET", url, true); ' +
    '		 locationReq.send(); ' +
    '	 } ' +
    '} ' +

    'function LoadLocationReply() { ' +
    '	if (locationReq && locationReq.readyState == 4) {  ' +
    '		if (locationReq.status == 200) { ' +
    '			var jsonObj = eval("(function(){return " + locationReq.responseText + ";})()"); ' +
    '     map.setMapTypeId(google.maps.MapTypeId.ROADMAP); '+
    '			FindLocation(jsonObj.text); ' +
    '		} ' +
    '	} ' +
    '}' +

    'function TryToResolvePosition(url){' +
    '  LoadLocation(url); ' +
    '}' +

    'function ZoomIn() { '+
    '  GotoLatLng(currentLat, currentLng); '+
    '  setTimeout("showMaxZoom()", 1); ' +
    '}'+
    ''+

    'google.maps.event.addDomListener(window, "load", initialize); ' +

    '</script> '+
    '<style>' +
    '</style>' +
    '</head> '+
    ''+
    '<body style="margin:0; padding:0; overflow: hidden"> '+
    '  <div id="map_canvas" style="width:100%; height:100%"></div> '+
    '  <div id="googlePopup" style="display: none;"> '+
    '	   <div style="height: 1111px; width: 230px; font-size: 12px;"> '+
    '       <p style="color: #000000; margin: 0"> '+
    '         <div style="text-align:center;"> '+
    '           <embed class="imageClass" width="204" height="204"></embed> '+
    '         </div> '+
    '         <span style="">%NAME_LABEL%: <strong>%NAME%</strong></span> '+
    '         <br /> '+
    '         <span style="display:inline">%DATE_LABEL%: %DATE%</span> '+
    '         <br /> '+
    '         <span style="padding-top: 5px; display:block;"><a onclick="ZoomIn();" href="javascript:;">%ZOOM_TEXT%</a></span> '+
    '         <div class="idSave" style="display: none; padding-top: 10px;"> '+
    '           <span style="padding: 5px;"><strong>%SAVE_TEXT%</strong></span> '+
    '           <br /> '+
    '           <input type="button" value="%YES%" onclick="SaveLocation()" style="width: 70px"> '+
    '           <input type="button" value="%NO%" onclick="ResetLocation()" style="width: 70px"> '+
    '         </div> '+
    '       </p> '+
    '     </div> '+
    '  </div> '+
    '</body> '+
    '</html> ';

//TODO: move this method to other unit
procedure ClearWebBrowser(WebBrowser: TWebBrowser);

implementation

procedure ClearWebBrowser(WebBrowser: TWebBrowser);
var
  v: Variant;
  HTMLDocument: IHTMLDocument2;
begin
  if WebBrowser <> nil then
  begin
    HTMLDocument := WebBrowser.Document as IHTMLDocument2;
    if HTMLDocument <> nil then
    begin
      v := VarArrayCreate([0, 0], varVariant);
      v[0] := ''; //empty document
      HTMLDocument.Write(PSafeArray(TVarData(v).VArray));
      HTMLDocument.Close;
    end;
  end;
end;

end.
