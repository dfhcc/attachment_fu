lib = File.expand_path('../lib/', __FILE__)
$:.unshift(lib) unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name         = 'ncri_attachment_fu'
  s.version      = '0.1.8'
  s.platform     = Gem::Platform::RUBY
  s.authors      = ['Jon Moses', 'Nico Ritsche']
  s.email        = ['jon@burningbush.us', 'ncrdevmail@gmail.com']
  s.homepage     = 'https://github.com/ncri/attachment_fu'
  s.summary      = 'Attachment-fu for rails3'
  s.description  = 'attachment-fu for rails3.  You know what it is.'

  s.files        = Dir.glob("{lib,rails,vendor}/**/*") + %w( CHANGELOG LICENSE README amazon_s3.yml.tpl rackspace_cloudfiles.yml.tpl )
  s.require_path = 'lib'
end

