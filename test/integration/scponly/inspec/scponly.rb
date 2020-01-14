# InSpec test for recipe osl-scponly::default

# The InSpec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

require_relative '../../helpers/inspec/helpers_spec.rb'

scponly_test('scponly_test', '/home/scponly_test')

describe user('scponly_test') do
  it { should exist }
  its('home') { should cmp '/home/scponly_test' }
  its('shell') { should cmp '/usr/bin/scponly' }
  its('group') { should cmp 'scponly_test' }
end
