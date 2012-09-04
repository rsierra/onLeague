module Utils
  module Color
    def Color.opposite_color_hex color_hex
      black_color_hex = "FFFFFF"
      "#" + (black_color_hex.hex - color_hex.gsub('#','').hex).to_s(16).rjust(6, '0')
    end
  end
end
