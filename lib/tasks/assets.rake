require 'open-uri'
require 'digest/md5'
require 'base64'
require 'tempfile'

def download_airline_logo(code)
  # %s: IATA code in uppercase
  url = "http://www.gstatic.com/flights/airline_logos/35px/#{code}.png"
  airline = Airline.find_by iata_code: code

  begin
    open(url) do |h|
      data = h.read
      hash = Digest::MD5.hexdigest(data)
      if hash == "e87bf421246723966bda4a7775818be2" || hash == "bc330b6678df2b9efdf4ed7783666a8b"
        puts "Got the default blank tail image for '#{code}'. Not saving"
      else
        puts "Attaching #{url} to #{airline.name}"
        airline.logo = StringIO.new(data)
        airline.save
      end
    end
  rescue OpenURI::HTTPError => ex
    puts "ERROR: Failed to load image for #{code}: #{ex}"
  end
end

namespace :assets do

  desc "Flatter Google by borrowing their airline logos"
  task :get_airline_logos => :environment do

    codes = %w(
      0B 0D 2F 3K 3L 4M 4U 5J 5T 6A 6E 7F 7H 8M 8U 9K 9U 9W A3 A5 A9 AA AB AC AD AF AH
      AI AK AM AP AR AS AT AV AY AZ B2 B6 BA BB BD BE BG BI BL BR BT BV BW CA CD CF CI
      CM CO CX CY CZ D7 DE DG DL DN DY EI EK EN ET EW EY F7 F9 FB FD FI FJ FL FM FR FV
      FY FZ G3 G4 GA GF GK GR HA HG HU HV HY I2 I5 IB IG IR IT IY J9 JA JF JJ JK JL JM
      JP JQ JT JU JV JZ K2 K5 KA KC KE KF KL KM KQ KU KX LA LG LH LI LN LO LP LS LX LY
      MA MD ME MF MH MI MK MP MS MT MU MW MX NA NF NH NK NT NX NZ O6 OA OK OM OR OS OU
      OV OZ PC PD PG PK PQ PR PS PU PX QF QI QR QS QZ RB RE RG RI RJ RO S2 S3 S4 S5 S7
      SA SB SG SK SN SP SQ SS ST SU SV SW SX SY T4 TA TF TG TJ TK TN TO TP TR TS TT TU
      TX U2 U5 U6 UA UL UM UN UO US UT UU UX V2 VA VH VK VN VS VV VW VX VY W6 WF WP WS
      WW WY X3 XE XJ XK XL XQ YM YV Z2 ZB ZH ZI ZL
    )

    codes.each do |c|
      download_airline_logo(c)
    end
  end

  desc "Fill in missing logos from sister airlines"
  task :fill_sister_airline_logos => :environment do
    sisters = {
      'AK' => ["FD","QZ","D7","PQ","Z2","I5","XJ"],
      '3K' => ["BL","GK","JM","JQ"]
    }
    sisters.each do |src_code,dest_codes|
      src = Airline.find_by iata_code: src_code
      dest_codes.each do |c|
        dest = Airline.find_by iata_code: c
        h = File.open(src.logo.path)
        dest.logo = h
        dest.save
        h.close
      end
    end
  end
end
