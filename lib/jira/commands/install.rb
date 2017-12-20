module Jira
  class CLI < Thor

    desc "install", "Guides the user through JIRA CLI installation"
    def install
      Command::Install.new.run
    end
  end

  module Command
    class Install < Base

      def run
        io.say('Please enter your JIRA information.')
        inifile[:global] = base_params

        case authentication
        when "basic"
          puts "To skip password entry when using jira-cli, set the JIRA_PASSWORD env var"
        when "token"
          inifile[:global][:token] = token
        end
        inifile.write
      end

    private

      def base_params
        {
          url:      url,
          username: username
        }
      end

      def session_params
        {
          username: username,
          password: password
        }
      end

      def authentication
        @authentication ||= io.select(
          "Select an authentication type:",
          ["basic", "token"]
        )
      end

      def url
        @url ||= io.ask("JIRA URL:")
      end

      def username
        @username ||= io.ask("JIRA username:")
      end

      def password
        Jira::Core.password
      end

      def token
        io.ask("JIRA token:")
      end

      def inifile
        @inifile ||= IniFile.new(
          comment:  '#',
          encoding: 'UTF-8',
          filename: Jira::Core.cli_path
        )
      end

    end
  end
end
