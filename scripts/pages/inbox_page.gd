extends Page
## Messages and history.


func build() -> void:
	title("Inbox", "Everything that's happened, newest first.", "mail")
	if Game.inbox.is_empty():
		add_child(UI.label("Nothing yet.", "BodyMuted"))
	var c: Array = UI.card("", "", "Card")
	var list: VBoxContainer = c[1]
	for msg in Game.inbox.slice(0, 80):
		var h := UI.hbox(14)
		var col := UI.kind_color(msg.get("kind", "info"))
		var ic := Icons.make(msg.icon, 22, col)
		ic.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		h.add_child(ic)
		var v := UI.vbox(2)
		v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		v.add_child(UI.label(msg.title, "Strong"))
		v.add_child(UI.label(msg.body, "BodyMuted", null, true))
		h.add_child(v)
		var d := UI.label(U.date_label(int(msg.week)), "Small")
		d.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		h.add_child(d)
		list.add_child(h)
		list.add_child(UI.sep())
	add_child(c[0])
