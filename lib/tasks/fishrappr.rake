require 'pp'
namespace :fishrappr do
  desc "Reindex issues"
  task :reindex_issues, [:ht_namespace, :ht_barcode] => :environment do |t, args|
    ht_namespace = args[:ht_namespace] || 'mdp'
    IssueIndexer.run ht_namespace, args[:ht_barcode]
  end
end