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
  attr_accessor :db, :db_name, :input_filename, :doc, :print_ok, :publication, :pub_id

  def initialize(publication_slug, input_filename, testing=nil)

    if testing
      pp "TESTING..."
      @print_ok = true
    else
      @print_ok = false
    end

    pp "Slug is: #{publication_slug}"

    @pub_id = add_daily_publication(publication_slug)
    @input_filename = input_filename

    import_data
 
  end # initialize

  def import_data
    pp_ok "STARTING PARSE for file #{@input_filename}..."

    @doc = Nokogiri::XML(File.open(@input_filename), 'UTF-8') do |config|
      config.options = Nokogiri::XML::ParseOptions::STRICT | Nokogiri::XML::ParseOptions::NOBLANKS
    end

    @NSMAP = { 
      "METS" => "http://www.loc.gov/METS/",
      "xlink" => "http://www.w3.org/1999/xlink",
      "MODS" => "http://www.loc.gov/mods/v3",
    }


    # issue information -------------
    # note: issue_id is autoincremented by the db
    # and we will want to select it from the last row created

    track_issue_keys = Hash.new(0)
    key_separator = '-'

    issues_target = "//METS:mets[@TYPE='urn:library-of-congress:ndnp:mets:newspaper:issue']"

    # pp_ok "Issue one is:"
    # pp issues[0]

    pp_ok "About to delete some issues"
    # delete the entries for all the volumes referenced in this XML
    volume_identifiers = {}
    @doc.xpath(issues_target, @NSMAP).each do |node1|
      volume_identifier = node1.xpath(".//MODS:identifier[@type='hathitrust']/text()").to_s
      volume_identifiers[volume_identifier] = true
    end
    volume_identifiers.keys.each do |volume_identifier|
      Issue.where(volume_identifier: volume_identifier).destroy_all
    end

    @doc.xpath(issues_target, @NSMAP).each do |node1|

      pp_ok "ISSUE INFO ------------------------------------------"
      
      volume_identifier = node1.xpath(".//MODS:identifier[@type='hathitrust']/text()").to_s

      pp_ok "volume_identifier value is #{volume_identifier}"

      volume = node1.xpath(".//MODS:detail[@type='volume']/MODS:number/text()").to_s
      pp_ok "volume value is #{volume}"

      issue_no = node1.xpath(".//MODS:detail[@type='issue']/MODS:number/text()").to_s
      pp_ok "issue_no value is #{issue_no}"

      edition = node1.xpath(".//MODS:detail[@type='edition']/MODS:number/text()").to_s
      pp_ok "edition value is #{edition}"

      date_issued = node1.xpath(".//MODS:dateIssued/text()").to_s
      pp_ok "dateIssued value is #{date_issued}"

      publication_title = node1.xpath("@LABEL").to_s
      if publication_title.blank?
        publication_title = 'The Michigan Daily'
      end
      publication_title = publication_title.split(",").first.strip
      pp_ok "publication_title is #{publication_title}"

      # Check for duplicate dates in array track_dates
      issue_key_to_check = [ volume_identifier, date_issued ].join(key_separator)
      track_issue_keys[issue_key_to_check] += 1
      
      variant = track_issue_keys[issue_key_to_check]
      issue_id = add_data_issue(volume_identifier, volume, issue_no, edition, date_issued, variant, publication_title)

      pp_ok "ISSUE ID IS: #{issue_id} and variant IS: #{variant}"

      # page information -------------
      # note: page_id is autoincremented by the db

      pages_target = ".//METS:structMap/METS:div[@TYPE='np:issue'][@DMDID='issueModsBib']/METS:div[@TYPE='np:page']"

      node1.xpath(pages_target, @NSMAP).each do |node2|

        pp_ok "PAGE INFO ------------------------------------------"

        # pp node2
        # pp_ok "issue_id value is #{issue_id}"

        page_no = node2['ORDERLABEL'].to_s
        pp_ok "page_no value is #{page_no}"

        issue_sequence = node2['ORDER'].to_s.to_i
        pp_ok "sequence value is #{issue_sequence}"

        page_label = node2['LABEL']
        if page_label
          page_label = page_label.to_s
        end

        # my $expr = $xpc->findvalue(q{METS:mptr[1]/@xlink:href}, $div);
        # my ( $volume_seq ) = ( $expr =~ m,.*//METS:div\[\@ORDER='(\d+)\'\]/METS:fptr, );
        # my $page_identifier = $objID . "-" . sprintf("%08d", $volume_seq);

        expr = node2.xpath('METS:mptr[1]/@xlink:href', @NSMAP).to_s
        # STDERR.puts "EXPR : #{expr}"
        volume_sequence = expr.match(/ORDER=.(\d+)./)[1].to_i
        basename = "%08d" % volume_sequence

        text_link = "TXT#{basename}"
        image_link = "IMG#{basename}"
        coordinates_link = "WORDS#{basename}"
        
        add_data_page(issue_id, page_no, issue_sequence, volume_sequence, image_link, text_link, coordinates_link, "#{volume_identifier}-#{basename}", page_label)

      end # each page
    end # each issue


  puts "\nFile >#{@input_filename}< processed"

  end # parse_file_to_ar

  def add_daily_publication(publication_slug)
    publication = Publication.find_or_create_by(slug: publication_slug) do |publication|
      publication.title = publication_slug.split("-").each {|word| word.capitalize!}.join (" ")
      # publication.info_link = "https://michigandaily.com"
    end
    
    # pp_ok "Publication record added or found, slug: #{p.slug}, title: #{p.title}, info_link: #{p.info_link}"

    publication.id
  end

  def add_data_issue(volume_identifier, volume, issue_no, edition, date_issued, variant, publication_title)

    i = Issue.create  volume_identifier: volume_identifier, volume: volume, issue_no: issue_no, edition: edition, date_issued: date_issued, variant: variant, publication_id: @pub_id, publication_title: publication_title
    return i.id 
  end
  
  def add_data_page(issue_id, page_no, issue_sequence, volume_sequence, image_link, text_link, coordinates_link, page_identifier, page_label)
    p = Page.create issue_id: issue_id, page_no: page_no, issue_sequence: issue_sequence, volume_sequence: volume_sequence, text_link: text_link, image_link: image_link, coordinates_link: coordinates_link, page_identifier: page_identifier, page_label: page_label
  end

  def pp_ok(s)
    pp s if @print_ok
  end

end # class DailyXmlToDb_v2