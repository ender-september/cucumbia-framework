class ElementRegistry
  def initialize(element_path_file)
    @el_path = element_path_file
  end

  def element_path_file_hashmap

    # Change/replace content of elements_file before loading it
    # file_content = File.read(@el_path)
    # new_contents = file_content.gsub(/replace this/, 'with this')
    # File.open(@el_path, 'w') { |file| file.puts new_contents }

    # load property file for elements path
    YAML.load_file @el_path
  end

  private

  attr_accessor :app_context
  attr_accessor :el_path
end
