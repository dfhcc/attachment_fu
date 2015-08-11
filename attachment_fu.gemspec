lib = File.expand_path('../lib/', __FILE__)
$:.unshift(lib) unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name         = 'attachment_fu'
  s.version      = '0.0.3'
  s.platform     = Gem::Platform::RUBY
  s.authors      = ['Jon Moses', 'Nico Ritsche', 'Tom Leonard']
  s.email        = ['thomas_leonard@dfci.harvard.edu']
  s.homepage     = 'https://github.com/dfhcc/attachment_fu'
  s.summary      = 'Attachment-fu for rails3'
  s.description  = 'Attachment-fu for rails3. Modified for use by DF/HCC.'

  s.files        = Dir.glob("{lib,rails,vendor}/**/*") + %w( CHANGELOG LICENSE README amazon_s3.yml.tpl rackspace_cloudfiles.yml.tpl )
  s.require_path = 'lib'
end

