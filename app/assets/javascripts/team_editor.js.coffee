class TeamEditor
  constructor: ->
    this.addRemoteSearch()
    this.addHideChanges()



  addRemoteSearch : ->
    $('.add-remote-search').submit ->
      url = $(this).attr 'action'
      data = "#{ $(this).serialize() }&#{ $('#club_file_search').serialize() }"

      $.ajax {
        type: 'POST',
        dataType: 'script',
        url: url,
        data: data
      }

      false

  addHideChanges : ->
    $('#hide-changes-button').toggle this.hideChanges, this.showChanges


  hideChanges : ->
    $('#team_files_changes').addClass 'hide-changes'
    setTimeout (->
      $('#hide-changes-button').addClass 'contract'
      $('#team_files_changes').addClass 'hidden'
      $('#team-alignment').removeClass 'span6'
      $('#team-alignment').addClass 'span8'
      $('#team-alignment').addClass 'offset2'),
      300

  showChanges : ->
    $('#hide-changes-button').removeClass 'contract'
    $('#team-alignment').addClass 'span6'
    $('#team-alignment').removeClass 'span8'
    $('#team-alignment').removeClass 'offset2'
    $('#team_files_changes').removeClass 'hidden'
    setTimeout (->
      $('#team_files_changes').removeClass 'hide-changes'),
      300

window.teamEditor = new TeamEditor
