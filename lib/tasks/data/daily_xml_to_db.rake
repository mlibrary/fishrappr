namespace :data do
  desc 'Import XML files to DB via AR'
  task daily_xml_to_db: :environment do

    # the first param is the slug of the newspaper we wish to add
    # passing "testing" as the second param produces pp output for each publication, issue, and page
    # pass any other string as the second param will not
    # was: DailyXmlToDb.new("testing") 

    DailyXmlToDb_v2.new("the-michigan-daily", "NOtesting") 

  end
end