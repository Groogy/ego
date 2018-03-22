struct GameTime
  struct Serializer
    def marshal(obj, node)
      node.marshal "ticks", obj.to_i
    end

    def unmarshal(node)
      time = GameTime.new
      node.each do |key, value|
        value = value.as(Int64)
        case key
        when "years" then time.add_years value
        when "months" then time.add_months value
        when "days" then time.add_days value
        when "hours" then time.add_hours value
        when "ticks" then time.add_ticks value
        end
      end
      time
    end
  end

  extend Boleite::Serializable(Serializer)
end