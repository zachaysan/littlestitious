# coding: utf-8
module Littlestitious

  def self.included(base)

    base.instance_eval do
      extend(ClassMethods)

      initialize_littlestitious_vars(base)
    end

  end

  module ClassMethods

    def inheritable_attrs(*args)
      args.flatten!
      @inheritable_attrs ||= [:inheritable_attrs]

      args -= @inheritable_attrs
      @inheritable_attrs += args

      args.each do |arg|
        class_eval %(
          class << self; attr_accessor :#{arg} end
        )
      end

      @inheritable_attrs
    end

    def inherited(subclass)
      @inheritable_attrs.each do |inheritable_attribute|

        instance_var = "@#{inheritable_attribute}"
        value = instance_variable_get instance_var

        subclass.instance_variable_set instance_var, value

      end
    end

    def initialize_littlestitious_vars(base)

      @zero_width_chars = {
        word_joiner:                   "\u2060",
        mongolian_vowel_separator:     "\u180e",
        zero_width_non_joiner:         "\u200c",
        zero_width_joiner:             "\u200d",
        zero_width_space:              "\u200b",
        zero_width_non_breaking_space: "\ufeff"
      }

      @weird_space_chars = {
        non_breaking_space:        "\u00a0",
        ogham_space:               "\u1680",
        en_quad_space:             "\u2000",
        em_quad_space:             "\u2001",
        en_space:                  "\u2002",
        em_space:                  "\u2003",
        three_per_em_space:        "\u2004",
        four_per_em_space:         "\u2005",
        six_per_em_space:          "\u2006",
        hair_space:                "\u200a",
        narrow_non_breaking_space: "\u202f",
        medium_mathematical_space: "\u205f",
        spc_symbol:                "\u2420",
        brail_pattern_blank:       "\u2800",
        ideographic_space:         "\u3000"
      }

      # At some point work these into a newline fingerprint
      # detector—it's harder than it looks because systems
      # are inconsistent.
      @new_line_chars = {
        line_feed:       "\u000a",
        carriage_return: "\u000d"
      }

      @non_printing_chars = {
        null:                 "\u0000",
        start_of_heading:     "\u0001",
        start_of_text:        "\u0002",
        end_of_text:          "\u0003",
        end_of_transmission:  "\u0004",
        enquiry:              "\u0005",
        acknowledge:          "\u0006",
        bell_alert:           "\u0007",
        backspace:            "\u0008",
        character_tabulation: "\u0009",

        line_tabulation:      "\u000b",
        form_feed:            "\u000c",

        shift_out:            "\u000e",
        shift_in:             "\u000f",
        data_link_escape:     "\u0010",
        device_control_1:     "\u0011",
        device_control_2:     "\u0012",
        device_control_3:     "\u0013",
        device_control_4:     "\u0014",
        negative_acknowledge: "\u0015",
        synchronous_idle:     "\u0016",
        end_of_trans_block:   "\u0017",
        cancel:               "\u0018",
        end_of_medium:        "\u0019",
        substitute:           "\u001a",
        escape:               "\u001b",
        file_separator:       "\u001c",
        group_separator:      "\u001d",
        record_separator:     "\u001e",
        unit_separator:       "\u001f",

        reverse_line_feed:    "\u008d",
        cancel_character:     "\u0094"
      }

      char_sub_group_syms = [ :weird_space_chars,
                              :non_printing_chars,
                              :zero_width_chars ]

      char_sub_groups = char_sub_group_syms.map do |sym|
        instance_variable_get "@#{sym}"
      end

      @all_chars = { checkmark: "\u2713" }

      char_sub_groups.each { | group | @all_chars.merge! group }

      @char_groups = [ @all_chars ] + char_sub_groups

      @char_groups.map do |char_group|
        char_group.transform_values! { |v| v.encode "utf-8" }
        char_group.freeze
      end

      @char_lookup = {}
      @all_chars.map { |k, v| @char_lookup[v] = k }

      size_ok = @char_lookup.size == @all_chars.size
      message = "Mismatched charater mapping".freeze
      raise AssertionError, message unless size_ok

      class_instance_vars = \
      [ :all_chars, :char_lookup ] + char_sub_group_syms

      inheritable_attrs class_instance_vars

    end

  end

  def includes_zero_width_characters?
    return false if self.boring?

    self.class.zero_width_chars.each do | char_type, char |
      return true if self.include? char
    end

    false
  end

  def includes_weird_spaces?
    return false if self.boring?

    self.class.weird_space_chars.each do | char_type, char |
      return true if self.include? char
    end

    false
  end

  def includes_non_printing_characters?
    return false if self.boring?

    self.class.non_printing_chars.each do | char_type, char |
      return true if self.include? char
    end

    false
  end

  def boring?
    # Matches ascii character 10 and 32 to 126
    # (newline + space + all visible)
    regex_string = '[^\n -~]'

    @boring_regex ||= Regexp.new regex_string

    @boring_regex.match(self).nil?
  end

  def strange_character_count

    char_count = Hash.new(0)

    return char_count if self.boring?

    self.each_char do |char|
      char_type = self.class.char_lookup[char]
      next unless char_type
      char_count[char_type] += 1
    end

    char_count

  end
  alias_method :count_strange_characters, :strange_character_count
  alias_method :count_strange_chars,      :strange_character_count
  alias_method :count_strange,            :strange_character_count
  alias_method :strange_count,            :strange_character_count
  alias_method :strange_char_count,       :strange_character_count

end

# TODO: Make littlestitious inclusion into string optional

class String

  include Littlestitious

end
