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
# get all issues
# construct db row for issues table
# create AR record issue object from xml data and save it
# get all pages in issues
# construct db row for pages table
# create AR record page object from xml data and save it
# end loop
# clean up file handling

# IMPLEMENTATION

class DailyXmlToDb_v2
  attr_accessor :db, :db_name, :xml_dir, :file_list, :doc, :yml_file, :yml, :print_ok, :publication, :pub_id

  def initialize(slug, testing)

    if testing == "testing"
      pp "TESTING..."
      @print_ok = true
    else
      @print_ok = false
    end

    pp "Slug is: #{slug}"

    # @pub_id = add_daily_publication
    @pub_id = add_daily_publication
 
    # set directory for xml files
    @xml_dir = "./tmp/xml_data/"

    # get list of xml files
    @xml_list = []
    @xml_list = get_flist

    pp_ok "File list:"
    pp_ok @xml_list

    # parse the files xml
    @xml_list.each { |f| parse_file_to_ar(f) }

  end # initialize

  # get file list
  # make xml dir the current directory
  def get_flist
    pp_ok "Started in directory #{Dir.pwd}"
    Dir.chdir(@xml_dir)
    pp_ok "Moved to directory #{Dir.pwd}"
    return Dir.glob("*.{xml}")
  end

  def parse_file_to_ar(f)
    pp_ok "STARTING PARSE for file #{f}..."

    @doc = Nokogiri::XML(File.open(f), 'UTF-8') do |config|
      config.options = Nokogiri::XML::ParseOptions::STRICT | Nokogiri::XML::ParseOptions::NOBLANKS
    end

    # Extend name space to include METS
    # The following actually modifies the xml, which we don't want. But it works.
    #ns = @doc.root.add_namespace_definition("xmlns:METS", "http://www.loc.gov/METS/")

    @NSMAP = { 
      "METS" => "http://www.loc.gov/METS/",
      "xlink" => "http://www.w3.org/1999/xlink",
      "MODS" => "http://www.loc.gov/mods/v3",
    }

    pp @NSMAP

    # @doc = @doc.xpath(@doc, "METS" => "http://www.loc.gov/METS/")

    # pp "Collection .first"
    # pp @doc.xpath("collection").first

    pp_ok "Current file is: #{f}"
    # issue information -------------
    # note: issue_id is autoincremented by the db
    # and we will want to select it from the last row created

    track_issue_keys = []
    key_separater = '-'

    issues_target = "//METS:mets[@TYPE='urn:library-of-congress:ndnp:mets:newspaper:issue']"

    # pp_ok "Issue one is:"
    # pp issues[0]

    # delete the entries
    Issue.where(ht_namespace: 'mdp', ht_barcode: File.basename(f, '.issue.mets.xml')).destroy


    @doc.xpath(issues_target, @NSMAP).each do |node1|

      print "."

      pp_ok "ISSUE INFO ------------------------------------------"
      
      hathitrust = node1.xpath(".//MODS:identifier[@type='hathitrust']/text()").to_s
      ht_namespace, ht_barcode = hathitrust.split(".", 2)

      pp_ok "hathitrust value is #{hathitrust}"
      pp_ok "ht_namespace is #{ht_namespace} and ht_barcode is #{ht_barcode}"

      volume = node1.xpath(".//MODS:detail[@type='volume']/MODS:number/text()").to_s
      pp_ok "volume value is #{volume}"

      issue_no = node1.xpath(".//MODS:detail[@type='issue']/MODS:number/text()").to_s
      pp_ok "issue_no value is #{issue_no}"

      edition = node1.xpath(".//MODS:detail[@type='edition']/MODS:number/text()").to_s
      pp_ok "edition value is #{edition}"

      date_issued = node1.xpath(".//MODS:dateIssued/text()").to_s
      pp_ok "dateIssued value is #{date_issued}"

      newspaper = node1.xpath("@LABEL").to_s
      newspaper = newspaper.split(",").first.strip
      pp_ok "newspaper is #{newspaper}"

      # Check for duplicate dates in array track_dates
      issue_sequence = 1
      issue_key_to_check = ht_namespace + key_separater + ht_barcode + key_separater + date_issued + key_separater + issue_sequence.to_s
      until ((track_issue_keys.bsearch { |id| id == issue_key_to_check}).nil?) do
        puts "\nWE HAVE A DUPLICATE OF: " + issue_key_to_check
        issue_sequence += 1
        issue_key_to_check = ht_namespace + key_separater + ht_barcode + key_separater + date_issued + key_separater + issue_sequence.to_s
      end

      track_issue_keys.push(issue_key_to_check).sort


      issue_id = add_data_issue(ht_namespace, ht_barcode, volume, issue_no, edition, date_issued, issue_sequence,  @pub_id)

      pp_ok "ISSUE ID IS: #{issue_id} and issue_sequence IS: #{issue_sequence}"

      # page information -------------
      # note: page_id is autoincremented by the db

      pages_target = ".//METS:structMap/METS:div[@TYPE='np:issue'][@DMDID='issueModsBib']/METS:div[@TYPE='np:page']"

      node1.xpath(pages_target, @NSMAP).each do |node2|

        pp_ok "PAGE INFO ------------------------------------------"

        # pp node2
        # pp_ok "issue_id value is #{issue_id}"

        page_no = node2['ORDERLABEL'].to_s
        pp_ok "page_no value is #{page_no}"

        sequence = node2['ORDER'].to_s.to_i
        pp_ok "sequence value is #{sequence}"

        text_link_a = node2.xpath("METS:mptr[1]", @NSMAP)
        text_link_b = text_link_a.xpath("@xlink:href", @NSMAP)
        pp_ok "text_link value is #{text_link_b}"

        img_link_a = node2.xpath("METS:mptr[2]", @NSMAP)
        img_link_b = img_link_a.xpath("@xlink:href", @NSMAP)
        pp_ok "text_link value is #{img_link_b}"
        
        add_data_page(issue_id, page_no, sequence, text_link_b, img_link_b)

      end # each page
    end # each issue


  puts "\nFile >#{f}< processed"

  end # parse_file_to_ar

  def add_daily_publication
    publication = Publication.find_or_create_by(slug: "the-michigan-daily") do |publication|
      publication.title = "The Michigan Daily"
      publication.info_link = "https://michigandaily.com"
    end
    
    # pp_ok "Publication record added or found, slug: #{p.slug}, title: #{p.title}, info_link: #{p.info_link}"

    publication.id
  end

  def add_data_issue(ht_namespace, ht_barcode, volume, issue_no, edition, date_issued, issue_sequence,  pub_id)
    pp_ok "issue row will be (hathitrust, volume, issue_no, edition, date_issued, newspaper)"

    i = Issue.create  ht_namespace: ht_namespace, ht_barcode: ht_barcode, volume: volume, issue_no: issue_no, edition: edition, date_issued: date_issued, issue_sequence: issue_sequence, publication_id: pub_id
    return i.id 
  end
  
  def add_data_page(issue_id, page_no, sequence, text_link, img_link)
    pp_ok "page row will be (issue_id, page_no, sequence, text_link, img_link)" 

    coordinates_link = text_link.to_s.gsub('TXT', 'WORDS')
    p = Page.create issue_id: issue_id, page_no: page_no, sequence: sequence, text_link: text_link, img_link: img_link, coordinates_link: coordinates_link
  end

  def pp_ok(s)
    pp s if @print_ok
  end

end # class DailyXmlToDb_v2