$ ->
  content = $('#content')
  viewMore = $('#view-more')
  currentPage = $('#currentPage').val()
  totalPages = $('#totalPages').val()

  isLoadingNextPage = false
  lastLoadAt = null
  minTimeBetweenPages = 500
  loadNextPageAt = 400

  waitedLongEnoughBetweenPages = ->
    return lastLoadAt == null || new Date() - lastLoadAt > minTimeBetweenPages

  approachingBottomOfPage = ->
    return document.documentElement.clientHeight +
      $(document).scrollTop() < document.body.offsetHeight - loadNextPageAt

  nextPage = ->
    url = viewMore.find('a').attr('href')

    return if isLoadingNextPage || !url

    viewMore.addClass('loading')
    isLoadingNextPage = true
    lastLoadAt = new Date()

    $.ajax({
      url: url,
      method: 'GET',
      dataType: 'script',
      success: ->
        viewMore.removeClass('loading')
        isLoadingNextPage = false
        lastLoadAt = new Date()
    })

  # watch the scrollbar
  $(window).scroll ->
    if approachingBottomOfPage() && waitedLongEnoughBetweenPages() && $('#currentPage').val() < $('#totalPages').val()
      nextPage()

  # failsafe in case the user gets to the bottom
  # without infinite scrolling taking affect.
  viewMore.find('a').click (e) ->
    nextPage()
    e.preventDefault()