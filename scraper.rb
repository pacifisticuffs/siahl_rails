require 'rubygems'
require 'mechanize'

# global mechanize object
$a = Mechanize.new

# gets the schedule for a particular team
def get_schedule( url )
  $a.get( url ) do |page|
    tables = page.search( 'table' )

    tables.each do |table|
      rows = tables.search( 'tr' )
      rows.each do |row|
        cells = row.search( 'td' )
        if cells.any? then
          id    = clean_data(cells[0].text)
          date  = clean_data(cells[1].text)
          time  = clean_data(cells[2].text)
          team1 = clean_data(cells[6].text)
          team2 = clean_data(cells[8].text)
          puts 'Game %s: %s %s %s at %s' % [id, date, time, team1, team2]
        end
      end
    end
  end
end

# replaces html spaces (nbsp, #160) with regular spaces and strips them
def clean_data( data )
  data = data.gsub(/[[:space:]]/, ' ').gsub(/\s+/, ' ').strip
  return data
end

# get_schedule( 'http://stats.liahl.org/display-schedule.php?team=2034&season=27&tlev=0&tseq=0&league=1' )

# get details from a game
def get_game( url )
  $a.get( url ) do |page|
    tables = page.search( 'table' )

    visitor_players = tables[11]
    visitor_scoring = tables[15]
    visitor_penalties = tables[16]

    # puts '%s' % [visitor_players]

    home_players = tables[13]
    home_scoring = tables[17]
    home_penalties = tables[18]

    # puts '%s' % [home_players]
    parse_players( visitor_players )
    # parse_players( home_players )
    parse_penalties( visitor_penalties )
    parse_scoring( visitor_scoring )
      # table[11] = visitor
      # table[15] = visitor scoring
      # table[16] = visitor penalties
      # table[13] = home
      # table[17] = home scoring
      # table[18] = home penalties
  end
end

def parse_penalties( penalties )
  # penalties[1] = player number
  # penalties[2] = infraction
  # penalties[3] = length
  rows = penalties.search( 'tr' )
  rows.each do |row|
    cells = row.search( 'td' )
    if cells.any? then
      number = clean_data( cells[1].text )
      infraction = clean_data( cells[2].text )
      length = clean_data( cells[3].text )
      puts '#%s %s minutes for %s' % [number, length, infraction]
    end
  end
end

def parse_scoring( scores )
  rows = scores.search( 'tr' )
  rows.each do |row|
    cells = row.search( 'td' )
    if cells.any? then
      type = clean_data( cells[2].text )
      scorer = clean_data( cells[3].text )
      assist1 = clean_data( cells[4].text )
      assist2 = clean_data( cells[5].text )
      puts '%s goal by #%s, from %s and %s' % [type, scorer, assist1, assist2]
    end
  end
end

def parse_players( players )
  rows = players.search( 'tr' )
  rows.each do |row|
    cells = row.search( 'td' )
    if cells.any? then
      number = clean_data( cells[0].text )
      modifier = clean_data( cells[1].text )
      name = clean_data( cells[2].text )
      puts '#%s %s (%s)' % [number, name, modifier]

      if !cells[3].attributes[ 'colspan' ] then
        number = clean_data( cells[3].text )
        modifier = clean_data( cells[4].text )
        name = clean_data( cells[5].text )
        puts '#%s %s (%s)' % [number, name, modifier]
      end

    end
  end
end

# get_game( 'http://stats.liahl.org/oss-scoresheet?game_id=103515&mode=display' )

# Fetches all the teams and puts them in their division
def get_teams( url )
  $a.get( url ) do |page|
    tables = page.search( 'table' )
    if tables.any? then
      tables.each do |table|
        rows = table.search( 'tr' )
        if rows.any? then
          rows.each do |row|
            league = row.at( 'th[colspan] a[name]' )
            if league then
              league = clean_data( league.text )
              puts league
            else
              team = row.at( 'td a' )
              if team then
                puts '  %s' % clean_data( team.text )
              end
            end
          end
        end
      end
    end
  end
end

get_teams( 'http://stats.liahl.org/display-stats.php?league=1' )