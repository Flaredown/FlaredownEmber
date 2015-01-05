`import Ember from 'ember'`

view = Ember.View.extend

  tagName: "div"
  templateName: "questioner/note-textarea"
  classNames: ["checkin-note-textarea"]

  tagRegex: /(?!<a[^>]*?>)(\B#\w\w+)(?![^<]*?<\/a>)/im
  finishedTagRegex: /(?!<[^>]+>)(#\w\w+)(\W+|\&nbsp;)<[^>]+>/im

  # Variables:
  editable: true
  isTyping: false

  contenteditable: (->
    editable = @get("editable")
    (if editable then "true" else `undefined`)
  ).property("editable")

  spellcheck: true
  role: "textbox"
  "aria-multiline": true


  attributeBindings: ["contenteditable", "spellcheck", "role", "aria-multiline"]

  placeholder: "<span class='placeholder'>Use <span class='hashtag'>#hashtags</span> to mark triggers on the graph</span>"

  # processValue: -> @setContent()  if not @get("isUserTyping") and @get("value")

  # contentObserver: Ember.observer(->
  #     placeholder = '<span class="placeholder">Use <span class="hashtag">#hashtags</span> to mark triggers on the graph</span>'
  #     content = if Ember.isEmpty(@get("value")) then placeholder else @get("value")
  #
  #     @$().html(Ember.Handlebars.Utils.escapeExpression(content))
  #   ).observes("value")

  # valueObserver: Ember.observer(->
  #   Ember.run.once => @processValue
  #   return
  # ).observes("value", "isUserTyping")
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

  setPlaceholder: -> @$().html(@placeholder) if Ember.isEmpty(@get("value")) and not @get("isTyping")
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
          console.log match[1], node.textContent
          currentTagNode = index if match[1] is node.textContent
        @setStart(nodes[currentTagNode+1], 1)

      # else
      #   el          = @$()[0]
      #   extent      = 0
      #   currentNode = 0

        # until extent >= @get("caretOffset") or extent > 1000
        #   extent = extent + @allTextNodes(@$()[0])[currentNode].length
        #   currentNode++
        #
        # offset = if currentNode > 1 then extent-@get("caretOffset") else extent
        #
        # if currentNode > 1
        #   node = sel.focusNode.childNodes[currentNode-1].childNodes[0]
        #   range.setStart(node, offset+node.length)
        # else
        #
        #   node = if el.textContent is sel.focusNode.textContent then el else sel.focusNode
        #   node = if Em.isPresent(node.childNodes) then node.childNodes[0] else node
        #   range.setStart(node, offset)


  ).observes("value")

  didInsertElement: ->
    @setPlaceholder()
    @setContent()

  focusOut:         ->
  focusIn:          ->
    @$().text("") if @$().text() is "Use #hashtags to mark triggers on the graph"
  keyDown:  (event) ->
  keyUp:    (event) ->
    debugger
    @set "value", @$().html().replace(/(\r\n|\n|\r)/gm,"")

`export default view`