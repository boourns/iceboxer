require 'octokit'
require 'active_support/all'

module Iceboxer
  class Icebox

    def initialize(repo)
      @repo = repo
    end

    def perform
      closers.each do |closer|
        issues = Octokit.search_issues(closer[:search])
        puts "Found #{issues.items.count} issues to close in #{@repo} ..."
        issues.items.each do |issue|
          unless already_iceboxed?(issue.number)
            puts "Closing #{@repo}/issues/#{issue.number}: #{issue.title}"

            if send_to_product_pains?
              send_to_product_pains(issue)
            else
              icebox(issue.number, closer)
            end
          end
        end
      end
    end

    def closers
      [
        {
          :search => "repo:#{@repo} is:open created:<#{12.months.ago.to_date.to_s} updated:<#{2.months.ago.to_date.to_s}",
          :message => "This is older than a year and has not been touched in 2 months."
        },
        {
          :search => "repo:#{@repo} is:open updated:<#{6.months.ago.to_date.to_s}",
          :message => "This has not been touched in 6 months."
        }
      ]
    end

    def already_iceboxed?(issue)
      comments = Octokit.issue_comments(@repo, issue)
      comments.any? { |c| c.body =~ /Icebox/ }
    end

    def send_to_product_pains?
      ENV['PRODUCT_PAINS_COOKIE'].present?
    end

    def icebox(issue, reason)
      Octokit.add_labels_to_an_issue(@repo, issue, ["Icebox"])
      Octokit.add_comment(@repo, issue, message(reason))
      Octokit.close_issue(@repo, issue)

      puts "Iceboxed #{@repo}/issues/#{issue}!"
    end

    def send_to_product_pains(issue)
      product_id = "5632cf5744c4901301e14e6a"
      github_url = "https://github.com/#{@repo}/issues/#{issue.number}"
      product_pains_url = Iceboxer::ProductPains.create_issue(issue, github_url, product_id)
      Octokit.add_labels_to_an_issue(@repo, issue.number, ["Icebox"])
      Octokit.add_comment(@repo, issue.number, product_pains_message(product_pains_url))
      Octokit.close_issue(@repo, issue.number)
    end

    def product_pains_message(url)
      <<-MSG.strip_heredoc
      Hi there! This issue is being closed because it has been inactive for a while.

      But don't worry, it will live on with ProductPains! Check out it's new home: #{url}
      MSG
    end

    def message(reason)
      <<-MSG.strip_heredoc
      ![picture of the iceboxer](https://cloud.githubusercontent.com/assets/699550/5107249/0585a470-6fce-11e4-8190-4413c730e8d8.png)

      #{reason[:message]}

      I am closing this as it is stale.

      I have applied the tag 'Icebox' so you can still see it by querying closed issues.

      Developers: Feel free to reopen if you and your team lead agree it is high priority and will be addressed in the next month.

      MSG
    end
  end
end
