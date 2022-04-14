#
# Load mimemagic - there has been much ado about mimemagic in the past
#
unless Gem::Specification.all_names.any?{|gem| gem =~ /mimemagic/}
  gem 'mimemagic', '~> 0.3.8'
end

#
# Load plugins' Gemfiles
#
Dir.glob File.expand_path("../converters/*/{Gemfile,PluginGemfile}", __FILE__) do |file|
  eval_gemfile file
end

gem 'rubyzip', require: 'zip'
