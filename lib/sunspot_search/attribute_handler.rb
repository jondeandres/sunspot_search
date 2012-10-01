module SunspotSearch

  class AttributeHandler
    attr_reader :field, :value, :sunspot_type

    def initialize(field, value, options = { } )
      @sunspot_type = sunspot_type
      @field = field
      @value = value
    end

    def query(dsl)
      q = query_action

      if q.is_a?(String)
        dsl.instance_eval(q)
      else
        args = q.parameters.map{ |p| send(p.last) }
        q.singleton_bind(dsl).call(*args)
      end
    end

    def query_action
      equal
    end

    def equal
      proc do |field, value|
        unless value.is_a?(Array)
          with(field, value)
        else
          with(field).all_of(value)
        end
      end
    end
  end

  class TextHandler < AttributeHandler
    def query_action
      text
    end

    def text
      proc do |field, value|
        if field
          fulltext(value) { fields(field) }
        else
          fulltext(value)
        end
      end
    end

  end

  class BooleanHandler < AttributeHandler
    def query_action
      compare
    end

    def compare
      proc do |field, boolean_value|
        with(field, boolean_value)
      end
    end

    def boolean_value
      !![true, 1, "1", "true"].detect{ |t| t == value }
    end
  end

  class TimeHandler < AttributeHandler
    def query_action
      if value[:start] && value[:end]
        between
      elsif value[:start]
        greater_than
      elsif value[:end]
        less_than
      end
    end

    def greater_than
      proc do |field, parsed_value|
        with(field).greater_than(parsed_value[:start])
      end
    end

    def less_than
      proc do |field, parsed_value|
        with(field).less_than(parsed_value[:end])
      end
    end

    def between
      proc do |field, parsed_value|
        with(field, parsed_value[:start]..parsed_value[:end])
      end
    end

    def parsed_value
      @parsed_value ||= value.inject({ }) do |acc, item|
        date = item.last.is_a?(String) ? Time.parse(item.last) : item.last
        acc[item.first] = date
        acc
      end
    end
  end
end
