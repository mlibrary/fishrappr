namespace :data do
  desc 'Import XML files to DB via AR'
  task daily_xml_to_db: :environment do

    # passing "testing" produces pp output for each new issue and page
    # pass any other string will not
    DailyXmlToDb.new("testing") 

  end
end