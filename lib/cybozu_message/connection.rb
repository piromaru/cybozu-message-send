# -*- coding: utf-8 -*-
require 'rest_client'
require 'rexml/document'
require 'time'
require 'base64'

module CybozuMessage
  class Connection
    LOGIN_SERVICE = 'Base'
    LOGIN_METHOD = 'BaseGetUsersByLoginName'
    SERVICE = 'Message'
    METHOD = 'MessageCreateThreads'

    attr_reader :error
    def initialize(option)
      @option = option
      @user = nil
      @error = nil
    end

    def login
      params = %{<parameters xmlns=""><login_name>#{@option.username}</login_name></parameters>}
      response = get(LOGIN_SERVICE, LOGIN_METHOD, params)

      if response
        doc = REXML::Document.new(response)
        elem = doc.elements['soap:Envelope/soap:Body/base:BaseGetUsersByLoginNameResponse/returns/user']
        id = elem.attributes['key']
        name = elem.attributes['name']
        @user = User.new(id, name)
      end

      return @user
    end

    def message(addressee, subject, body, file_path, confirm)

      addressee_ary = addressee.split(",")

      params =  %{ <parameters xmlns="">}
      params << %{  <create_thread>}
      params << %{    <thread}
      params << %{      id="dummy"}
      params << %{       version="999999"}
      params << %{       subject="#{subject}"}
      params << %{       confirm="#{confirm}"}
      params << %{       is_draft="false">}

      for ad in addressee_ary do
        params << %{       <addressee xmlns="http://schemas.cybozu.co.jp/message/2008"}
        params << %{         user_id="#{ad}"}
        params << %{         deleted="false"/>}
      end

      params << %{       <content xmlns="http://schemas.cybozu.co.jp/message/2008"}
      params << %{         body="#{body}">}

      unless file_path.nil? then
        file_Path_ary = file_path.split(",")
        file_Path_ary.each_with_index do |fp, index|
          params << %{           <file id="attached#{index}" name="#{File::basename(fp)}" mime_type="application/octet-stream" />}
        end
      end

      params << %{       </content>}
      params << %{     </thread>}

      unless file_path.nil? then
        file_Path_ary.each_with_index do |fp, index|
          content = Base64.encode64(File.binread(fp))
          params << %{     <file id="attached#{index}">}
          params << %{       <content>#{content}</content>}
          params << %{     </file>}
        end
      end

      params << %{   </create_thread>}
      params << %{ </parameters>}

      response = get(SERVICE, METHOD, params)

      return response

    end

    def get(service, method, params)
      time = Time.now
      created = time.strftime('%Y-%m-%dT%H:%M:%SZ')
      time = time + 1
      expires = time.strftime('%Y-%m-%dT%H:%M:%SZ')

      xml = <<-EOS
      <?xml version="1.0" encoding="utf-8"?>
      <soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
        <soap:Header>
            <Action soap:mustUnderstand="1" xmlns="http://schemas.xmlsoap.org/ws/2003/03/addressing">#{method}</Action>
            <Timestamp soap:mustUnderstande="1" xmlns="http://schemas.xmlsoap.org/ws/2002/07/utility">
                  <Created>#{created}</Created>
                  <Expires>#{expires}</Expires>
            </Timestamp><Security xmlns:wsu="http://schemas.xmlsoap.org/ws/2002/07/utility" soap:mustUnderstand="1" xmlns="http://schemas.xmlsoap.org/ws/2002/12/secext">
            <UsernameToken>
              <Username>#{@option.username}</Username>
              <Password>#{@option.password}</Password>
            </UsernameToken>
          </Security>
      </soap:Header>
        <soap:Body>
          <#{method} xmlns="http://wsdl.cybozu.co.jp/base/2008">
            #{params}
          </#{method}>
        </soap:Body>
      </soap:Envelope>
      EOS

      #前に空白があるとエラーになる
      xml.strip!

      response = nil
      begin
        response = RestClient.post @option.url + service, xml, :content_type => "application/soap+xml; charset=utf-8; action="#{method}"}
        response = check_err(response)
      rescue
        @error = '通信エラーが発生しました'
      end

      return response
    end

    def check_err(response)
      doc = REXML::Document.new(response)
      elem = doc.elements['soap:Envelope/soap:Body/soap:Fault']
      unless elem
        return response
      end

      @error = doc.elements['soap:Envelope/soap:Body/soap:Fault/soap:Reason/soap:Text'].text
      return nil
    end
  end
end
