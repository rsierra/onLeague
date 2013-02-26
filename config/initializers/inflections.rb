# encoding: utf-8

# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format
# (all these examples are active by default):
# ActiveSupport::Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end
#
# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections do |inflect|
#   inflect.acronym 'RESTful'
# end

ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'proveedor OAuth', 'proveedores OAuth'
  inflect.irregular 'jugador', 'jugadores'
  inflect.irregular 'gol', 'goles'
  inflect.irregular 'alineación', 'alineaciones'
  inflect.irregular 'tarjeta', 'tarjetas'
  inflect.irregular 'centrocampista', 'centrocampistas'
end