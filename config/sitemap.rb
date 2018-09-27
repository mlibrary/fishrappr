# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://digital.bentley.umich.edu"
# SitemapGenerator::Sitemap.public_path = 'public/sitemaps'
SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end


  Publication.all.each do |publication|
    add "/#{publication.slug}/donors", changefreq: 'monthly'
    add "/#{publication.slug}/about", changefreq: 'monthly'
    add "/#{publication.slug}/project", changefreq: 'monthly'
    add "/#{publication.slug}/rights", changefreq: 'monthly'

    Issue.where(publication_id: publication.id).find_each do |issue|
      Page.where(issue_id: issue.id).find_each do |page|
        priority = page.issue_sequence == 1 ? 1.0 : 0.5
        add "/#{publication.slug}/#{issue.volume_identifier || issue.issue_identifier}/#{page.volume_sequence}", lastmod: page[:updated_at], priority: priority, changefreq: 'monthly'
      end
      STDERR.puts "-- processed: #{issue.issue_identifier}"
    end
    STDERR.puts "=== processed: #{publication.slug}"
  end

end
