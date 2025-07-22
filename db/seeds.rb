# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require 'csv'
require 'net/http'
require 'json'
require 'uri'

def fetch_country_data(isocode)
  base_url = "https://public.opendatasoft.com/api/explore/v2.1/catalog/datasets/countries-codes/records"
  params = {
    where: "iso2_code=\"#{isocode}\""
  }

  uri = URI(base_url)
  uri.query = URI.encode_www_form(params)

  response = Net::HTTP.get_response(uri)

  if response.code == '200'
    data = JSON.parse(response.body)
    records = data['results']

    if records && records.any?
      record = records.first

      return {
        name: record['label_en'],
        geo_point_2d: record['geo_point_2d']
      }
    end
  end

  nil
rescue => e
  puts "Error fetching country #{isocode}: #{e.message}"
  nil
end

def extract_artists(artists_string)
  return [] if artists_string.blank?

  artists = artists_string.split(',').map(&:strip).reject(&:blank?)

  return artists
end

def determine_primary_artist(artists_array)
  return artists_array.first
end

def determine_featured_artists(artists_array)
  return artists_array[1..-1] || []
end

csv_file_path = Rails.root.join('db', 'universal_top_spotify_songs.csv')

puts "Starting seed process..."

# First pass: Create all countries
puts "Creating countries..."
country_codes = Set.new
CSV.foreach(csv_file_path, headers: true) do |row|
  country_codes << row['country'] if row['country'].present?
end

country_codes.each do |iso_code|
  next if iso_code.blank?

  begin
    country_data = fetch_country_data(iso_code)
    if country_data
      country = Country.find_or_initialize_by(iso_code: iso_code)
      country.name = country_data[:name]
      country.geopoint = "#{country_data[:geo_point_2d]["lon"]},#{country_data[:geo_point_2d]["lat"]}"

      if country.save
        puts "Country saved: #{country.name} (#{iso_code})"
      else
        puts "Failed to save country: #{iso_code} - #{country.errors.full_messages.join(', ')}"
      end
    else
      puts "No data found for #{iso_code}"
    end
  rescue => e
    puts "Error processing country #{iso_code}: #{e.message}"
  end
end

# Second pass: Create tracks, artists, albums, and relationships
puts "Processing tracks and artists..."
imports = 0
failed_imports = 0

CSV.foreach(csv_file_path, headers: true) do |row|
  begin
    # Find country
    country = Country.find_by(iso_code: row['country'])
    unless country
      puts "Country not found: #{row['country']}"
      failed_imports += 1
      next
    end

    # Extract and process artists
    artists = extract_artists(row['artists'])
    if artists.empty?
      puts "No artists found for track: #{row['name']}"
      failed_imports += 1
      next
    end

    primary_artist_name = determine_primary_artist(artists)
    featured_artists_names = determine_featured_artists(artists)

    # Create or find primary artist
    primary_artist = Artist.find_or_create_by(name: primary_artist_name)
    if primary_artist.persisted?
      puts "Primary artist processed: #{primary_artist.name}"
    else
      puts "Failed to save primary artist: #{primary_artist_name} - #{primary_artist.errors.full_messages.join(', ')}"
      failed_imports += 1
      next
    end

    # Create or find album
    album = Album.find_or_initialize_by(title: row['album_name'])
    album.release_date = row['album_release_date']
    album.primary_artist_id = primary_artist.id

    if album.save
      puts "Album processed: #{album.title}"
    else
      puts "Failed to save album: #{row['album_name']} - #{album.errors.full_messages.join(', ')}"
      failed_imports += 1
      next
    end

    # Create or find track
    track = Track.find_or_initialize_by(name: row['name'], spotify_id: row['spotify_id'])
    track.duration_ms = row['duration_ms']
    track.danceability = row['danceability']
    track.energy = row['energy']
    track.key = row['key']
    track.mode = row['mode']
    track.tempo = row['tempo']
    track.time_signature = row['time_signature']
    track.album_id = album.id
    track.primary_artist_id = primary_artist.id

    if track.save
      puts "Track processed: #{track.name}"
    else
      puts "Failed to save track: #{row['name']} - #{track.errors.full_messages.join(', ')}"
      failed_imports += 1
      next
    end

    # Create primary artist relationship
    track_artist = TrackArtist.find_or_initialize_by(track_id: track.id, artist_id: primary_artist.id)
    track_artist.is_primary = true

    if track_artist.save
      puts "Primary track-artist relationship created: #{track.name} - #{primary_artist.name}"
    else
      puts "Failed to save primary track-artist relationship: #{track_artist.errors.full_messages.join(', ')}"
    end

    # Create featured artists relationships
    featured_artists_names.each do |featured_artist_name|
      featured_artist = Artist.find_or_create_by(name: featured_artist_name)

      if featured_artist.persisted?
        featured_track_artist = TrackArtist.find_or_initialize_by(track_id: track.id, artist_id: featured_artist.id)
        featured_track_artist.is_primary = false

        if featured_track_artist.save
          puts "Featured track-artist relationship created: #{track.name} - #{featured_artist.name}"
        else
          puts "Failed to save featured track-artist relationship: #{featured_track_artist.errors.full_messages.join(', ')}"
        end
      else
        puts "Failed to save featured artist: #{featured_artist_name} - #{featured_artist.errors.full_messages.join(', ')}"
      end
    end

    # Create daily ranking if we have the necessary data
    if row['daily_rank'].present? && row['popularity'].present? && row['snapshot_date'].present?
      daily_ranking = DailyRanking.find_or_initialize_by(
        track_id: track.id,
        country_id: country.id,
        snapshot_date: row['snapshot_date']
      )
      daily_ranking.daily_rank = row['daily_rank']
      daily_ranking.popularity = row['popularity']

      if daily_ranking.save
        puts "Daily ranking processed: #{track.name} - #{country.name} - Rank #{daily_ranking.daily_rank}"
      else
        puts "Failed to save daily ranking: #{daily_ranking.errors.full_messages.join(', ')}"
      end
    end

    imports += 1
    puts "Successfully imported record #{imports}"

  rescue => e
    puts "Error processing row: #{e.message}"
    puts "Row data: #{row.to_h}"
    failed_imports += 1
  end
end

puts "\n=== Seed Summary ==="
puts "Total successful imports: #{imports}"
puts "Total failed imports: #{failed_imports}"
puts "Total countries created: #{Country.count}"
puts "Total artists created: #{Artist.count}"
puts "Total albums created: #{Album.count}"
puts "Total tracks created: #{Track.count}"
puts "Total track-artist relationships: #{TrackArtist.count}"
puts "Total daily rankings: #{DailyRanking.count}"
puts "Seed process completed!"