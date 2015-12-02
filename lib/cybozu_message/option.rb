# -*- coding: utf-8 -*-
require 'yaml'

module CybozuMessage
  class Option
    attr_reader :url, :username, :password

    def initialize
      @url = nil
      @username = nil
      @password = nil
      load_yaml
    end

    def load_yaml
      path = File.expand_path('../../data/setting.yaml', File.dirname(__FILE__))
      return if !File.exist?(path)

      setting = YAML.load_file(path)

      @url = setting['url'] + '?page=PApi'
      @username = setting['username']
      @password = setting['password']
    end
  end
end
