unless Rails.env.production?
  require 'rubocop/rake_task'
  desc 'Run style checker'
  RuboCop::RakeTask.new(:rubocop) do |task|
    task.requires << 'rubocop-rspec'
    task.fail_on_error = false
  end

  desc 'Run the ci build'
  task ci: [:rubocop] do
    require 'solr_wrapper'
    SolrWrapper.wrap(port: '8888') do |solr|
      solr.with_collection(name: 'fishrappr-core', dir: File.join(File.expand_path("../../", File.dirname(__FILE__)), "solr", "conf")) do
        Rake::Task["spec"].invoke
      end
    end
  end
end
