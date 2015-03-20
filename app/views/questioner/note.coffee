`import Ember from 'ember'`

view = Ember.View.extend

  tagName: "div"
  templateName: "questioner/note-textarea"
  classNames: ["checkin-note-textarea"]

  tagRegex: /(?!<a[^>]*?>)(\B#\w\w+)(?![^<]*?<\/a>)/im                # Replace content with tagged content if untransformed tag text exists
  finishedTagRegex: /(?!<[^>]+>)(\B#\w\w+)(\W+|\&nbsp;)<[^>]+>/im     # Escape <a> if the user enters anything but word characters after the tag
  brokenTagRegex: /(<a[^>]*?>(\B#\w+))((\W{1}|\&nbsp;{1})\w+)<\/a>/im # Put <a> back at beginning of tag
  joinedTagRegex: /(<a[^>]*?>(\B#\w\w+))<\/a>(\w+)/im                 # Put <a> at the end of current tag and joined text
  invalidTagRegex: /<a[^>]*?>(\B#\w{1}|\w.+|\B#\W{1}\w+)<\/a>/im      # Hash symbol removed, or #+ only 1 character or hash split off

  currentTagIndex: null

  # Variables:
  editable: true

  contenteditable: (->
    editable = @get("editable")
    (if editable then "true" else `undefined`)
  ).property("editable")

  spellcheck: true
  role: "textbox"
  "aria-multiline": true

  attributeBindings: ["contenteditable", "spellcheck", "role", "aria-multiline"]

  placeholder: "<span class='placeholder'>Use <span class='hashtag'>#hashtags</span> to mark triggers on the graph</span>"
  isPlaceheld: Ember.computed(-> @$().text() is "Use #hashtags to mark triggers on the graph").property().volatile()

  hashtaggedContent: Ember.computed(->
    replaced = @get("value").replace(@invalidTagRegex, "$1")
    replaced = replaced.replace(@brokenTagRegex, "$1</a>$3")
    replaced = replaced.replace(@joinedTagRegex, "$1$3</a>")
    replaced = replaced.replace(@finishedTagRegex, "$1</a>$2")
    replaced = replaced.replace(@tagRegex, "<a class='hashtag'>$1</a>")
    replaced
  ).property("value")

  setPlaceholder: -> @$().html(@placeholder) if Ember.isEmpty(@$().text())
  currentTag: Ember.computed( ->
    if @get("currentTagIndex")
      tagText = @get("textNodes")[@get("currentTagIndex")].textContent
      @set("currentTag", tagText.substring(1,tagText.length)) # trim the #
  ).property()

  # tagSearchWatcher: Ember.observer ->
  #   if @get("currentTag") and @get("currentTagIndex")
  #
  #     tagText = @get("textNodes")[@get("currentTagIndex")].textContent
  #     tagText = tagText.substring(1,tagText.length) # trim the #
  #
  #     $(".note-tag-search").select2("search", tagText)
  #     @setStart(@get("textNodes")[@get("currentTagIndex")], @get("textNodes")[@get("currentTagIndex")].length)
  #   else
  #     $(".note-tag-search").select2("close")
  # .observes("currentTag")

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

      new_match       = @$().html().match(@tagRegex)
      finished_match  = @$().html().match(@finishedTagRegex)
      broken_match    = @$().html().match(@brokenTagRegex)
      joined_match    = @$().html().match(@joinedTagRegex)
      invalid_match   = @$().html().match(@invalidTagRegex)

      if new_match or finished_match or broken_match or invalid_match or joined_match
        match = new_match[0] if new_match
        match ||= finished_match[1] if finished_match
        match ||= broken_match[2] if broken_match
        match ||= joined_match[2] if joined_match
        match ||= invalid_match[1] if invalid_match

        currentTagNode = 0

        if invalid_match or (new_match and match.length > 3)
          @get("textNodes").forEach (node, index) -> currentTagNode = index if match is node.textContent

        # Content replaced
        @$().html(@get("hashtaggedContent"))

        # Find the current node based on match
        unless currentTagNode
          @get("textNodes").forEach (node, index) -> currentTagNode = index if match is node.textContent

        # Now set cursor
        [node,offset] = [@get("textNodes")[currentTagNode],1]

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

      @get("controller").set("notes", @$().text())

  didInsertElement: ->
    @set "value", @get("controller.notes")
    @setPlaceholder()
    @updateTagging()
    Ember.run.next => @$().focus() unless @get("isPlaceheld")

  # Only on modal close instead
  # willDestroyElement: ->
  #   @get("controller").send("save")

  # focusOut:         ->
  focusIn:          -> @$().text("") if @get("isPlaceheld")
  # keyDown:  (event) ->
  keyUp:    (event) ->
    if event.keyCode is 27 # keyboard: escape
      @get("controller").set("modalOpen", false)
    else
      @set "value", @$().html().replace(/(\r\n|\n|\r)/gm,"")
      @updateTagging()

`export default view`