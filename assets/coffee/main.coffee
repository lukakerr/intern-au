JS = {}

$(document).ready ->
  toInit = []
  # Find all elements with data-init=
  $("[data-init]").each ->
    # Add data-init value to toInit
    toInit = toInit.concat $(@).data("init").split(/,[\s]*/)

  # Find and initialize method for all methods in toInit
  for method, i in toInit when toInit.indexOf method is i
    method = JS["init_#{method}"]?()