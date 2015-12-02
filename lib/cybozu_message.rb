Dir.glob(File.dirname(__FILE__) + '/cybozu_message/**/*.rb') do |f|
  require f.sub(/\.rb/, '')
end
