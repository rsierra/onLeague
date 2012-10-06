class ChartDrawer
  drawPlayerPointsChart: (id) ->
    element = $('#'+id)
    Morris.Line
      element: id
      data: element.data('points')
      xkey: 'week'
      ykeys: ['points', 'average_points']
      labels: element.data('ylabels')
      ymax: 'auto 10'
      ymin: 'auto 0'
      dateFormat: (x) -> "#{element.data('xlabel')} #{x}"
      hideHover: true

  drawTeamPointsChart: (id) ->
    element = $('#'+id)
    Morris.Line
      element: id
      data: element.data('points')
      xkey: 'week'
      ykeys: ['points']
      labels: element.data('ylabels')
      ymax: 'auto 50'
      ymin: 'auto 20'
      dateFormat: (x) -> "#{element.data('xlabel')} #{x}"

window.chartDrawer = new ChartDrawer
