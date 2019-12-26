# InSpec test for recipe osl-scponly::default

# The InSpec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

describe package('scponly') do
  it { should be_installed }
end

%w(sbin/scponlyc bin/scponly).each do |s|
  describe file('/etc/shells') do
    its('content') { should include "/usr/#{s}" }
  end
end

describe group('scponly') do
  it { should exist }
end
