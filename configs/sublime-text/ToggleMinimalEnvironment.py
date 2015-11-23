import sublime, sublime_plugin

class ToggleMinimalEnvironment(sublime_plugin.WindowCommand):
	def run(self):
		self.window.run_command("toggle_side_bar")
		self.window.run_command("toggle_tabs")
		self.window.run_command("toggle_status_bar")
