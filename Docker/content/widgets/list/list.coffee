class Dashing.List extends Dashing.Widget
  ready: ->
    if @get('unordered')
      $(@node).find('ol').remove()
    else
      $(@node).find('ul').remove()


  onData: (data) =>
    if data.empty == true
      $(@node).css('background-color', 'green')
    else
      $(@node).css('background-color', '#B4000A')
      
      for i, index in data.items
        if i.value == 'Building'
          $(@node).find('ul.list-nostyle').find("li:nth-child(#{index+1})").find('#service-body').css({'color':'black'});
          $(@node).find('ul.list-nostyle').find("li:nth-child(#{index+1})").find('#service-header').css({'color':'black'});
          $(@node).find('ul.list-nostyle').find("li:nth-child(#{index+1})").css({'background-color':'yellow'})
          $(@node).find('ul.list-nostyle').find("li:nth-child(#{index+1})").find('.imgHealth').css({'background-color':'black', 'border-radius':'10px'});