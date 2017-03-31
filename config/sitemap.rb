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

  add '/static/donors', changefreq: 'monthly'
  add '/static/about_daily', changefreq: 'monthly'
  add '/static/about_project', changefreq: 'monthly'
  add '/static/rights', changefreq: 'monthly'

  issue_cache = {}
  publication_cache = {}
  Page.find_each do |page|
    unless issue_cache[page.issue_id]
      issue_cache[page.issue_id] = page.issue
    end
    issue = issue_cache[page.issue_id]
    unless publication_cache[issue.publication_id]
      publication_cache[issue.publication_id] = issue.publication
    end
    publication = publication_cache[issue.publication_id]
    priority = page.issue_sequence == 1 ? 1.0 : 0.5
    add "/#{publication.slug}/#{issue_cache[page.issue_id].volume_identifier}/#{page.volume_sequence}", lastmod: page[:updated_at], priority: priority, changefreq: 'monthly'
  end

end
