class TeamEditor

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

window.teamEditor = new TeamEditor
teamEditor.addRemoteSearch();
