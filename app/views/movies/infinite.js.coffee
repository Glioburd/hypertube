$ ->
  content = $('#content')
  viewMore = $('#view-more')
  currentPage = $('#currentPage').val()
  totalPages = $('#totalPages').val()

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

  console.log(moviesGallery.clientHeight)

  waitedLongEnoughBetweenPages = ->
    return lastLoadAt == null || new Date() - lastLoadAt > minTimeBetweenPages

  # approachingBottomOfPage = ->
  #   return document.documentElement.clientHeight +
  #     $(document).scrollTop() < document.body.offsetHeight - loadNextPageAt

  approachingBottomOfPage = ->
    return moviesGallery.clientHeight +
      $(document).scrollTop() > (document.body.offsetHeight - loadNextPageAt) * 2

  nextPage = ->
    url = viewMore.find('a').attr('href')

    return if isLoadingNextPage || !url

    viewMore.addClass('fa fa-circle-o-notch fa-spin')
    isLoadingNextPage = true
    lastLoadAt = new Date()

    $.ajax({
      url: url,
      method: 'GET',
      dataType: 'script',
      success: ->
        viewMore.removeClass('fa fa-circle-o-notch fa-spin')
        isLoadingNextPage = false
        lastLoadAt = new Date()
    })

  # watch the scrollbar
  $(window).scroll ->
    console.log(approachingBottomOfPage())
    if approachingBottomOfPage() && waitedLongEnoughBetweenPages() && $('#currentPage').val() < $('#totalPages').val()
      # console.log('moviesGallery.clientHeight : '+moviesGallery.clientHeight)     
      # console.log('document.scrolltop() : '+$(document).scrollTop())
      # console.log('document.body.offsetHeight : '+document.body.offsetHeight)
      # console.log('loadNextPageAt : '+loadNextPageAt)
      nextPage()

  # failsafe in case the user gets to the bottom
  # without infinite scrolling taking affect.
  viewMore.find('a').click (e) ->
    nextPage()
    e.preventDefault()


# $(document).ready(function() {
#   if ($('#moviesGallery').length) {
#     $(window).scroll(function() {
#       var url = $('#moviesGallery .next_page').attr('href');
#       if (url && $(window).scrollTop() > $(document).height() - $(window).height() - 50) {
#         $('#moviesGallery').text("Please Wait...");
#         return $.getScript(url);
#       }
#     });
#     return $(window).scroll();
#   }
# });