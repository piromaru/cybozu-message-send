#! /usr/bin/env ruby
root = File.dirname(__FILE__) # 現在処理中のディレクトリ
$LOAD_PATH.unshift File.join(root, 'lib')

require 'rubygems'
require 'cybozu_message'

addressee = ARGV[0]
subject = ARGV[1].encode("UTF-8")
body = ARGV[2].nil? ? nil : ARGV[2].encode("UTF-8")
filePath = ARGV[3].nil? ? nil : ARGV[3].encode("UTF-8")
confirm = ARGV[4].nil? ? "true" : ARGV[4].encode("UTF-8")

# addressee, subject, body, filePath, confirm
CybozuMessage::App.new().run(addressee, subject, body, filePath, confirm)

