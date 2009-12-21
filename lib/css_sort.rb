require 'pathname'

def css_sort( filename )
  css_file = Pathname.new(filename)

  act = {}

  css_file.each_line do |line|
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

  act
end
