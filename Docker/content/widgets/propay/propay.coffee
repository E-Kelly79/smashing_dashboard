class Dashing.Propay extends Dashing.Widget
  onData: (data) =>
        $(@node).find("div:nth-child(2)").css({'background-color': '#066800'});
        $(@node).find("div:nth-child(4)").css({'background-color': '#B60000'});