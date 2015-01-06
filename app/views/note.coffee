`import Ember from 'ember'`

view = Ember.View.extend

  tagName: "div"
  templateName: "questioner/note-textarea"
  classNames: ["checkin-note-textarea"]

  tagRegex: /(?!<a[^>]*?>)(\B#\w\w+)(?![^<]*?<\/a>)/im
  finishedTagRegex: /(?!<[^>]+>)(#\w\w+)(\W+|\&nbsp;)<[^>]+>/im

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
  isPlaceheld: Ember.computed(-> @$().text() is "Use #hashtags to mark triggers on the graph").property()

  hashtaggedContent: Ember.computed(->
    replaced = @get("value").replace(@finishedTagRegex, "$1</a>$2")
    replaced = replaced.replace(@tagRegex, "<a class='hashtag'>$1</a>")
    replaced
  ).property("value")


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

  setStart: (node, offset) ->
    sel   = window.getSelection()
    range = document.createRange()

    range.setStart(node, offset)
    range.collapse(false)
    sel.removeAllRanges()
    sel.addRange(range)

  setPlaceholder: -> @$().html(@placeholder) if Ember.isEmpty(@$().text())
  setContent: Ember.observer(->
    unless Ember.isEmpty(@get("value"))

      # Replace content with tagged content if untransformed tag text exists
      match = @$().html().match(@tagRegex)
      if match
        @$().html(@get("hashtaggedContent"))
        nodes           = @allTextNodes(@$()[0])
        currentTagNode  = 0

        nodes.forEach (node, index) ->
          currentTagNode = index if match[0] is node.textContent
        @setStart(nodes[currentTagNode], nodes[currentTagNode].length)

      # Escape <a> if the user enters anything but word characters after the tag
      match = @$().html().match(@finishedTagRegex)
      if match
        @$().html(@get("hashtaggedContent"))
        nodes           = @allTextNodes(@$()[0])
        currentTagNode  = 0

        nodes.forEach (node, index) ->
          currentTagNode = index if match[1] is node.textContent
        @setStart(nodes[currentTagNode+1], 1)

      @get("controller").set("notes", @$().text())

  ).observes("value")

  didInsertElement: ->
    @set "value", @get("controller.notes")
    @setPlaceholder()
    @setContent()
    Ember.run.next => @$().focus() unless @get("isPlaceheld")

  willDestroyElement: ->
    @get("controller").send("save")

  # focusOut:         ->
  focusIn:          -> @$().text("") if @get("isPlaceheld")
  # keyDown:  (event) ->
  keyUp:    (event) ->
    if event.keyCode is 27
      @get("controller").set("modalOpen", false)  # keyboard: escape
    else
      @set "value", @$().html().replace(/(\r\n|\n|\r)/gm,"")

`export default view`