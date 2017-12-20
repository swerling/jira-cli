module Jira
  class Core
    class << self

      #
      # @return [String] JIRA project endpoint
      #
      def url
        @url ||= ENV['JIRA_URL'] || config[:global]['url']
      end

      #
      # @return [String] JIRA username
      #
      def username
        @username ||= ENV['JIRA_USERNAME'] || config[:global]['username']
      end

      #
      # @return [String] JIRA password
      #
      def password(site_url = nil)
        @password ||= begin
          if(pwd = ENV['JIRA_PASSWORD']).nil?
            puts "\n\tTo skip password entry for jira-cli, define env var JIRA_PASSWORD.\n\n"
            TTY::Prompt.new.mask("Please enter your password for #{self.username}@#{site_url || self.url}:")
          else
            pwd
          end
        end
      end

      #
      # @return [String] JIRA token
      #
      def token
        @token ||= ENV['JIRA_TOKEN'] || config[:global]['token']
      end

      #
      # @return [Hash] JIRA cookie
      #
      def cookie
        return {} if config[:cookie].nil? || config[:cookie].empty?
        { name: config[:cookie]['name'], value: config[:cookie]['value'] }
      end

      #
      # Determines whether or not the input ticket matches the expected JIRA
      # ticketing syntax. Outputs a warning that the input ticket isn't a valid
      # ticket.
      #
      # @param ticket [String] input ticket name
      # @param verbose [Boolean] verbose output of the ticket warning
      #
      # @return [Boolean] whether input string matches JIRA ticket syntax
      #
      def ticket?(ticket, verbose=true)
        !!ticket.to_s[/^[a-zA-Z]+-[0-9]+$/] and return true
        if verbose
          puts "#{Jira::Format.ticket(ticket)} is not a valid JIRA ticket."
        end
        false
      end

      ### Relevant Paths

      #
      # @return [String] path to .jira-cli file
      #
      def cli_path
        @cli_path ||= "#{Dir.home}/.jira-cli"
      end

      #
      # @return [String] path to .jira-rescue-cookie file
      #
      def rescue_cookie_path
        @rescue_cookie_path ||= "#{Dir.home}/.jira-rescue-cookie"
      end

      def config
        @config ||= (
          raise InstallationException unless File.exist?(cli_path)
          IniFile.load(cli_path, comment: '#', encoding: 'UTF-8')
        )
      end

    end
  end
end
