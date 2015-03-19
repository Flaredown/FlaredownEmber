`import Ember from 'ember'`

view = Ember.View.extend

  tagName: "div"
  templateName: "questioner/note-textarea"
  classNames: ["checkin-note-textarea"]

  tagRegex: /(?!<a[^>]*?>)(\B#\w\w+)(?![^<]*?<\/a>)/im
  finishedTagRegex: /(?!<[^>]+>)(#\w\w+)(\W+|\&nbsp;)<[^>]+>/im

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
    replaced = @get("value").replace(@finishedTagRegex, "$1</a>$2")
    replaced = replaced.replace(@tagRegex, "<a class='hashtag'>$1</a>")
    replaced
  ).property("value")

  setPlaceholder: -> @$().html(@placeholder) if Ember.isEmpty(@$().text())
  currentTag: Ember.computed( ->
    if @get("currentTagIndex")
      tagText = @get("textNodes")[@get("currentTagIndex")].textContent
      @set("currentTag", tagText.substring(1,tagText.length)) # trim the #
  ).property()

  tagSearchWatcher: Ember.observer ->
    if @get("currentTag") and @get("currentTagIndex")

      tagText = @get("textNodes")[@get("currentTagIndex")].textContent
      tagText = tagText.substring(1,tagText.length) # trim the #


      $("#note-tag-search").select2("search", tagText)
      @setStart(@get("textNodes")[@get("currentTagIndex")], @get("textNodes")[@get("currentTagIndex")].length)
    else
      $("#note-tag-search").select2("close")
  .observes("currentTag")

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

  setContent: Ember.observer(->
    unless Ember.isEmpty(@get("value"))
      console.log "?!?!?!"

      # @tagSearchWatcher()
      @notifyPropertyChange("currentTag")

      # Hash tagging is done by adding <a> tags around matched content
      #
      # The raw content is processed and 2 things can happen
      # 1. A tag being created is matched (@tagRegex)
      # 2. A finished tag is matched (@finishedTagRegex)
      #
      # Then HTML is updated and the cursor position set only when the above events happen
      # this prevents needing to track cursor position in HTML soup

      # Replace content with tagged content if untransformed tag text exists
      match = @$().html().match(@tagRegex)
      if match
        # Content replaced
        @$().html(@get("hashtaggedContent"))

        # Now set cursor
        nodes           = @get("textNodes")
        currentTagNode  = 0

        nodes.forEach (node, index) ->
          currentTagNode = index if match[0] is node.textContent

        if currentTagNode
          @set("currentTagIndex",currentTagNode)
          # tagText = @allTextNodes(@$()[0])[currentTagNode].textContent
          # @set("currentTag", tagText.substring(1,tagText.length)) # trim the #

        else
          @set("currentTagIndex",false)

      # Escape <a> if the user enters anything but word characters after the tag
      match = @$().html().match(@finishedTagRegex)
      if match

        # @set("currentTagIndex",false)

        # Content replaced
        @$().html(@get("hashtaggedContent"))

        # Now set cursor
        nodes           = @get("textNodes")
        currentTagNode  = 0

        nodes.forEach (node, index) ->
          currentTagNode = index if match[1] is node.textContent


        @setStart(nodes[currentTagNode+1], 1)
        # @set("currentTagIndex",currentTagNode)



      @get("controller").set("notes", @$().text())

  ).observes("value")

  didInsertElement: ->
    @set "value", @get("controller.notes")
    @setPlaceholder()
    @setContent()
    Ember.run.next => @$().focus() unless @get("isPlaceheld")

  # Only on modal close instead
  # willDestroyElement: ->
  #   @get("controller").send("save")

  # focusOut:         ->
  focusIn:          -> @$().text("") if @get("isPlaceheld")
  # keyDown:  (event) ->
  keyUp:    (event) ->
    if event.keyCode is 27
      @get("controller").set("modalOpen", false)  # keyboard: escape
    else
      @set "value", @$().html()#.replace(/(\r\n|\n|\r)/gm,"")

`export default view`