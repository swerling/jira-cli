require 'fileutils'

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
        io.say <<-XXX
          jira-cli will store your jira info in #{Jira::Core.cli_path}.

          The directory will have limited access (0700).

          The config file will also have limited access (0600).

        XXX
        io.say('Please enter your JIRA information.')
        inifile[:global] = base_params

        case authentication
        when "basic"
          inifile[:global][:password] = password
        when "token"
          inifile[:global][:token] = token
        end

        save_ini_file
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
        io.say <<-SAY
          Your password will be stored in plain text in #{Jira::Core.cli_path}".

          The config file and its parent directory are given restricted
          access only when created by jira-cli.

          Skip the password entry if you prefer to store the password in
          an env var called JIRA_PASSWORD, or if you prefer to enter your
          password each time you run a jira-cli command.
        SAY
        io.mask("JIRA password:")
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

      # save ini file, restricting access to the dir and the config file
      def save_ini_file
        fn = Jira::Core.cli_path

        dir = File.dirname(fn)
        if !File.exist?(dir)
          FileUtils.mkdir(dir)
          FileUtils.chmod(0700, dir)
        end
        inifile.write
        FileUtils.chmod(0600, fn)
      end

    end
  end
end
