//refreshes the interface every 4 minutes

setInterval(function(){
  // do not refresh if focus is currently on an input element
  if (document.activeElement.tagName == "INPUT"){return;}

  //refresh
  $.ajax({
        url: "refresh",
        type: 'GET',
        success: function(res){
         }
    });
}, 240000);