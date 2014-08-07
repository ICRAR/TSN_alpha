TheSkyMap.PaginationLinksComponent = Ember.Component.extend
  maxPagesToDisplay: 9 #should be odd
  pageItems: (->
    activePage = Number @get "pagesObject.activePage"
    totalPages = Number @get "pagesObject.totalPages"
    maxPagesToDisplay = Number @get "maxPagesToDisplay"

    startTruc = false
    endTruc = false
    #set start and finish numbers
    if totalPages > maxPagesToDisplay
      distanceToSpill = (maxPagesToDisplay-1) / 2
      if activePage <= distanceToSpill
        startPage = 1
        endPage = maxPagesToDisplay - 1
        endTruc = true
      else if (totalPages - activePage) < distanceToSpill
        startPage = totalPages - maxPagesToDisplay + 2
        endPage = totalPages
        startTruc = true
      else
        startPage = activePage - distanceToSpill + 1
        endPage = activePage + distanceToSpill - 1
        startTruc = true
        endTruc = true
    else
      startPage = 1
      endPage = totalPages

    #generate page list
    pageList = for pageNumber in [startPage..endPage]
      page: pageNumber
      active: activePage == pageNumber
      ellipses: false

    if startTruc
      pageList.unshift
        ellipses: true
    if endTruc
      pageList.push
        ellipses: true
    pageList

  ).property("pagesObject.activePage", "pagesObject.totalPages", "maxPagesToDisplay")