require 'octokit'
require 'active_support/all'
require 'uri'

module Iceboxer
  class Template

    def initialize(repo)
      @repo = repo
    end

    def perform
      Octokit.auto_paginate = true

      # close issues that lack a template
      closers.each do |closer|
        issues = Octokit.search_issues(closer[:search])
        puts "Found #{issues.items.count} issues to close in #{@repo} ..."
        issues.items.each do |issue|
          unless already_nagged?(issue.number)
            puts "Nagging https://github.com/#{@repo}/issues/#{issue.number}: #{issue.title}"

            templateNag(issue.number, closer)
          end
        end
      end
    end

    def closers
      [
        {
          # The latest template, with "Is this a bug report?", was introduced on June 27, 2017.
          :search => "repo:#{@repo} is:issue is:open created:>=2017-06-27 NOT \"Is this a bug report?\" in:body NOT \"cherry-pick\" in:title -label:\"For Discussion\" comments:<5 -label:\"Core Team\" -label:\"Documentation\" -label:\"Missing required information from template\" -label:\"Needs more information\" -label:\"For Stack Overflow\" -label:\"Icebox\" -label:\"Good First Task\" NOT \"relicense\" in:title"
        },
        {
          # Earlier than July, let's check if they at least have some sort of repro steps
          :search => "repo:#{@repo} is:issue is:open created:<2017-06-27 NOT \"reproduction\" in:body NOT \"cherry-pick\" in:title -label:\"For Discussion\" comments:<5 -label:\"Core Team\" -label:\"Documentation\" -label:\"Missing required information from template\" -label:\"Needs more information\" -label:\"For Stack Overflow\" -label:\"Icebox\" -label:\"Good First Task\" NOT \"relicense\" in:title"
        }

      ]
    end

    def already_nagged?(issue)
      comments = Octokit.issue_comments(@repo, issue)
      comments.any? { |c| c.body =~ /no-template/ }
    end

    def templateNag(issue, reason)
      Octokit.add_comment(@repo, issue, message("there"))
      Octokit.update_issue(@repo, issue, :labels => "no-template, Ran Commands")
      Octokit.close_issue(@repo, issue)

      puts "Template nagged #{@repo}/issues/#{issue}!"
    end

    def message(issue_author)
      <<-MSG.strip_heredoc
      Thanks for posting this! It looks like your issue is missing some required information. Can you please add all the details specified in the [Issue Template](https://raw.githubusercontent.com/facebook/react-native/master/.github/ISSUE_TEMPLATE.md)? This is necessary for people to be able to understand and reproduce your issue. 
      
      I am going to close this, but please feel free to open a new issue with the additional information provided. Thanks!
      
      <sub>[How to Contribute](https://facebook.github.io/react-native/docs/contributing.html#bugs) • [What to Expect from Maintainers](https://facebook.github.io/react-native/docs/maintainers.html#handling-issues)</sub>

      MSG
    end
  end
end
