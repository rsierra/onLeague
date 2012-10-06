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


window.chartDrawer = new ChartDrawer
