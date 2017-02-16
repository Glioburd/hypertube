$ ->
  # if (document.getElementById('moviesGallery'))
  if $('#moviesGallery').length > 0
    content = $('#content')
    viewMore = $('#view-more')
    load = $('#load')
    currentPage = $('#currentPage').val()
    totalPages = $('#totalPages').val()

    i = 0
    isLoadingNextPage = false
    lastLoadAt = null
    minTimeBetweenPages = 500
    loadNextPageAt = 2000
    moviesGallery = document.getElementById('moviesGallery')
    # console.log('moviesGallery.clientHeight : '+moviesGallery.clientHeight)     
    # console.log('document.scrolltop() : '+$(document).scrollTop())
    # console.log('document.body.offsetHeight : '+document.body.offsetHeight)
    # console.log('loadNextPageAt : '+loadNextPageAt)
    # console.log(moviesGallery.clientHeight + $(document).scrollTop()) 
    # console.log(document.body.offsetHeight - loadNextPageAt)

    # console.log(moviesGallery.clientHeight)

    waitedLongEnoughBetweenPages = ->
      return lastLoadAt == null || new Date() - lastLoadAt > minTimeBetweenPages

    approachingBottomOfPage = ->
      return moviesGallery.clientHeight +
        $(document).scrollTop() > (document.body.offsetHeight - loadNextPageAt) * 2

    nextPage = ->
      url = viewMore.find('a').attr('href')

      return if isLoadingNextPage || !url

      load.addClass('fa fa-circle-o-notch fa-spin')
      isLoadingNextPage = true
      lastLoadAt = new Date()

      $.ajax({
        url: url,
        method: 'GET',
        dataType: 'script',
        success: ->
          load.removeClass('fa fa-circle-o-notch fa-spin')
          isLoadingNextPage = false
          lastLoadAt = new Date()
      })

    # watch the scrollbar
    $(window).scroll ->
      if approachingBottomOfPage() && waitedLongEnoughBetweenPages() && parseInt($('#currentPage').val()) < parseInt($('#totalPages').val())
        nextPage()

    # failsafe in case the user gets to the bottom
    # without infinite scrolling taking affect.
    viewMore.find('a').click (e) ->
      nextPage()
      e.preventDefault()
