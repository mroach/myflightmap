require 'net/http'
require 'uri'
require 'countries'
require 'csv'
require 'logging'

TEMP_FILE = 'airlines.csv'
TEMP_FILE_PATH = File.join(ENV['TMPDIR'], TEMP_FILE)

DATA_URL = 'https://sourceforge.net/p/openflights/code/HEAD/tree/openflights/data/airlines.dat?format=raw'

logger ||= Logger.new(STDOUT)

# Download the file if it doesn't already exist
if !File.exists?(TEMP_FILE_PATH)
  %x[curl -L -o #{TEMP_FILE_PATH} "#{DATA_URL}"]
  puts "Downloading to #{TEMP_FILE_PATH}"
else
  puts "#{TEMP_FILE_PATH} already exists"
end

irregular_country_names = {
  'Burma'                                  => 'MM',
  'Canadian Territories'                   => 'CA',
  'Congo (Kinshasa)'                       => 'CD',
  'Democratic People\'s Republic of Korea' => 'KP',
  'Hong Kong SAR of China'                 => 'HK',
  'Ivory Coast'                            => 'CI',
  'Lao Peoples Democratic Republic'        => 'LA',
  'Republic of Korea'                      => 'KR',
  'Republic of the Congo'                  => 'CG',
  'Reunion'                                => 'RE',
  'South Korea'                            => 'KR'
}

# Columns
# 0: Internal ID (ignore)
# 1: Name
# 2: Alias (e.g. "ANA" for "All Nipppon Airways")
# 3: IATA (e.g. "NH")
# 4: ICAO (e.g. "ANA")
# 5: Callsign (e.g. "ALL NIPPON")
# 6: Country name (e.g. "Japan")
# 7: Active. "Y" for active or recently active, "N" for defunct
#
# Note: Blanks are stored as \N for the null character
# More info: http://openflights.org/data.html

airlines = []
CSV.foreach(TEMP_FILE_PATH) do |row|
  next if row[7] != 'Y'  # Only include active airports
  next if row[3].empty?  #
  next unless row[3].match('^[A-Z0-9]{2}$')

  country_name = row[6]

  # skip cargo airlines. SQ specifically messed us up
  next if row[1].match(/\bCargo\b/i)

  if irregular_country_names.has_key?(country_name)
    country = Country[irregular_country_names[country_name]]
  else
    country = Country.find_country_by_name(country_name)
  end

  if country.nil?
    logger.warn "Unknown country #{country_name} for '#{row[3]} #{row[1]}'"
    country = '??'
  else
    country = country.alpha2
  end

  airlines.push({
                  iata_code: row[3],
                  icao_code: row[4] == '\\N' ? nil : row[4],
                  name:      row[1],
                  country:   country
                })
end

airlines.sort_by! { |a| a[:iata_code] }
airlines.uniq! { |a| a[:iata_code] }

logger.info "Creating #{airlines.size} airlines"

Airline.create(airlines)

logger.info 'Done'
