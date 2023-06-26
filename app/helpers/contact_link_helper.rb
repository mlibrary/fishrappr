# frozen_string_literal: true

# Helpers for building a link to Qualtrics
module ContactLinkHelper
  def contact_link
    return Settings.default_contact_link unless Settings.key?(:qualtrics_survey_link)
    build_contact_link Settings.qualtrics_survey_link, publication_slug
  end

  private

  def build_contact_link(link, publication_slug)
    uri = URI(link)
    unless publication_slug.nil?
      uri.query = "publication=#{publication_slug}"
    end
    uri.to_s
  end

  def publication_slug
    if @publication.present?
      return @publication['slug']
    end
  end
end
