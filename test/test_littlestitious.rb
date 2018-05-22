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

    @new_line_chars = {
      :line_feed=>"\n",
      :carriage_return=>"\r",
    }

    @non_printing_strings = \
    { :null=>"\u0000",
      :start_of_heading=>"\u0001",
      :start_of_text=>"\u0002",
      :end_of_text=>"\u0003",
      :end_of_transmission=>"\u0004",
      :enquiry=>"\u0005",
      :acknowledge=>"\u0006",
      :bell_alert=>"\a",
      :backspace=>"\b",
      :character_tabulation=>"\t",

      :line_tabulation=>"\v",
      :form_feed=>"\f",

      :shift_out=>"\u000E",
      :shift_in=>"\u000F",
      :data_link_escape=>"\u0010",
      :device_control_1=>"\u0011",
      :device_control_2=>"\u0012",
      :device_control_3=>"\u0013",
      :device_control_4=>"\u0014",
      :negative_acknowledge=>"\u0015",
      :synchronous_idle=>"\u0016",
      :end_of_trans_block=>"\u0017",
      :cancel=>"\u0018",
      :end_of_medium=>"\u0019",
      :substitute=>"\u001A",
      :escape=>"\e",
      :file_separator=>"\u001C",
      :group_separator=>"\u001D",
      :record_separator=>"\u001E",
      :unit_separator=>"\u001F",
      :reverse_line_feed=>"\u008D",
      :cancel_character=>"\u0094" }
      .map do | char_type, char |

      suspicious_strings.map { |string| string.gsub "CHAR", char }

    end.flatten

    @normal_strings = \
    [ "Someone did something suspicious but it wasn't me.",
      "lol\nlookr\nelsewhere!!" ]

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
        better_string.includes_weird_spaces?.must_equal false
        better_string.includes_non_printing_characters?.must_equal false
      end
    end

    it "reports weird spaces in strings" do
      @weird_space_strings.map do | string |
        better_string = BetterString.new string
        better_string.includes_weird_spaces?.must_equal true
      end
    end

    it "reports non printing chars in strings" do
      @non_printing_strings.map do | string |
        better_string = BetterString.new string
        better_string.includes_non_printing_characters?.must_equal true
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

    it "can tell which strings are boring" do
      @normal_strings.map do | string |
        better_string = BetterString.new string
        better_string.boring?.must_equal true
      end
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

    it "can tell which strings are boring" do
      @normal_strings.map do | string |
        string.boring?.must_equal true
      end
    end

  end

end
