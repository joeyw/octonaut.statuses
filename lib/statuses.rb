module Octonaut

  desc 'Manage commit statuses'
  command :status do |c|
    c.default_command :show

    c.desc "View a commit status"
    c.arg_name "owner/repo ref"
    c.command :show do |show|
      show.action do |global,options,args|
        name = args.shift
        ref = args.shift

        statuses = @client.statuses(name, ref)
        puts("\n#{name} @ #{ref}\n\n")
        statuses.each do |status|
          puts "#{status.state}
            #{status.created_at}
            #{status.description}
            #{status.rels[:target].href if status.rels[:target] }"
        end
      end
    end

    c.desc "Update a commit status"
    c.arg_name "owner/repo ref state"
    c.command :update do |update|

      update.flag :state,
        :arg_name => "State",
        :desc => 'Commit status, can be pending, success, error, or failure.'

      update.flag :description,
        :arg_name => 'Description',
        :desc => 'A short description of the status'

      update.flag :target_url,
        :arg_name => 'Target URL',
        :desc => 'URL associated with the status.',
        :long_desc => %(
          The target URL to associate with this status. This URL will be linked
          from the GitHub UI to allow users to easily see the ‘source’ of the
          Status.
        )

      update.action do |global,options,args|
        repo = args.shift
        ref = args.shift
        state = args.shift

        opts = {}
        opts[:description] = options[:description] if options[:description]
        opts[:target_url] = options[:target_url] if options[:target_url]

        @client.create_status repo, ref, state, opts
      end
    end
  end
end
