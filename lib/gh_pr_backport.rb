require 'gh_pr_backport/version'

module GhPrBackport
  class BranchCheckoutFailed < StandardError; end
  class CherryPickFailed < StandardError; end
  class DirectoryIsMessy < StandardError; end
  class FetchFailed < StandardError; end
  class PushFailed < StandardError; end

  autoload :Backporter, 'gh_pr_backport/backporter'
  autoload :AtOnceBackporter, 'gh_pr_backport/at_once_backporter'
  autoload :Common, 'gh_pr_backport/common'
end
