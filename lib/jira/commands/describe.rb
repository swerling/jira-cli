module Jira
  class CLI < Thor

    desc "describe <ticket>", "Describes the input ticket"
    method_option :summary_limit, aliases: "-s", type: :numeric, default: 50, banner: "Summary cutoff"
    method_option :description_limit, aliases: "-d", type: :numeric, default: 100, banner: "Description cutoff"

    def describe(ticket)
      Command::Describe.new(ticket, options).run
    end

  end

  module Command
    class Describe < Base

      attr_accessor :ticket, :options

      def initialize(ticket, options)
        self.ticket = ticket
        self.options = options
      end

      def run
        return if json.empty?
        return unless errors.empty?
        render_table(header, [row])
      end

      def header
        [ 'Ticket', 'Assignee', 'Status', 'Summary', 'Description' ]
      end

      def row
        [ ticket, assignee, status, summary, description ]
      end

      def errors
        @errors ||= (json['errorMessages'] || []).join('. ')
      end

      def assignee
        (fields['assignee'] || {})['name'] || 'Unassigned'
      end

      def status
        (fields['status'] || {})['name'] || 'Unknown'
      end

      def summary_limit
        options['summary_limit']
      end

      def summary
        truncate(json['fields']['summary'], self.summary_limit)
      end

      def description_limit
        options['description_limit']
      end

      def description
        truncate(json['fields']['description'], self.description_limit)
      end

      def fields
        json['fields'] || {}
      end

      def json
        @json ||= api.get "issue/#{ticket}"
      end

    end
  end
end
