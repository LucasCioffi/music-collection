class ListeningSession
  attr_accessor :input, :output, :test_env

  def initialize(input = $stdin, output = $stdout, test_env = false)
    @input = input
    @output = output
    @test_env = test_env
    @album_titles_hash = {}
  end

  def log(message)
    self.output.puts message if test_env # catch all messages in the logger so we can test them with RSpec
    puts message # include the standard `puts` so the users can read the output and interact with the prompts
  end

  def commence
    input = prompt(test_env ? '' : '> ')
    arguments = input.split(' "').map{ |x| x.gsub('"', '') }
    command = arguments.shift
    if command == 'add'
      add_album(arguments[0], arguments[1])
    elsif command == 'play'
      play(arguments[0])
    elsif command == 'show all'
      show_all(artist_name: nil, played: nil, show_status: true)
    elsif command == 'show unplayed'
      show_all(artist_name: nil, played: false, show_status: false)
    elsif command == 'show all by'
      show_all(artist_name: arguments[0], played: nil, show_status: true)
    elsif command == 'show unplayed by'
      show_all(artist_name: arguments[0], played: false, show_status: false)
    elsif command == 'quit'
      quit
    elsif command == 'help'
      help
    else
      self.log "We didn't recognize your command.  Please try again, or type \"help\"."
    end
    self.commence unless @quit
  end

  def prompt(*args)
    print(*args)
    self.input.gets.chomp
  end

  def add_album(album_title, artist_name)
    if !artist_name
      self.log "The data must be in this format: add \"title\" \"artist\""
      return
    end
    if @album_titles_hash[album_title]
      self.log "There is already an album with that title."
      return
    end
    self.log "Added \"#{album_title}\" by #{artist_name}"
    @album_titles_hash[album_title] = Album.new(album_title, artist_name)
  end

  def play(album_title)
    album = @album_titles_hash[album_title]
    if album
      album.played = true
      @album_titles_hash[album_title] = album
      self.log "You're listening to \"#{album_title}\""
    else
      self.log "We didn't find that song."
    end
  end

  def show_all(artist_name: , played: , show_status:)
    @album_titles_hash.each do |album_title, album|
      next if artist_name && album.artist_name != artist_name
      show_album(album, show_status) if played.nil? || album.played == played
    end
  end

  def show_album(album, show_status)
    played = album.played ? 'played' : 'unplayed'
    output = "\"#{album.title}\" by #{album.artist_name}"
    output += " (#{played})" if show_status
    self.log output
  end

  def quit
    self.log "Bye!"
    @quit = true
  end

  def help
    self.log %(
      Available commands:
      add "$title" "$artist"
      play "$title"
      show all
      show unplayed
      show all by "$artist"
      show unplayed by "$artist"
      quit
    )
  end
end

class Album
  attr_accessor :listening_session, :title, :artist_name, :played

  def initialize(title, artist_name)
    @title = title
    @artist_name = artist_name
    @played = false
  end
end
