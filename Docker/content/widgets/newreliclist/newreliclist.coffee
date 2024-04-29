class Dashing.Newreliclist extends Dashing.Widget
  ready: ->
    if @get('unordered')
      $(@node).find('ol').remove()
    else
      $(@node).find('ul').remove()

  onData: (data) =>
    for i, index in data.items
        i.apdex = i.apdex.toString().concat(" sec");
        $(@node).css({'background-color': i.apdexColor});