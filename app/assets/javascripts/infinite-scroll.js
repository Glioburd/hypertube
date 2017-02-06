$(function() {
  var approachingBottomOfPage, content, isLoadingNextPage, lastLoadAt, loadNextPageAt, minTimeBetweenPages, nextPage, viewMore, waitedLongEnoughBetweenPages;
  content = $('#content');
  viewMore = $('#view-more');
  isLoadingNextPage = false;
  lastLoadAt = null;
  minTimeBetweenPages = 5000;
  loadNextPageAt = 1000;
  waitedLongEnoughBetweenPages = function() {
	return lastLoadAt === null || new Date() - lastLoadAt > minTimeBetweenPages;
  };
  approachingBottomOfPage = function() {
	return document.documentElement.clientHeight + $(document).scrollTop() < document.body.offsetHeight - loadNextPageAt;
  };
  nextPage = function() {
	var url;
	url = viewMore.find('a').attr('href');
	if (isLoadingNextPage || !url) {
	  return;
	}
	viewMore.addClass('loading');
	isLoadingNextPage = true;
	lastLoadAt = new Date();
	return $.ajax({
	  url: url,
	  method: 'GET',
	  dataType: 'script',
	  success: function() {
		viewMore.removeClass('loading');
		isLoadingNextPage = false;
		return lastLoadAt = new Date();
	  }
	});
  };
  $(window).scroll(function() {
	if (approachingBottomOfPage() && waitedLongEnoughBetweenPages()) {
	  return nextPage();
	}
  });
  return viewMore.find('a').click(function(e) {
	nextPage();
	return e.preventDefaults();
  });
});