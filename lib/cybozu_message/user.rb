# -*- coding: utf-8 -*-

module CybozuMessage
  class User
    attr_reader :id, :name

    def initialize(id, name)
      @id = id
      @name = name
    end
  end
end
