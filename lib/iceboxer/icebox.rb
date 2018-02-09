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
          :search => "repo:#{@repo} is:open is:issue created:<#{12.months.ago.to_date.to_s} updated:<#{2.months.ago.to_date.to_s} -label:\"Good First Task\" -label:\"Help Wanted\" -label:\"For Discussion\""
        },
        {
          :search => "repo:#{@repo} is:open is:issue updated:<#{6.months.ago.to_date.to_s} -label:\"Good First Task\" -label:\"Help Wanted\" -label:\"For Discussion\""
        }
      ]
    end

    def already_iceboxed?(issue)
      comments = Octokit.issue_comments(@repo, issue)
      comments.any? { |c| c.body =~ /Icebox/ }
    end

    def icebox(issue, reason)
      Octokit.add_comment(@repo, issue, "@facebook-github-bot icebox")

      puts "Iceboxed #{@repo}/issues/#{issue}!"
    end
  end
end
