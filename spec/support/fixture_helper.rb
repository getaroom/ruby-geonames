module FixtureHelper
  def fixture_content(fixture_path)
    content = File.read(fixture_path, encoding: 'UTF-8')
    # Extract XML content after the first blank line (removes HTTP headers)
    lines = content.split("\n")
    xml_start_line = lines.find_index { |line| line.strip.empty? }
    if xml_start_line
      lines[(xml_start_line + 1)..-1].join("\n")
    else
      content
    end
  end
end
