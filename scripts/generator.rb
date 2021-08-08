require 'nokogiri'

class Generator
  def initialize(output_filename)
    @emoji_list = []
    @output_filename = output_filename
  end

  def generate
    build_emoji_list
    generate_enum_emoji
  end

  private def build_emoji_list
    File.open('html/emoji-list.html') do |f|
      doc = Nokogiri::HTML(f)
      parse(doc).each { |e| append_to_emoji_list(e) }
    end
    File.open('html/full-emoji-modifiers.html') do |f|
      doc = Nokogiri::HTML(f)
      parse(doc).each { |e| append_to_emoji_list(e) }
    end
  end

  private def parse(doc)
    doc.xpath("//tr/td[@class='code']/parent::tr").xpath("td[@class='code'] | td[@class='name'][1]").each_slice(2).map do |code_element, name_element|
      code_points = code_element.xpath("a/text()")[0].text.split.map { |code_point| code_point.delete_prefix('U+').to_i(16) }
      description = name_element.xpath('text()')[0].text
      { code_points: code_points, description: description }
    end
  end

  private def append_to_emoji_list(code_points:, description:)
    @emoji_list.append({
      code_points: code_points,
      description: description,
    })
  end

  private def generate_enum_emoji
    File.open(@output_filename, 'w') do |f|
      f.puts <<~DEF
        enum Emoji: CaseIterable {
            static func random() -> Emoji {
                Emoji.allCases.randomElement()!
            }

            case #{cases}

            var image: String {
                String(String.UnicodeScalarView(unicodeScalars))
            }
            var unicodeScalars: [UnicodeScalar] {
                _unicodeScalars.map({ UnicodeScalar($0)! })
            }
            private var _unicodeScalars: [Int] {
                switch self {
                #{unicodeScalars}
                default:
                    preconditionFailure("EmojiGacha: Unknown emoji")
                }
            }
            var description: String {
                switch self {
                #{descriptions}
                default:
                    preconditionFailure("EmojiGacha: Unknown emoji")
                }
            }
        }
      DEF
    end
  end

  private def case_name(string)
    return '`guard`' if string == 'guard'

    partially_sanitized = string
      .gsub('&', 'and')
      .gsub('1st', 'first')
      .gsub('2nd', 'second')
      .gsub('3rd', 'third')
      .gsub('*', 'asterisk')
      .gsub('#', 'hash')

    sanitized = ''
    if partially_sanitized.match?(/flag:/)
      sanitized = partially_sanitized
        .gsub(/[’: \.\(\)\-]/, '_')
    else
      sanitized = partially_sanitized
        .gsub(/[^0-9a-zA-Z]/, '_')
    end

    snakecased = sanitized
      .gsub(/_+/, '_') 
      .downcase
      .split('_')
    [snakecased[0], *snakecased[1..-1].map(&:capitalize)].join
  end

  private def cases
    @emoji_list.map { |emoji| case_name(emoji[:description]) }.join(', ')
  end

  private def unicodeScalars
    @emoji_list.map do |emoji|
      <<~CASE.chomp
        case .#{case_name(emoji[:description])}: return #{emoji[:code_points]};
      CASE
    end.join("\n" + ' ' * 8)
  end

  private def descriptions
    @emoji_list.map do |emoji|
      <<~CASE.chomp
        case .#{case_name(emoji[:description])}: return "#{emoji[:description].gsub('⊛', '').strip}";
      CASE
    end.join("\n" + ' ' * 8)
  end
end

Generator.new(ARGV[0] || 'Emoji.swift').generate
