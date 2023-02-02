# frozen_string_literal: true

require_relative '../app'

RSpec.describe 'Scraper' do
  describe '#scraper_imdb' do
    it 'returns an array of 10 urls' do
      expect(scraper_imdb).to be_an_instance_of(Array)
      expect(scraper_imdb.size).to eq(10)
    end
  end

  describe '#scraper_movie' do
    it 'returns a hash with the movie details' do
      expect(scraper_movie('https://www.imdb.com/title/tt0111161/')).to be_an_instance_of(Hash)
    end
  end
end
