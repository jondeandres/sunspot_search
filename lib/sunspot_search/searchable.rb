module SunspotSearch
  module Searchable
    class InvalidFilter < StandardError; end

    def self.included(base)
        base.class_eval do
        class_attribute :sunspot_search_scopes
        self.sunspot_search_scopes = []

        class << self
          include ClassMethods
        end
      end
    end

    module ClassMethods
      def sunspot_fields
        @sunspot_fields ||= (sunspot_setup.fields + sunspot_setup.all_text_fields).inject({ }) do |acc, field|
          acc[field.name] = field
          acc
        end
      end

      def sunspot_setup
        @sunspot_setup ||= Sunspot::Setup.for(self)
      end

      def sunspot_search(params = { }, options = { })
        raise "Model #{self.name} cannot be searchable with sunspot" unless self.try(&:searchable?)
        params.symbolize_keys!
        scopes = select_sunspot_scopes(params)
        klass = self
        results = search do
          scopes.each_pair do |scope, value|
            handler = klass.handler_for(scope, value)
            handler.query(self)
          end
          paginate(:page => params[:page], :per_page => params[:per_page])
        end
      end

      def handler_for(scope, value)
        if sunspot_type = sunspot_fields[scope]
          type = sunspot_type.type.class.name.split("::").last.gsub("Type", "")
          type_handler = "#{type}Handler"
          field_handler = SunspotSearch.const_defined?(type_handler) ? SunspotSearch.const_get(type_handler) : AttributeHandler

          field_handler.new( scope, value, :sunspot_type => sunspot_type)
        elsif scope == :text
          TextHandler.new(nil, value)
        end
      end

      def sunspot_search_with(*args)
        self.sunspot_search_scopes = args
      end

      def select_sunspot_scopes(params)
        filters = params.reject {|k,v| !k.to_s.match /^filter_/ }
        scopes = filters.inject({}) do |hash, (key,value)|
          k = key.to_s.gsub('filter_', '')
          if k.to_s =~ /(.*)_(start|end)/
            field = $1; type = $2
            hash[field.to_sym] ||= { }
            hash[field.to_sym][type.to_sym] = value
          else
            hash[k.to_sym] = value
          end
          hash
        end
        rogue_filters = scopes.keys - sunspot_search_scopes

        raise InvalidFilter, "Unexpected filter received in params: #{rogue_filters.inspect}" if rogue_filters.any?

        scopes
      end
    end
  end
end

