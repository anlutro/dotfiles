# SYNTAX TEST "Packages/User/syntaxes/YAML-Mako.sublime-syntax"

foo_${var}: bar
# ^^ text.yaml_mako source.yaml entity.tag.yaml
#   ^^ text.yaml_mako source.mako control.punctuation.mako
#     ^^^ text.yaml_mako source.mako meta.embedded.inline.python source.python
#        ^ text.yaml_mako source.mako control.punctuation.mako
#         ^ text.yaml_mako source.yaml punctuation.seperator.key-value.yaml
#           ^ text.yaml_mako source.yaml string.unquoted.yaml

foo: foo_${bar}_baz
# ^ text.yaml_mako source.yaml entity.tag.yaml
#  ^ text.yaml_mako source.yaml punctuation.seperator.key-value.yaml
#    ^^^^ text.yaml_mako source.yaml string.unquoted.yaml
#        ^^ text.yaml_mako source.mako control.punctuation.mako
#          ^^^ text.yaml_mako source.mako meta.embedded.inline.python source.python
#             ^ text.yaml_mako source.mako control.punctuation.mako
#              ^^^^ text.yaml_mako source.yaml string.unquoted.yaml
