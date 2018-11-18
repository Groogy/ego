class SurveyTask < AgentTask
  struct Serializer < BaseSerializer
    def marshal(obj, node)
      super obj, node
      obj = obj.as(SurveyTask)
      node.marshal "path", obj.path
    end

    def unmarshal(node)
      path = node.unmarshal "path", Path
      unmarshal node, SurveyTask, path
    end
  end

  extend Boleite::Serializable(Serializer)
end