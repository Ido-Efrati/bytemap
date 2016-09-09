  tempmarker = null; 
  /*
    Handles when user hits "submit" to search a location on the map.
  */
  $("#search").click(function(){
    launchSearch();
  });

  /* Handle when user hits enter key to search a location on the map.
  */
  $("#queryField").keyup(function(event){
    if (event.keyCode == 13){
      launchSearch();
    }
  });

  function launchSearch(){
    var query = $("#queryField").val();
    create_search(query);
  }
  /*
    Sends user's location query to whereis.mit.edu via ajax GET request
    Gets back the most likely MIT location based on this query, along with its associated information.
  */
  function create_search(query){
    $.ajax({
        url: "http://whereis.mit.edu/search",
        type: 'GET',
        data: {type: 'query', q: query, output: 'json'},
        dataType: 'jsonp',
        success: function(res){
          handle_search_result(res[0]);
        }
    });
  }
  /*
   Takes in MIT location information (as "result") and uses those as parameters to create a location.
  */
  function handle_search_result(result){
    if (result == undefined){
      handle_null_result();
    }else{
      var latitude = result.lat_wgs84;
      var longitude = result.long_wgs84;
      var mitlocation_id = result["id"];

      var epsilon = 0.000001;
      var marker = null;
      //search in existing markers
      marker = _.find(markers, function(obj) {
        return (Math.abs(obj.serviceObject.position.lat() - latitude) < epsilon && Math.abs(obj.serviceObject.position.lng() - longitude) < epsilon)
      });
      var centerpoint = new google.maps.LatLng(latitude,longitude);
      handler.getMap().setCenter(centerpoint)

      //remove any previous temp marker
      if (tempmarker!=null){
        handler.removeMarker(tempmarker); 
      }

      if (marker!=null){
        google.maps.event.trigger(marker.serviceObject, 'click', {latLng: new google.maps.LatLng(0, 0)});
      }else{
        $.ajax({
          type: 'GET',
          url: "/subscriptions/exists",
          dataType: "JSON",
          data: { mitlocation_id: mitlocation_id, user_id: <%= @userid%> },
          success: function(data){
              show_location(latitude, longitude, mitlocation_id, result["name"], result["bldgnum"], <%= @is_signed_in %>, data);
          }
        });   
      }
    }
  }

  /*If a location does not exist in the database, create a temporary location
  on the map that will allow the user to commit it to the database with a new
  active offer.*/
  function show_location(lat, lng, mitlocation_id, location_name,bldgnum, signed_in, subscriptionId){
    /*from google map api: https://developers.google.com/maps/articles/phpsqlinfo_v3*/
    
    /*the content of the inital byte form*/
    var buttonName = "Subscribe";
    if (subscriptionId!=-1){
      buttonName = "Unsubscribe";
    }
    if (!<%= @cansubscribe%>){
        buttonName = "Enable Texting!";
    }

    if(signed_in){
      var infoWindowContent = [
      "<h2><b> "+String(location_name) + "</b></h2>",
      "<h2>Post A New Byte "+ '<span class="tab"></span>' + '<input type="button" class="btn btn-primary" value="'+ buttonName +'" onClick="subscribe(\'' + mitlocation_id  + '\', \'' + subscriptionId  + '\')" /> </h2>',
      "<form id='map-form'>",
      "<div>Location Details: <input id='location-details' type='text' /></div>",
      "<div>Food Description: <input id='food-description' type='text' /></div>",
      '<center><input type="button" class="btn btn-primary" value="Post Byte" onClick="saveData(\'' + lat + '\',\'' + lng +
       '\', \'' + mitlocation_id + '\', \'' + location_name + '\',\'' + bldgnum + '\')" /></center>',
      "</form>"].join("");    
    }
    else{
      var infoWindowContent = [
      "<h2><b> " +String(location_name) + "</b></h2>",
      "<h2>Login To Post A Byte</h2>"].join("");   
    }

    var tempmarkerInfo= {"lat":lat,
      "lng":lng,
      "picture":{
       "url":"/pin.png",
       "width":"50",
       "height":"68"
      },
      "infowindow":infoWindowContent
    };

    //creates new temp marker
    tempmarker = handler.addMarker(tempmarkerInfo);
    google.maps.event.trigger(tempmarker.serviceObject, 'click', {latLng: new google.maps.LatLng(0, 0)});
  };

  /*
    Sends user's search query to whereis.mit.edu and gets back information for this potential location.
  */
  function handle_null_result(){
    $('.notice').html("Sorry, no MIT location found for your query").slideDown(500).delay(3000).slideUp(500)
  }

  /*
    Creates a permanent location on the map if such a location doesn't already 
    exist. If the location was sucessfully created, the initial offering will also
    be created.
  */
  function create_location(lat, lng, mitlocation_id, location_name,bldgnum, sub_location, description){
    $.ajax({
      url: "/locations",
      type: 'POST',
      data: {location: {latitude: lat, longitude: lng, title: location_name, customid: mitlocation_id, building_number: bldgnum}},
      success: function(res){
        create_offering(mitlocation_id,sub_location,description);
      }
    })
  }

  /* 
    creates the initial offering that for a new location 
    that was just added to the map.
  */
  function create_offering(mitlocation_id, sub_location, description){
    $.ajax({
      url: "/offerings",
      type: 'POST',
      data: {offering: {location: mitlocation_id, sub_location: sub_location, description: description}},
      success: function(res){ 
        location.reload();
      }
    })
  }

  /*
    initiate the creation of a new location and its initial offering if a user
    submits the initial offering form.
  */
  function saveData(lat, lng, mitlocation_id, location_name,bldgnum){
    var locationDetails = document.getElementById("location-details").value;
    var foodDescription = document.getElementById("food-description").value;
    create_location(lat, lng, mitlocation_id, location_name, bldgnum,locationDetails,foodDescription);
  };

  /*
    subscribe/unsubscribe to a location
  */
  function subscribe(mitlocation_id, subscriptionsId){
    if (<%= @cansubscribe%>){
      //if you already have a subscription, delete it
      if (subscriptionsId!=-1){
        $.ajax({
          url: "/subscriptions/"+subscriptionsId + "/destroyViaAjax",
          type: 'POST',
          data: {},
          success: function(res){ 
            location.reload();
          }
        });
      }else{  //create a subscription
        $.ajax({
          url: "/subscriptions",
          type: 'POST',
          data: {subscription: {mitlocation_id: mitlocation_id, user_id: <%= @userid%>}},
          success: function(res){ 
            location.reload();
          }
        });
      }
    }else{//didn't have a valid phone number
      window.location.replace("/users/"+ <%= @userid%> + "/edit");
    }
  };
