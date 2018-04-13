require 'gh_pr_backport/backporter'
require 'gh_pr_backport/version'

module GhPrBackport
  class BranchCheckoutFailed < StandardError; end
  class CherryPickFailed < StandardError; end
  class DirectoryIsMessy < StandardError; end
  class FetchFailed < StandardError; end
  class PushFailed < StandardError; end
end
