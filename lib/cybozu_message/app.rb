# -*- coding: utf-8 -*-
module CybozuMessage
  class App
    def initialize
      @option = Option.new
    end

    def run(addressee, subject, body, file_path, confirm)

      unless @option.url
        return
      end

      con = Connection.new(@option)

      # ユーザー存在チェック
      user = con.login
      unless user
        notify(con.error)
        return
      end

      # メッセージ送信
      message_arr = con.message(addressee, subject, line_break_convert(body), file_path, confirm)
      unless message_arr
        notify(con.error)
        return
      end
    end

    def notify(message)
      puts message
    end

    def line_break_convert(body)
      body.gsub(/(\\r\\n|\\r|\\n)/, "&#xD;&#xA;")
    end

  end
end

