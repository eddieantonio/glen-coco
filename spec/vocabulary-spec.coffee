Vocabulary = require '../lib/vocabulary'

describe 'Vocabulary', ->
  vocab = null

  beforeEach ->
    vocab = new Vocabulary

  it 'should start empty', ->
    expect(vocab.length).toBe 0


  describe '::vivify', ->
    it 'increases the count when new words are vivified', ->
      vocab.vivify 'fhqwhgads'
      expect(vocab.length).toBe 1

      vocab.vivify 'herp'
      expect(vocab.length).toBe 2

    it 'does not allow insertion of the empty string', ->
      expect( ->
        vocab.vivify('')
      ).toThrow()

    it 'returns a non-zero integer', ->
      value = vocab.vivify('-module')
      expect(vocab.length).toBe 1
      expect(value).toBeGreaterThan 0

    it 'handles UTF-8 characters', ->
      value = vocab.vivify 'ಠ_ಠ'
      expect(value).toBeGreaterThan 0

    it 'throws if a new special token is inserted', ->
      expect( ->
        vocab.vivify '\x17goobidigoo'
      ).toThrow()


  describe '::lookup', ->
    it 'returns undefined for undefined terms', ->
      expect(vocab.lookup('enoch')).toBeUndefined()

    it 'returns identifiers for special terms', ->
      expect(vocab.lookup('\x17newline')).toBeLessThan 1
      expect(vocab.lookup('\x17start')).toBeLessThan 1
      expect(vocab.lookup('\x17unk')).toBeLessThan 1
      expect(vocab.lookup('\x17indent')).toBeLessThan 1
      expect(vocab.lookup('\x17dedent')).toBeLessThan 1

    it 'throws an error when looking up the empty string', ->
      expect( ->
        vocab.lookup('')
      ).toThrow()


  it 'returns the same IDs for old terms', ->
    # A real token sequence, with duplicate tokens.
    tokens = [
      'for', 'i', 'in', 'range', '(', '10', ')', ':', '\x17newline',
      '\x17indent', 'print', '(', 'i', ')'
    ]

    # Vivify everything in the input.
    vivifyResult = tokens.map(vocab.vivify.bind(vocab))

    # Because of the duplicate tokens, there should be less tokens in the
    # vocabulary.
    expect(vocab.length).toBeLessThan tokens.length

    # If we lookup all the tokens again, we should get the exact same results
    # as vifify.
    expect(tokens.map(vocab.lookup.bind(vocab))).toEqual vivifyResult

  it 'it can store and retrieve UTF-8 strings', ->
    identifier = 'π'

    vocab.vivify 'dummy_token'
    vocab.vivify identifier

    expect(vocab.lookup(identifier)).toBeGreaterThan 1
    
    dummyValue = vocab.lookup 'dummy_token'
    expect(dummyValue).toBeDefined
    expect(vocab.lookup(identifier)).not.toBe dummyValue


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


