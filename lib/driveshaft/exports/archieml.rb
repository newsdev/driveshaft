require 'archieml'
require 'nokogiri'

module Driveshaft
  module Exports

    def self.archieml(file, drive_service)
      data = {}

      file_html = drive_service.export_file(file.id, 'text/html')
      html_doc  = Nokogiri::HTML(file_html)

      text = Driveshaft::Exports::Archieml.convert_node(html_doc.children[1].children[1])
      text.gsub!(/<[^<>]*>/) do |match|
        match.gsub(/‘|’/, "'")
             .gsub(/“|”/, '"')
      end
      data = ::Archieml.load(text)

      return {
        body: JSON.dump(data),
        content_type: 'application/json; charset=utf-8'
      }
    end

    module Archieml

      NODE_TYPES = {
        'text' => lambda { |node|
          return node.content
        },
        'span' => lambda { |node|
          convert_node(node)
        },
        'p' => lambda { |node|
          return convert_node(node) + "\n"
        },
        'a' => lambda { |node|
          return convert_node(node) unless node.attributes['href'] && node.attributes['href'].value

          href = node.attributes['href'].value
          if !href.index('?').nil? && parsed_url = CGI.parse(href.split('?')[1])
            href = parsed_url['q'][0] if parsed_url['q']
          end

          str = "<a href=\"#{href}\">"
          str += convert_node(node)
          str += "</a>"
          return str
        },
        'li' => lambda { |node|
          return '* ' + convert_node(node) + "\n"
        }
      }

      %w(ul ol).each { |tag| NODE_TYPES[tag] = NODE_TYPES['span'] }
      %w(h1 h2 h3 h4 h5 h6 br hr).each { |tag| NODE_TYPES[tag] = NODE_TYPES['p'] }

      def self.convert_node(node)
        str = ''
        node.children.each do |child|
          if func = NODE_TYPES[child.name || child.type]
            str += func.call(child)
          end
        end
        return str
      end

    end
  end
end
