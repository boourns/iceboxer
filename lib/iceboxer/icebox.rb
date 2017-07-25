require 'octokit'
require 'active_support/all'
require 'uri'

module Iceboxer
  class Icebox

    def initialize(repo)
      @repo = repo
    end

    def perform
      Octokit.auto_paginate = true

      # close stale issues
      closers.each do |closer|
        issues = Octokit.search_issues(closer[:search])
        puts "Found #{issues.items.count} issues to close in #{@repo} ..."
        issues.items.each do |issue|
          unless already_iceboxed?(issue.number)
            puts "Closing https://github.com/#{@repo}/issues/#{issue.number}: #{issue.title}"

            icebox(issue.number, closer)
          end
        end
      end
    end

    def closers
      [
        {
          :search => "repo:#{@repo} is:open is:issue updated:<#{2.months.ago.to_date.to_s}",
          :message => "it has been inactive for a while"
        }
      ]
    end

    def already_iceboxed?(issue)
      comments = Octokit.issue_comments(@repo, issue)
      comments.any? { |c| c.body =~ /Icebox/ }
    end

    def icebox(issue, reason)
      Octokit.add_labels_to_an_issue(@repo, issue, ["Icebox"])
      Octokit.add_comment(@repo, issue, message(reason))
      Octokit.close_issue(@repo, issue)

      puts "Iceboxed #{@repo}/issues/#{issue}!"
    end

    def message(reason)
      <<-MSG.strip_heredoc
      Hi there! This issue is being closed because #{reason}. Maybe the issue has been fixed in a recent release, or perhaps it is not affecting a lot of people. Either way, we're automatically closing issues after a period of inactivity. Please do not take it personally!

      If you think this issue should definitely remain open, please let us know. The following information is helpful when it comes to determining if the issue should be re-opened:

      - Does the issue still reproduce on the latest release candidate? Post a comment with the version you tested.
      - If so, is there any information missing from the bug report? Post a comment with all the information required by the [issue template](https://github.com/facebook/react-native/blob/master/.github/ISSUE_TEMPLATE.md).
      - Is there a pull request that addresses this issue? Post a comment with the PR number so we can follow up.

      If you would like to work on a patch to fix the issue, *contributions are very welcome*! Read through the [contribution guide](http://facebook.github.io/react-native/docs/contributing.html), and feel free to hop into [#react-native](https://discordapp.com/invite/0ZcbPKXt5bZjGY5n) if you need help planning your contribution.
      MSG
    end
  end
end
