class Issue < ActiveRecord::Base
  self.table_name = "issues"
  after_save :index_record
  #before_destroy :remove_from_index

  def index_record

    conn = Blacklight.default_index.connection
    doc = { id: self.id, volume_t => volume }
#     doc = YAML.load(File.open(File.join(Blacklight.root, 'solr', 'sample_solr_documents.yml')))
    conn.add doc
    conn.commit
  end

end
