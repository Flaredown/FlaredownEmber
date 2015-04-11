`import Ember from 'ember'`

view = Ember.View.extend

  tagName: "div"
  templateName: "questioner/note-textarea"
  classNames: ["checkin-note-textarea"]

  tagRegex: /(?!<a[^>]*?>)(\B#\w\w+)(?![^<]*?<\/a>)/gim                 # Replace content with tagged content if untransformed tag text exists
  finishedTagRegex: /(?!<[^>]+>)(\B#\w\w+)(\W+|\&nbsp;)<[^>]+>/im       # Escape <a> if the user enters anything but word characters after the tag
  brokenTagRegex: /(<a[^>]*?>(\B#\w+))((\W{1}|\&nbsp;{1})\w+)<\/a>/im   # Put <a> back at beginning of tag
  joinedTagRegex: /(<a[^>]*?>(\B#\w\w+))<\/a>(\w+)/im                   # Put <a> at the end of current tag and joined text
  invalidTagRegex: /<a[^>]*?>(\B#\w{1}|\w.+|\B#\W{1}\w+)<\/a>/im       # Hash symbol removed, or #+ only 1 character or hash split off

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

  # Placeholder
  placeholder: "<span class='placeholder'>Use <span class='hashtag'>#hashtags</span> to mark triggers on the graph</span>"
  isPlaceheld: Ember.computed(-> @$().text() is "Use #hashtags to mark triggers on the graph").property().volatile()
  setPlaceholder: -> @$().html(@placeholder) if Ember.isEmpty(@$().text())

  hashtaggedContent: ->
    replaced = @get("value").replace(@invalidTagRegex, "$1")
    replaced = replaced.replace(@brokenTagRegex, "$1</a>$3")
    replaced = replaced.replace(@joinedTagRegex, "$1$3</a>")
    replaced = replaced.replace(@tagRegex, "<a class='hashtag'>$1</a>")
    replaced = replaced.replace(@finishedTagRegex, "$1</a>$2")
    replaced

  currentTag: Ember.computed( ->
    if @get("currentTagIndex")
      tagText = @get("textNodes")[@get("currentTagIndex")].textContent
      @set("currentTag", tagText.substring(1,tagText.length)) # trim the #
  ).property()

  tagMatches: -> [@$().html().match(@tagRegex), @$().html().match(@finishedTagRegex), @$().html().match(@brokenTagRegex), @$().html().match(@joinedTagRegex), @$().html().match(@invalidTagRegex)]

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

  # Event helpers
  textAdded: ->
    @set "value", @$().html().replace(/(\r\n|\n|\r)/gm,"")
    @updateTagging()
    @set "value", @$().html().replace(/<font\ssize="\d+">(.*?)<\/font>/gm,"$1")
    @$('font').contents().unwrap()

  didInsertElement: ->
    @set "value", @get("controller.notes")
    @$().html(@get("value"))
    @textAdded()
    @setPlaceholder()

    @$().on("paste", @paste.bind(@))
    Ember.run.next => @$().focus() unless @get("isPlaceheld")

  # Only on modal close instead
  # willDestroyElement: ->
    # @set "value", @get("controller.notes")
    # @get("controller").send("save")

  focusIn: -> @$().text("") if @get("isPlaceheld")

  paste: (event) ->
    event.preventDefault()
    text = event.originalEvent.clipboardData.getData("text")
    document.execCommand('insertText', false, text)
    @textAdded()

  keyUp:    (event) ->
    if event.keyCode is 27 # keyboard: escape
      @get("controller").set("modalOpen", false)
    else
      @textAdded()

`export default view`