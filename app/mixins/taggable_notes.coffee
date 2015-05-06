`import Ember from 'ember'`

mixin = Ember.Mixin.create

  tagRegex: /(?!<a[^>]*?>)(\B#\w\w+)(?![^<]*?<\/a>)/gim                 # Replace content with tagged content if untransformed tag text exists
  finishedTagRegex: /(?!<[^>]+>)(\B#\w\w+)(\W+|\&nbsp;)<[^>]+>/im       # Escape <a> if the user enters anything but word characters after the tag
  brokenTagRegex: /(<a[^>]*?>(\B#\w+))((\W{1}|\&nbsp;{1})\w+)<\/a>/im   # Put <a> back at beginning of tag
  joinedTagRegex: /(<a[^>]*?>(\B#\w\w+))<\/a>(\w+)/im                   # Put <a> at the end of current tag and joined text
  invalidTagRegex: /<a[^>]*?>(\B#\w{1}|\w.+|\B#\W{1}\w+)<\/a>/im       # Hash symbol removed, or #+ only 1 character or hash split off

  currentTagIndex: null

  hashtaggedContent: ->
    replaced = @get("value").replace(@invalidTagRegex, "$1")
    replaced = replaced.replace(@brokenTagRegex, "$1</a>$3")
    replaced = replaced.replace(@joinedTagRegex, "$1$3</a>")
    replaced = replaced.replace(@tagRegex, "<a class='hashtag current'>$1</a>")
    replaced = replaced.replace(@finishedTagRegex, "$1</a>$2")
    replaced

  currentTagText: (node) ->
    tagText = @get("textNodes")[node].textContent
    tagText = tagText.substring(1,tagText.length) # trim the #

  tagMatches: -> [@$().html().match(@tagRegex), @$().html().match(@finishedTagRegex), @$().html().match(@brokenTagRegex), @$().html().match(@joinedTagRegex), @$().html().match(@invalidTagRegex)]

  allTextNodes: (node) ->
    textNodes = []
    return textNodes if typeof(node.childNodes) is "undefined"
    if node.nodeType is 3
      textNodes.push node
    else
      return if typeof(node.childNodes) is "undefined"
      [].concat.apply([],node.childNodes).forEach (child) =>
        textNodes.push.apply textNodes, @allTextNodes(child)
    textNodes

  textNodes: Ember.computed( -> @allTextNodes(@$()[0]) ).property().volatile()

  setStart: (node, offset) ->
    sel   = window.getSelection()
    range = document.createRange()

    range.setStart(node, offset)
    range.collapse(false)
    sel.removeAllRanges()
    sel.addRange(range)

  updateTagging: ->
    unless Ember.isEmpty(@get("value"))

      # Hash tagging is done by adding <a> tags around matched content
      #
      # The html content is processed and a few things can happen
      # - A tag being created is matched (@tagRegex) and wrapped
      # - A finished tag is matched (@finishedTagRegex) and the <a> is escaped
      # - An existing tag is "broken" and the <a> removed and reprocessed
      # - An existing tag becomes invalid and <a> is removed
      # - An existing tag is joined with adjacent text
      #
      # Then HTML is updated and the cursor position set only when the above events happen
      # this prevents needing to track cursor position in HTML soup

      matches = @tagMatches()
      # test string.... #bla freak #la dee #daa ergle #bla
      if matches[0] and matches[0].length > 1
        @$().html(@hashtaggedContent()) # pasted content, only new matches and don't bother with cursor position

      else if matches.compact().length is 1 and not @get("isPlaceheld")
        [new_match, finished_match, broken_match, joined_match, invalid_match] = matches

        match = new_match[0] if new_match
        match ||= finished_match[1] if finished_match
        match ||= broken_match[2] if broken_match
        match ||= joined_match[2] if joined_match
        match ||= invalid_match[1] if invalid_match

        currentTagNode = 0

        if invalid_match or (new_match and match.length > 3) or joined_match
          @get("textNodes").forEach (node, index) -> currentTagNode = index if match is node.textContent

        @$().html(@hashtaggedContent()) # Content replaced

        # Find the current node based on match
        unless currentTagNode
          @get("textNodes").forEach (node, index) -> currentTagNode = index if match is node.textContent

        [node,offset] = [@get("textNodes")[currentTagNode],1]

        if new_match # do tag search
          $(".note-tag-search").select2("search", @currentTagText(currentTagNode))
          @setStart(@get("textNodes")[currentTagNode], @get("textNodes")[currentTagNode].length)

        if finished_match # clear "current" class from most recent tag and close suggestions
          @$(".hashtag").removeClass("current")
          $(".note-tag-search").select2("close")

        # Now set cursor
        if new_match and match.length is 3
          offset = node.length
        else if finished_match or broken_match
          node = @get("textNodes")[currentTagNode+1]
        else if joined_match
          offset = match.length
        else if invalid_match
          node = @get("textNodes")[currentTagNode-1]
          offset = match.length+1

        @setStart(node, offset)

  # Event helpers
  textAdded: ->
    @set "value", @$().html().replace(/(\r\n|\n|\r)/gm,"")
    @updateTagging()
    @set "value", @$().html().replace(/<font\ssize="\d+">(.*?)<\/font>/gm,"$1")
    @$('font').contents().unwrap()

    @get("controller").set("notes", @$().text())

  keyDown:    (event) ->
    # Prevent enter, and up/down arrows while hashtagging
    event.preventDefault() if [13,38,40].contains(event.keyCode) and @$(".hashtag.current").length

  keyUp:    (event) ->
    switch event.keyCode
      when 27 # keyboard: escape
        @get("controller").set("modalOpen", false)
      when 13 # keyboard: enter
        if @$(".hashtag.current").length
          $("input.note-tag-search").select2("selectHighlighted")
          event.preventDefault()
      when 38 # keyboard: up arrow
        if @$(".hashtag.current").length
          $("input.note-tag-search").select2("moveHighlight", -1)
          event.preventDefault()
      when 40 # keyboard: down arrow
        if @$(".hashtag.current").length
          $("input.note-tag-search").select2("moveHighlight", 1)
          event.preventDefault()

      else
        @textAdded()


`export default mixin`
