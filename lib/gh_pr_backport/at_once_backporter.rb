require 'octokit'

module GhPrBackport
  class AtOnceBackporter
    include GhPrBackport::Common

    def run
      raise GhPrBackport::DirectoryIsMessy unless clean?
      create_todo_file
      open_editor
      run_todos_from_file
    end

    def open_editor
      unless system("#{optional_str ENV['EDITOR'], 'vim'} #{todo_file}")
        raise 'Editor returned non-zero exit status.'
      end
    end

    def run_todos_from_file
      todo_commits = read_todo_file
      if todo_commits.empty?
        puts 'Nothing to do.'
        return
      end
      system("git cherry-pick -m 1 -x #{todo_commits.join(' ')}")
    end

    def list_todo_prs
      picked_pr_numbers = list_picked_prs.map { |commit| commit[:pr_number] }.to_set
      list_merged_prs.select { |commit| !picked_pr_numbers.include?(commit[:pr_number]) }
    end

    def list_merged_prs
      parse_log_stream(`git log --merges #{log_format_option} HEAD..origin/HEAD`)
        .select { |commit| commit[:pr_number] }
    end

    def list_picked_prs
      parse_log_stream(`git log #{log_format_option} origin/HEAD..HEAD`)
        .select { |commit| commit[:pr_number] }
    end

    private

    def git_dir
      optional_str ENV['GIT_DIR'], '.git'
    end

    def todo_file
      File.join(git_dir, '.git-pr-backport-todo')
    end

    def read_todo_file
      File.readlines(todo_file)
        .map(&:strip)
        .reject { |line| line == '' || line.start_with?('#') }
        .each_with_index { |line, i| raise "Parse error in line #{i + 1}: #{line}" unless line =~ /^[0-9A-Za-z]+(?:\s|\z)/ }
        .map { |line| line.split(/\s+/, 2)[0] }
    end

    def create_todo_file
      File.write(todo_file, list_todo_prs.map do |commit|
        "# #{commit[:hash][0..7]} ##{commit[:pr_number]} #{commit[:body].lines[0]} (#{pr_to_link(commit)})"
      end.join("\n"))
    end

    def pr_to_link(commit)
      "#{repo.url}/pull/#{commit[:pr_number]}"
    end

    def log_format_option
      # null terminated
      '--format=format:%H%n%B%x00'
    end

    def parse_log_stream(stream)
      stream
        .split("\0\n")
        .map { |commit_data| parse_commit_data(commit_data) }
        .reverse
    end

    def parse_commit_data(commit_data)
      hash, subject, body = commit_data.split("\n", 3).map(&:strip)
      pr_number = subject.match(/\AMerge pull request #([1-9][0-9]*) from/)&.tap { |m| break m[1].to_i }
      { hash: hash, pr_number: pr_number, subject: subject, body: body || '' }
    end

    def optional_str(str, default)
      str == '' ? default : str || default
    end
  end
end
