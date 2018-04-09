require 'parslet'

module Rundoc
  class PegParser < Parslet::Parser
    rule(:spaces) { match('\s').repeat(1) }
    rule(:spaces?) { spaces.maybe }
    rule(:comma) { spaces? >> str(',') >> spaces? }
    rule(:digit) { match('[0-9]') }
    rule(:single_string) {

    }
    rule(:singlequote_string) {
      str("'") >> (
        str("'").absnt? >> any
      ).repeat.as(:string) >>
      str("'") >> spaces?
    }
    rule(:doublequote_string) {
      str('"') >> (
        str('"').absnt? >> any
      ).repeat.as(:string) >>
      str('"') >> spaces?
    }
    rule(:string) { doublequote_string | singlequote_string }

    rule(:number) {
      (
        str('-').maybe >> (
          str('0') | (match('[1-9]') >> digit.repeat)
        ) >> (
          str('.') >> digit.repeat(1)
        ).maybe >> (
          match('[eE]') >> (str('+') | str('-')).maybe >> digit.repeat(1)
        ).maybe
      ).as(:number)
    }

    rule(:value) {
      string |
      number |
      str('true').as(:true) |
      str('false').as(:false) |
      str('nil').as(:nil)
    }

    rule(:key) {
      match['[^:\s]'].repeat
    }

    rule(:key_value) {
      (
         key.as(:key) >> spaces? >>
         str(':') >> spaces? >>
         value.as(:val)
      ).as(:key_value)
    }

    rule(:named_args) {
      spaces? >>
      (key_value >> (comma >> key_value).repeat).maybe.as(:named_args) >>
      spaces?
    }
  end
end


module Rundoc
  class PegTransformer < Parslet::Transform
    rule(:string => simple(:st)) {
      st.to_s
    }
    rule(:number => simple(:nb)) {
      nb.match(/[eE\.]/) ? Float(nb) : Integer(nb)
    }

    rule(:named_args => subtree(:na)) {

      (na.is_a?(Array) ? na : [ na ]).each_with_object({}) { |element, hash|
        key = element[:key_value][:key].to_sym
        val = element[:key_value][:val]
        hash[key] = val
      }
    }
  end
end