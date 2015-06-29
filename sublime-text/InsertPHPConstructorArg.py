import sublime, sublime_plugin


def find_class_opening_bracket(view):
	pos = view.find(r'class\s+[0-9A-Za-z_]+', 0)
	pos = view.find(r'\{', pos.b).b

	return pos


class InsertPHPConstructorArg(sublime_plugin.TextCommand):
	'''
	Inserts a constructor argument.
	'''

	placeholder = 'PROPERTY'

	def name(self):
		return 'insert_php_constructor_arg'

	def description(self):
		return 'Insert a constructor argument.'

	def run(self, edit):
		self.edit = edit
		self.regions = []

		self.add_property(self.placeholder)
		self.add_constructor(self.placeholder)

		# make a multiselect for all the variable names
		self.view.sel().clear()
		self.view.sel().add_all(self.regions)

	def add_property(self, prop_name):
		# add the property first
		text = prop_name + ";"
		properties = self.view.find_all(r'(public|protected|private)\s+\$[A-Za-z_]+;')

		# check if the class has existing properties. if not, we need an extra
		# newline to separate the property from any existing methods
		if properties:
			pos = properties[-1].b
		else:
			pos = find_class_opening_bracket(self.view)
			text += "\n"

		pos += self.view_insert(pos, "\n\tprivate $")
		self.view_insert(pos, text)

		cursor_start = pos
		cursor_end = cursor_start + len(prop_name)
		self.add_region(cursor_start, cursor_end)

	def add_constructor(self, prop_name):
		constructor = self.view.find(r'__construct\s*\(', 0)

		if constructor:
			constructor_start = constructor.b
			constructor_end = self.view.find(r'\)', constructor_start).a
		# create the constructor if it does not exist
		else:
			text = "\n\tpublic function __construct()\n\t{\n\t}"
			properties = self.view.find_all(r'(public|protected|private)\s+\$[A-Za-z_]+;')

			# if the class has any properties, insert an extra newline and put
			# the constructor right after the last property
			if properties:
				pos = properties[-1].b
				text = "\n" + text
			# otherwise, find the opening { of the class and put it there
			else:
				pos = find_class_opening_bracket(self.view)

			self.view_insert(pos, text)

			# easier than calculating the positions
			constructor = self.view.find(r'__construct\s*\(\)', 0)
			constructor_start = constructor_end = constructor.b - 1

		constructor_args = self.view.substr(sublime.Region(constructor_start, constructor_end))
		arg_pos = constructor_end
		text = "$" + prop_name

		# rudimentary check for multiline constructor args
		if "\n" in constructor_args:
			arg_pos = self.view.find_by_class(constructor_end, False, sublime.CLASS_LINE_END)

			# append a comma if there are any other arguments
			if constructor_args.strip() != '':
				arg_pos += self.view_insert(arg_pos, ",")

			# insert a newline and indent before inserting the argument
			arg_pos += self.view_insert(arg_pos, "\n\t\t")
			cursor_start = arg_pos + 1
		else:
			# when substitution is done, cursor will be past the point where the
			# closing parenthesis of the constructor currently is
			cursor_start = constructor_end + 1

			# prepend a comma if there are any other arguments
			if constructor_args.strip() != '':
				print(repr(constructor_args))
				text = ", " + text
				cursor_start += 2

		# insert and add selection for the constructor argument name
		self.view_insert(arg_pos, text)
		cursor_end = cursor_start + len(prop_name)
		self.add_region(cursor_start, cursor_end)

		# add the line of code that sets the property
		constructor_close = self.view.find(r'\}', constructor_end).a
		last_newline = self.view.find_by_class(constructor_close, False, sublime.CLASS_LINE_START)
		cursor_start = last_newline + self.view_insert(last_newline, "\t\t$this->")
		self.view_insert(cursor_start, prop_name+' = $'+prop_name+";\n")

		# add selection for the property name
		cursor_end = cursor_start + len(prop_name)
		self.add_region(cursor_start, cursor_end)

		# add selection for the variable name
		cursor_start = cursor_end + 4
		cursor_end = cursor_start + len(prop_name)
		self.add_region(cursor_start, cursor_end)

	def add_region(self, start, end):
		self.regions.append(sublime.Region(start, end))

	def view_insert(self, pos, text):
		return self.view.insert(self.edit, pos, text)
