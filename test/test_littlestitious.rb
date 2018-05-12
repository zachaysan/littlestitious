# coding: utf-8
require 'test_helper'

describe Littlestitious do

  before do

    suspicious_strings = \
    [ "Suspicious CHAR string",
      "CHARSuspicious string",
      "Suspicious stringCHAR",
      "Suspicious string\nCHAR" ]

    @zero_width_strings = \
    { :word_joiner=>"⁠",
      :mongolian_vowel_separator=>"᠎",
      :zero_width_non_joiner=>"‌",
      :zero_width_joiner=>"‍",
      :zero_width_space=>"​",
      :zero_width_non_breaking_space=>"﻿" }
      .map do | char_type, char |

      suspicious_strings.map { |string| string.gsub "CHAR", char }

    end.flatten

    @weird_space_strings = \
    { :non_breaking_space=>" ",
      :ogham_space=>" ",
      :en_quad_space=>" ",
      :em_quad_space=>" ",
      :en_space=>" ",
      :em_space=>" ",
      :three_per_em_space=>" ",
      :four_per_em_space=>" ",
      :six_per_em_space=>" ",
      :hair_space=>" ",
      :narrow_non_breaking_space=>" ",
      :medium_mathematical_space=>" ",
      :spc_symbol=>"␠",
      :brail_pattern_blank=>"⠀",
      :ideographic_space=>"　" }
      .map do | char_type, char |

      suspicious_strings.map { |string| string.gsub "CHAR", char }

    end.flatten

    @normal_strings = \
    [ "Someone did something suspicious but it wasn't me.",
      "lol\nlook\r\nelsewhere" ]

    @marked_up_string = "Something‌isn't ‌right here\t✓"
  end

  describe "when used as a String descendant class" do

    before do
      class BetterString < String
        include Littlestitious
      end
    end

    it "reports zero width characters" do
      @zero_width_strings.map do | string |
        better_string = BetterString.new string
        better_string.includes_zero_width_characters?.must_equal true
      end
    end

    it "doesn't flag normal strings" do
      @normal_strings.map do | string |
        better_string = BetterString.new string
        better_string.includes_zero_width_characters?.must_equal false
      end
    end

    it "reports weird spaces in strings" do
      @weird_space_strings.map do | string |
        better_string = BetterString.new string
        better_string.includes_weird_spaces?.must_equal true
      end
    end

    it "reports counts of weird chars" do
      better_string = BetterString.new @marked_up_string
      count = better_string.strange_character_count
      expected_count = {:zero_width_non_joiner=>2,
                        :en_quad_space=>1,
                        :character_tabulation=>1,
                        :checkmark=>1}
      count.must_equal expected_count
    end

  end

  describe "when used directly as a String" do

    before do
      class String
        include Littlestitious
      end
    end

    it "reports zero width characters" do
      @zero_width_strings.map do | string |
        string.includes_zero_width_characters?.must_equal true
      end
    end

    it "doesn't flag normal strings" do
      @normal_strings.map do | string |
        string.includes_zero_width_characters?.must_equal false
      end
    end

    it "reports weird spaces in strings" do
      @weird_space_strings.map do | string |
        string.includes_weird_spaces?.must_equal true
      end
    end

    it "reports counts of weird chars" do
      count = @marked_up_string.strange_character_count
      expected_count = { zero_width_non_joiner: 2,
                         en_quad_space: 1,
                         character_tabulation: 1,
                         checkmark: 1 }
      count.must_equal expected_count
    end

  end

end
