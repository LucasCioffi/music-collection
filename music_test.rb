require 'rspec/autorun'
require_relative 'music.rb'

RSpec.describe ListeningSession do
  let(:output) { StringIO.new }

  def setup_app(input_string)
    input = StringIO.new(input_string)
    described_class.new(input, output, true)
  end

  describe '#commence' do
    subject { setup_app(input_string) }

    context "when user adds a new album" do
      let(:input_string) do
        ['add "Ride the Lightning" "Metallica\n"', 'quit'].map{ |command| command + "\n" }.join
      end

      it 'saves the album and says "Bye!"' do
        subject.commence
        expect(output.string).to include 'Added "Ride the Lightning" by Metallica'
        expect(output.string).to include 'Bye!'
      end
    end

    context "when user adds two albums with the same title" do
      let(:input_string) do
        ['add "Ride the Lightning" "Metallica\n"','add "Ride the Lightning" "Metallica\n"', 'quit'].map{ |command| command + "\n" }.join
      end

      it 'shows an error message' do
        subject.commence
        expect(output.string.scan(/"Ride the Lightning" by Metallica/).size).to eq 1
        expect(output.string).to include 'There is already an album with that title.'
      end
    end

    context "when user attempts to add a album with a missing argument" do
      let(:input_string) do
        ['add "Ride the Lightning\n"', 'quit'].map{ |command| command + "\n" }.join
      end

      it 'displays an error message' do
        subject.commence
        expect(output.string).to include 'The data must be in this format: add "title" "artist"'
      end
    end

    context "when user shows all albums" do
      let(:input_string) do
        [
          'add "Ride the Lightning" "Metallica"',
          'add "Licensed to Ill" "Beastie Boys"',
          'show all',
          'quit'
        ].map{ |command| command + "\n" }.join
      end

      it 'all albums are visible' do
        subject.commence
        expect(output.string).to include '"Ride the Lightning" by Metallica (unplayed)'
        expect(output.string).to include '"Licensed to Ill" by Beastie Boys (unplayed)'
      end
    end

    context "when user plays a album" do
      let(:input_string) do
        [
          'add "Ride the Lightning" "Metallica"',
          'add "Licensed to Ill" "Beastie Boys"',
          'play "Licensed to Ill"',
          'show unplayed',
          'quit'
        ].map{ |command| command + "\n" }.join
      end

      it 'the album is marked as played' do
        subject.commence
        expect(output.string).to include 'You\'re listening to "Licensed to Ill'
        # the unplayed album is visible twice, once when it is saved and then after `show unplayed`
        expect(output.string.scan(/"Ride the Lightning" by Metallica/).size).to eq 2
      end
    end

    context "when user searches for all albums by an artist" do
      let(:input_string) do
        [
          'add "Ride the Lightning" "Metallica"',
          'add "Licensed to Ill" "Beastie Boys"',
          'show all by "Beastie Boys"',
          'quit'
        ].map{ |command| command + "\n" }.join
      end

      it 'all albums by that artist are returned' do
        subject.commence
        expect(output.string.scan(/"Ride the Lightning" by Metallica/).size).to eq 1
        expect(output.string.scan(/Metalica \(unplayed\)/).size).to eq 0
        expect(output.string.scan(/Beastie Boys \(unplayed\)/).size).to eq 1
      end
    end

    context "when user searches for all unplayed albums by an artist" do
      let(:input_string) do
        [
          'add "Ride the Lightning" "Metallica"',
          'add "Licensed to Ill" "Beastie Boys"',
          'add "Pauls Boutique" "Beastie Boys"',
          'play "Licensed to Ill"',
          'show unplayed by "Beastie Boys"',
          'quit'
        ].map{ |command| command + "\n" }.join
      end

      it 'returns all albums by that artist' do
        subject.commence
        # these albums are shown only once, when they are saved
        expect(output.string.scan(/"Ride the Lightning" by Metallica/).size).to eq 1
        expect(output.string.scan(/"Licensed to Ill" by Beastie Boys/).size).to eq 1
        # this album is shown once when saved and once for `show unplayed by "Beastie Boys"`
        expect(output.string.scan(/"Pauls Boutique" by Beastie Boys/).size).to eq 2
      end
    end
  end
end
