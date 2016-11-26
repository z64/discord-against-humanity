require 'rest-client'
require 'json'

module UrbanDictionary

  class Definition
    # @return [String] text of the definition
    attr_reader :definition
    alias text definition

    # @return [String] the word defined
    attr_reader :word

    # @return [Integer] thumbs up count
    attr_reader :thumbs_up

    # @return [Integer] thumbs down count
    attr_reader :thumbs_down

    # @return [String] author
    attr_reader :author

    # @return [Integer] definition id
    attr_reader :defid
    alias id defid

    # @return [String] definition url
    attr_reader :permalink
    alias url permalink

    # @return [String] example of the word in context
    attr_reader :example

    def initialize(data)
      @definition = data[:definition]
      @word = data[:word]
      @thumbs_up = data[:thumbs_up]
      @thumbs_down = data[:thumbs_down]
      @author = data[:author]
      @defid = data[:defid]
      @permalink = data[:permalink]
      @example = data[:example]
    end
  end

  module_function

  # @param term [String] term to look up
  # @return [Array<Definition>] an array of definitions for the term
  def define(term)
    response = API.define(term)
    response[:list].map { |d| Definition.new d }
  end

  # @return [Array<Definition>] an array of definitions for the term
  def random
    response = API.random
    response[:list].map { |d| Definition.new d }
  end

  module API
    API_BASE = 'http://api.urbandictionary.com'
    API_VERSION = 'v0'

    module_function

    def get(path = '', params = {})
      response = RestClient.get "#{API_BASE}/#{API_VERSION}/#{path}", params: params
      JSON.parse response, symbolize_names: true
    end

    def define(term)
      get 'define', { term: term }
    end

    def random
      get 'random'
    end
  end
end
