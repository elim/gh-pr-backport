require 'octokit'

module GhPrBackport
  module Common
    def client
      client = Octokit::Client.new(access_token: `git config backport.token`.chomp)
      client.scopes # Validate token. If the token is invalid, then raise an error.
      client
    end

    def clean?
      `git status --porcelain`.chomp.empty?
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
  end
end
