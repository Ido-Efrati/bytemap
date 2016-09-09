$(function() {
    $('#queryField').autocomplete({
           minLength: 1,
            // This is the source of the autocomplete suggestions. Fetched from whereis.mit.edu.
            source: function(request, response){ 
                $.ajax({
                    url: "http://whereis.mit.edu/search",
                    dataType: "jsonp",
                    data: {
                        type: "suggest",
                        output: "json",
                        q: request.term
                    },
                    success: function(data){ 
                        response( $.map(data, function(item){
                            return item;
                        }));
                    }
                });

            },
            focus: function(event, ui) {
                $('#queryField').val(ui.item.label);
                return false;
            },
            select: function(event, ui) { 
                $('#queryField').val(ui.item.label);
                return false;
            }
    });
});
