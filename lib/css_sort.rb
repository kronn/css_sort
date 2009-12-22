require 'pathname'

class CssSort
  # attr :filename, :abstract_css_tree, :groups, :css_string

  GROUPS = {
    :layout => [:position, :top, :right, :bottom, :left, :float, :display],
    :color  => [:color, :background, :border],
    :typography => [:"font-size", :"font-family", :align],
    :positioning => [:margin, :padding]
  }

  def initialize( filename )
    @css_file = Pathname.new(filename)
    @abstract_css_tree = {}
    @groups = {}
    @css_string = ""
  end

  def analyze
    act = {}

    @css_file.each_line do |line|
      selectors, rules = line.gsub('}', '').split('{')

      selectors.split(',').each do |selector|
        selector.strip!
        next if selector.length == 0

        act[selector.to_sym] ||= []
        rules.split(';').each do |rule|
          rule.strip!
          act[selector.to_sym] << rule
        end
      end
    end

    @abstract_css_tree = act
  end

  def group
    [:layout, :color, :typography, :positioning, :other].collect do |group_key|
      @groups[group_key] = {}
    end

    @abstract_css_tree.each do |selector, rules|
      rules.flatten.compact.each do |rule|
        next unless rule.include?(':')
        key, value = rule.split(':')

        GROUPS.each do |gr_key, gr_values|
          @groups[gr_key][selector] ||= []
          @groups[:other][selector] ||= []

          if gr_values.include?(key.strip.to_sym)
            @groups[gr_key][selector] << rule
          else
            @groups[:other][selector] << rule
          end
        end
      end
    end

    @groups
  end

  def combine
    @groups.each do |key, values|
      @css_string << "\n/* {{{ #{key} */\n"
      values.each do |selector, rules|
        @css_string << "#{selector} { #{rules.join('; ')}  }\n"
      end
      @css_string << "/* }}} */\n\n"
    end

    @css_string
  end
end

def css_sort( filename )
  sorter = CssSort.new( filename )
  sorter.analyze
  sorter.group
  sorter.combine
end
