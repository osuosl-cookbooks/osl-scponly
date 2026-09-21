module OslScponly
  module Cookbook
    module Helpers
      # The account's passwd line with the jail prefix stripped from its home,
      # so it resolves inside the jail. nil until the user resource has run.
      def osl_scponly_jail_passwd_line(altroot, account)
        line = ::File.readlines('/etc/passwd').find { |l| l.start_with?("#{account}:") }
        return if line.nil?

        fields = line.chomp.split(':', -1)
        # squeeze collapses the doubled slash older converges wrote into home.
        fields[5] = fields[5].sub(/\A#{::Regexp.escape(altroot)}/, '').squeeze('/')
        fields.join(':')
      end
    end
  end
end
Chef::DSL::Recipe.include ::OslScponly::Cookbook::Helpers
Chef::Resource.include ::OslScponly::Cookbook::Helpers
