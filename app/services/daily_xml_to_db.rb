require 'pp'
# require 'sqlite3'
require 'nokogiri'

# CODE FLOW OUTLINE
# -- PARSE XML FILES INTO AR OBJECTS --
# get directory for xml files
# get file list
# loop while next file exists
# open file with nokogiri
# parse file
# construct db row for issues table
# create AR record issue object from xml data and save it
# construct db row for pages table
# create AR record page object from xml data and save it
# end loop
# clean up file handling


# IMPLEMENTATION

class DailyXmlToDb
  attr_accessor :db, :db_name, :xml_dir, :file_list, :doc, :yml_file, :yml, :print_ok

  def initialize(testing)

    if testing == "testing"
      pp "TESTING..."
      @print_ok = true
    else
      @print_ok = false
    end
 
    # set directory for xml files
    @xml_dir = "./tmp/xml_data/"

    # get list of xml files
    @xml_list = []
    @xml_list = get_flist

    pp_ok "File list:"
    pp_ok @xml_list

    # parse the files xml
    @xml_list.each { |f| parse_file_to_ar(f) }
  end

  # get file list
  # make xml dir the current directory
  def get_flist
    pp_ok "Started in directory #{Dir.pwd}"
    Dir.chdir(@xml_dir)
    pp_ok "Moved to directory #{Dir.pwd}"
    return Dir.glob("*.{xml}")
  end

 # The following assumes that each xml file is single edition
  def parse_file_to_ar(f)
    pp_ok "STARTING PARSE for file #{f}..."

    @doc = Nokogiri::XML(File.open(f), 'UTF-8') do |config|
      config.options = Nokogiri::XML::ParseOptions::STRICT | Nokogiri::XML::ParseOptions::NOBLANKS
    end

    # Extend name space to include METS
    # couldn't get the following to work
    # example: node.xpath('.//foo:name', {'foo' => 'http://example.org/'})
    # example: node.xpath('.//xmlns:name', node.root.namespaces)
    # my try: puts @doc.xpath("xmlns:METS", {"METS" => "http://www.loc.gov/METS/"})

    # The following actually modifies the xml, which we don't want. But it works.
    ns = @doc.root.add_namespace_definition("xmlns:METS", "http://www.loc.gov/METS/")



    pp_ok "Current file is: #{f}"
    # issue information -------------
    # note: issue_id is autoincremented by the db
    # and we will want to select it from the last row created

    pp_ok "ISSUE INFO:"
    hathitrust = @doc.xpath("//MODS:identifier[@type='hathitrust']/text()").to_s
    pp_ok "hathitrust value is #{hathitrust}"

    volume = @doc.xpath("//MODS:detail[@type='volume']/MODS:number/text()").to_s
    pp_ok "volume value is #{volume}"

    issue_no = @doc.xpath("//MODS:detail[@type='issue']/MODS:number/text()").to_s
    pp_ok "issues value is #{issue_no}"

    edition = @doc.xpath("//MODS:detail[@type='edition']/MODS:number/text()").to_s
    pp_ok "edition value is #{edition}"

    date_issued = @doc.xpath("//MODS:dateIssued/text()").to_s
    pp_ok "dateIssued value is #{date_issued}"

    newspaper = @doc.xpath("/METS:mets/@LABEL").to_s
    newspaper = newspaper.split(",").first.strip
    pp_ok "newspaper is #{newspaper}"


    issue_id = add_data_issue_ar(hathitrust, volume, issue_no, edition, date_issued, newspaper)

    pp_ok "ISSUE ID IS: #{issue_id}"

    # page information -------------
    # note: page_id is autoincremented by the db

    pages_target = "//METS:structMap/METS:div[@TYPE='np:issue'][@DMDID='issueModsBib']/METS:div[@TYPE='np:page']"

    pages = @doc.xpath(pages_target)

    @doc.xpath(pages_target).each do |node|

      pp_ok "PAGE INFO:"

      pp_ok "issue_id value is #{issue_id}"

      page_no = node.xpath("@ORDERLABEL").to_s
      pp_ok "page_no value is #{page_no}"

      sequence = node.xpath("@ORDER").to_s.to_i
      pp_ok "sequence value is #{sequence}"

      text_link = node.xpath("METS:mptr[1]/@xlink:href").to_s
      pp_ok "text_link value is #{text_link}"

      img_link = node.xpath("METS:mptr[2]/@xlink:href").to_s
      pp_ok "img_link value is #{img_link}"

      add_data_page_ar(issue_id, page_no, sequence, text_link, img_link)

    end # each

    pp "File #{f} processed"

  end # parse_file_to_ar

  def add_data_issue_ar(hathitrust, volume, issue_no, edition, date_issued, newspaper)
    pp_ok "issue row will be (hathitrust, volume, issue_no, edition, date_issued, newspaper)"

    i = Issue.create  hathitrust: hathitrust, volume: volume, issue_no: issue_no, edition: edition, date_issued: date_issued, newspaper: newspaper
    i.save
    return i.id 
  end
  
  def add_data_page_ar(issue_id, page_no, sequence, text_link, img_link)
    pp_ok "page row will be (issue_id, page_no, sequence, text_link, img_link)" 

    p = Page.create issue_id: issue_id, page_no: page_no, sequence: sequence, text_link: text_link, img_link: img_link
  end

  def pp_ok(s)
    pp s if @print_ok
  end

end