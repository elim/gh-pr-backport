require 'uri'

require 'bundler/setup'
require 'hashie'
require 'octokit'

class GhPrBackport::Backporter
  def initialize(original_pr_number:, staging_branch: nil)
    @client   = client
    @repo     = repo
    @original = original(original_pr_number)

    @backport_branch = backport_branch
    @staging_branch  = staging_branch || read_staging_branch_from_config
  end

  def backport
    raise GhPrBackport::DirectoryIsMessy unless clean?
    checkout_backport_branch
    cherry_pick
    # push
    # create_backport_pull_request
  end

  private

  def backport_branch
    "bp/#{@original.branch}"
  end

  def checkout_backport_branch
    system!("git checkout -b #{@backport_branch} origin/#{@staging_branch}",
            GhPrBackport::BranchCheckoutFailed)
  end

  def cherry_pick
    @original.commits.each do |commit|
      system!("git cherry-pick -x #{commit}", GhPrBackport::CherryPickFailed)
    end
  end

  def client
    client = Octokit::Client.new(access_token: `git config backport.token`.chomp)
    client.scopes # Validate token. If the token is invalid, then raise an error.
    client
  end

  def clean?
    `git status --porcelain`.chomp.empty?
  end

  def create_backport_pull_request
    body = "##{@original.number} のバックポートです\r\n\r\n" +
           @original.body.lines.map { |l| "> #{l}" }.join
    pr = client.create_pull_request(@repo,
                                    @staging_branch,
                                    @backport_branch,
                                    @original.title, body)
    client.add_assignees(repo, pr.number, [@original.user])
    client.add_labels_to_an_issue(repo, pr.number, @original.labels)
  end

  def fetch
    system!('git fetch', GhPrBackport::FetchFailed)
  end

  def original(number)
    original = client.pull_request(@repo, number)

    Hashie::Mash.new({
      number:  original.number,
      branch:  original.head.ref,
      user:    original.user.login,
      title:   original.title,
      body:    original.body,
      labels:  original.labels.map(&:name),
      commits: client.pull_request_commits(@repo, original.number).map(&:sha)
    })
  end

  def push
    system!('git push origin HEAD', GhPrBackport::PushFailed)
  end

  def read_staging_branch_from_config
    path = './' + `git rev-parse --show-cdup`.chomp
    `git config -f #{path}/.git-pr-release pr-release.branch.staging`.chomp
  end

  def repo
    remote = `git config remote.origin.url`.chomp
    repo_name = if remote.start_with?('git@github.com:')
                  remote.split(':', 2)[1].sub(/.git$/, '')
                else
                  URI.parse(remote).path.sub(%r{^\/}, '').sub(/.git$/, '')
                end
    Octokit::Repository.new(repo_name)
  end

  def system!(program, *args, error_class)
    raise error_class unless system(program, *args)
    true
  end
end
