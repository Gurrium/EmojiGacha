class Generator
  def initialize(input_filename, output_filename)
    @emoji_list = []
    @input_filename = input_filename
    @output_filename = output_filename
    # Usage:
    # [
    #   {
    #     code_points: [0x231a],
    #     description: 'watch1',
    #   },
    #   {
    #     code_points: [0x231b],
    #     description: 'watch2',
    #   },
    # ]
  end

  def main
    build_emoji_list

    generate_enum_emoji
  end

  private def build_emoji_list
    File.open(@input_filename) do |f|
      f.each_line do |line|
        next unless line.match?(/^[\h\.]+ /)

        raw_code_points, _, raw_description = line.split(';').map(&:strip)
        description = raw_description.split('#').first.strip
        endpoints = raw_code_points.split('..')
        if endpoints.count == 2
          (endpoints[0].to_i(16)...endpoints[1].to_i(16)).each_with_index do |code_point, index|
            append_to_emoji_list(code_points: [code_point], description: description + "_#{index}")
          end
        else
          append_to_emoji_list(code_points: raw_code_points.split.map { |code_point| code_point.to_i(16) }, description: description)
        end
      end
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
                    fatalError()
                }
            }
            var description: String {
                switch self {
                #{descriptions}
                default:
                    fatalError()
                }
            }
        }
      DEF
    end
  end

  private def case_name(string)
    snakecased = string
      .gsub('&', 'and')
      .gsub('1st', 'first')
      .gsub('*', 'asterisk')
      .gsub('\x{23}', 'hash')
      .gsub(/[^0-9a-zA-Z]/, '_')
      .gsub(/_+/, '_') 
      .downcase
    snakecased = snakecased.split('_')
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
    end.join("\n")
  end

  private def descriptions
    @emoji_list.map do |emoji|
      <<~CASE.chomp
        case .#{case_name(emoji[:description])}: return "#{emoji[:description].gsub('\x', '\\\\\\x')}";
      CASE
    end.join("\n")
  end
end

Generator.new(ARGV[0] || 'emoji-sequences.txt', ARGV[1] || 'Emoji.swift').main
