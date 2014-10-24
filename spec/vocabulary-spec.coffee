Vocabulary = require '../lib/vocabulary'

describe 'Vocabulary', ->
  vocab = null

  beforeEach ->
    vocab = new Vocabulary

  it 'should start empty', ->
    expect(vocab.length).toBe 0


  describe '::vivfy', ->
    it 'increases the count when new words are vivified', ->
      vocab.vivfy 'fhqwhgads'
      expect(vocab.length).toBe 1

      vocab.vivfy 'herp'
      expect(vocab.length).toBe 2

  # TODO: UTF-8 in keys!

  describe '::lookup', ->
    it 'returns undefined for undefined terms', ->
      expect(vocab.lookup('enoch')).toBeUndefined()

    it 'returns identifiers for special terms', ->
      expect(vocab.lookup('\x17')).toBeUndefined()

    it 'returns unique identifiers for new terms'


  describe '.special', ->

    it 'has fixed values', ->
      expect(vocab.special.unk).toBeLessThan 1
      expect(vocab.special.start).toBeLessThan 1
      expect(vocab.special.newline).toBeLessThan 1
      expect(vocab.special.indent).toBeLessThan 1
      expect(vocab.special.dedent).toBeLessThan 1

    it 'is unmodifiable', ->
      original = vocab.special

      vocab.special.newline = 42
      expect(vocab.special).toBe original


