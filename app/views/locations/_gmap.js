
  //Define the boundaries of a map 
  var strictBounds = new google.maps.LatLngBounds(
    new google.maps.LatLng(42.340, -71.20), 
    new google.maps.LatLng(42.370, -71.0)
  );

  //Define the max and min allowed zoom of the map
  var mapOptions = 
  {
    maxZoom:19,
    minZoom:15,
  };

  //Create a map and set the markers
  handler = Gmaps.build('Google', {markers: { maxRandomDistance: null} });
  handler.buildMap({ provider: mapOptions, internal: {id: 'map'}}, function(){

    handler.fitMapToBounds();
    markers = handler.addMarkers(<%=raw @hash.to_json %>);
    handler.bounds.extendWith(markers);
    //set the initial zoom
    handler.getMap().setZoom(16);
    //set the initial center 
    
    handler.getMap().setCenter(new google.maps.LatLng(42.359, -71.090413));
  });

  var map = handler.getMap();


   // Listen for the dragend event
  google.maps.event.addListener(map, 'dragend', function() {
     if (strictBounds.contains(map.getCenter())) return;

     // We're out of bounds - Move the map back within the bounds
     var c = map.getCenter(),
         x = c.lng(),
         y = c.lat(),
         maxX = strictBounds.getNorthEast().lng(),
         maxY = strictBounds.getNorthEast().lat(),
         minX = strictBounds.getSouthWest().lng(),
         minY = strictBounds.getSouthWest().lat();

     if (x < minX) x = minX;
     if (x > maxX) x = maxX;
     if (y < minY) y = minY;
     if (y > maxY) y = maxY;

     map.setCenter(new google.maps.LatLng(y, x));

   });




