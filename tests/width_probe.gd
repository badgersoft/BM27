extends RefCounted
## Lists the deepest controls whose minimum width exceeds a limit.
static func probe(root: Node, limit: float) -> Array:
	var out: Array = []
	_walk(root, limit, out)
	return out

static func _walk(n: Node, limit: float, out: Array) -> void:
	var any_child := false
	for c in n.get_children():
		if c is Control and c.get_combined_minimum_size().x > limit:
			any_child = true
			_walk(c, limit, out)
	if not any_child and n is Control:
		var t := ""
		if n is Label:
			t = (n as Label).text.substr(0, 40)
		elif n is Button:
			t = (n as Button).text.substr(0, 40)
		out.append("%s %s min=%d '%s'" % [n.get_class(), n.name, int(n.get_combined_minimum_size().x), t])
