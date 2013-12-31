#= require items_show
#= require reminder_panel
# require "dino.js"

#= require masonry/jquery.masonry
#= require masonry/jquery.event-drag
#= require masonry/jquery.imagesloaded.min
#= require masonry/jquery.infinitescroll.min
#= require masonry/modernizr-transitions

$ ->
  #load items content for each item
  $('.item-bloc[data-local-uri]').each (id, element) ->
    localUri = $(element).attr('data-local-uri')
    downloadNewsDatas(localUri)

  setInterval(getNewNews,30000)
  setInterval(updateLayout,1000)


  $container = $('#masonry-container');

  $container.masonry
    itemSelector: '.item-bloc',
    gutterWidth: 20,
    columnWidth: 40,
    isFitWidth: true,

  setTimeout ( ->
    #infinite scroll managment
    $container.infinitescroll
      navSelector: "#page-nav" # selector for the paged navigation
      nextSelector: "#page-nav a:first" # selector for the NEXT link (to page 2)
      itemSelector: ".item-bloc" # selector for all items you'll retrieve
      prefill: true #load other pages if too big window
      loading:
        finishedMsg: "No more pages to load."
        img: "http://i.imgur.com/6RMhx.gif"

      # trigger Masonry as a callback
      (newElements,opts) ->
        # hide new items while they are loading
        $newElements = $(newElements).css(opacity: 0)
        nextPath=opts.path[0]+opts.state.currPage
        $.getScript nextPath
  ),3000

(exports ? this).updateLayout = () ->
  $('#masonry-container').masonry('reload')
  Arrow_Points()

#functions declaration
(exports ? this).getNewNews = () ->
  lastNews = $('.items-box').children(".item-bloc").first()
  lastNewsDate = lastNews.attr("data-pub-date")

  searchId = getCurSearch().attr("id").substr(5)
  uri = "/search/"+searchId+"/getNewsNumber/"+lastNewsDate

  $.ajax
    url: uri
    async: true
    context: uri
    timeout: 5000
    success: (data) ->
      if data != "0"
        $(".numberOfNewNews").html(data)
        $(".newNewsLinkBox").show()
    error: ->
      console.log("error in fetching new news")

(exports ? this).downloadNewsDatas = (uri,item=null) ->
  $.ajax uri,
    async: true
    context: uri
    success: (data) ->
      if item == null
        item = $('.item-bloc[data-local-uri="'+uri+'"]')
      if(item.length > 0)
        $(item).removeAttr("data-local-uri")
        $(item).find('[class*=item_wait]').detach()
        $(item).find('[class=item_container]').append(data)
        setHighlightTags($(item))
        $('#masonry-container').masonry('reload');

    error: (xhr, ajaxOptions, thrownError) ->
      if (xhr.status == 500)
        downloadNewsDatas(uri,item)

(exports ? this).setHighlightTags = (item) ->
  curSearch = getCurSearch()

  #we get all the filters
  filtersSearch = new Array();
  curSearch.find("#summaryOr,#summaryAnd").children().each (id,fi) ->
    val = $(fi).attr("filter-uri")
    if(val == "undefined")
      val = $(fi).attr("filter-value")
    filtersSearch.push(val)

  #we check filters in the news
  $(item).find(".label-tag").each (id,filterItem) ->
    filterval = $(filterItem).attr("filter-uri")
    if(filterval == undefined)
      filterval = $(filterItem).attr("filter-value")
    if ($.inArray(filterval,filtersSearch) != -1)
      $(filterItem).addClass("label-selected")

Arrow_Points = ->
  if (getPageFormat() != "time")
    return
  s = $("#masonry-container").find(".item-bloc")
  s.each (i, obj) ->
    posLeft = $(obj).css("left")

    date = $(obj).attr("data-pub-date-string")
    $(obj).find(".arrowAcronym").remove()

    acronym = "<acronym class='arrowAcronym' title="+date+" style='border-bottom:dotted 1px black; cursor:help;'>"
    if posLeft is  "5px"
      html = acronym+"<span class='rightCorner'></span></acronym>"
      $(obj).prepend html
    else
      html = acronym+"<span class='leftCorner'></span></acronym>"
      $(obj).prepend html


(exports ? this).getCurSearch = () ->
  return $($(".searchItem.active").attr("data-content"))

(exports ? this).getPageFormat =->
  idSelected = $(".btn-format.active").attr("id")
  switch idSelected
    when "btnFormatTime" then return "time"
    when "btnFormatCard" then return "card"
    when "btnFormatList" then return "list"
