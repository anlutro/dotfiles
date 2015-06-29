import sublime, sublime_plugin


def find_class_opening_bracket(view):
	pos = view.find(r'class\s+[0-9A-Za-z_]+', 1)
	pos = view.find(r'\{', pos.b).b
	return pos


class InsertPHPConstructorArg(sublime_plugin.TextCommand):
	'''
	Inserts a constructor argument.
	'''
	def name(self):
		return 'insert_php_constructor_arg'

	def run(self, edit):
		regions = []
		view = sublime.active_window().active_view()
		prop_name = 'PROPERTY'

		# add the property first
		text = prop_name + ";"
		properties = view.find_all(r'(public|protected|private)\s+\$[A-Za-z_]+;')

		# check if the class has existing properties. if not, we need an extra
		# newline to separate the property from any existing methods
		if properties:
			pos = properties[-1].b
		else:
			pos = find_class_opening_bracket(view)
			text += "\n"

		pos += view.insert(edit, pos, "\n\tprivate $")
		view.insert(edit, pos, text)

		cursor_start = pos
		cursor_end = cursor_start + len(prop_name)
		regions.append(sublime.Region(cursor_start, cursor_end))

		# find or create a constructor
		constructor = view.find(r'__construct\s*\(', 0)

		if constructor:
			constructor_start = constructor.b
			constructor_end = view.find(r'\)', constructor_start).a
		else:
			text = "\n\tpublic function __construct()\n\t{\n\t}"
			properties = view.find_all(r'(public|protected|private)\s+\$[A-Za-z_]+;')
			if properties:
				pos = properties[-1].b
				text = "\n" + text
			else:
				pos = find_class_opening_bracket(view)

			view.insert(edit, pos, text)
			constructor = view.find(r'__construct\s*\(\)', 0)
			constructor_start = constructor.b - 2
			constructor_end = constructor.b - 1

		constructor_args = view.substr(sublime.Region(constructor_start + 1, constructor_end))

		# add the constructor argument
		pos = constructor_end

		# rudimentary check for multiline constructor args
		if view.substr(pos - 1) in (' ', '\t', '\n'):
			pos = view.find_by_class(constructor_end, False, sublime.CLASS_LINE_END)
			cursor_start = pos + 4
			text = "\n\t\t$" + prop_name
			# don't append a comma if there are no other arguments
			if constructor_args.strip() != '':
				text = "," + text
				cursor_start += 1
		else:
			cursor_start = constructor_end + 1
			text = "$" + prop_name
			# don't append a comma if there are no other arguments
			if constructor_args.strip() != '':
				text = ", " + text
				cursor_start += 2

		view.insert(edit, pos, text)
		cursor_end = cursor_start + len(prop_name)
		regions.append(sublime.Region(cursor_start, cursor_end))

		# add the line of code that sets the property
		constructor_close = view.find(r'\}', constructor_end).a
		last_newline = view.find_by_class(constructor_close, False, sublime.CLASS_LINE_START)
		cursor_start = last_newline + view.insert(edit, last_newline, "\t\t$this->")
		ins = view.insert(edit, cursor_start, prop_name+' = $'+prop_name+";\n")

		cursor_end = cursor_start + len(prop_name)
		regions.append(sublime.Region(cursor_start, cursor_end))

		cursor_start = cursor_end + 4
		cursor_end = cursor_start + len(prop_name)
		regions.append(sublime.Region(cursor_start, cursor_end))

		# make a multiselect for all the variable names
		view.sel().clear()
		view.sel().add_all(regions)
