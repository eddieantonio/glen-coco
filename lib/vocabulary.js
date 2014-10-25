/**
 * Defines a vocabulary!
 */
module.exports = Vocabulary;

var SPECIAL_HEADER = '\x17';

/**
 * Is this overengineered?
 */
var specials = Object.create(Object.prototype, {
  unk:      {value:    0, enumerable: true },
  start:    {value:   -1, enumerable: true },
  newline:  {value:   -2, enumerable: true },
  indent:   {value:   -3, enumerable: true },
  dedent:   {value:   -4, enumerable: true }
});



/**
 * Maps words to unique integers.
 *
 * @constructor
 */
function Vocabulary() {
  var count = 0;

  this.table = {};

  this.nextID = function nextID() {
    return count += 1;
  };

  /* Define a `length` property like an array. */
  Object.defineProperty(this, 'length', {
    get: function () { return count; }
  });
}

Object.defineProperty(Vocabulary.prototype, 'special', {
  value: specials
});


/**
 * Internal: takes an array of terms, the current index in the term array, and
 * a vocabulary table, and looks up the term.
 */
function tableLookup(term, index, table) {
  var charsLeft, nextChar, nextTable, nextEntry;
  charsLeft = term.length - index;

  console.assert(charsLeft >= 1);


  nextChar = term[index];
  nextEntry = table[nextChar];

  if (!nextEntry) {
    return undefined;
  }

  nextTable = nextEntry.table;
  if (!nextTable) {
    return undefined;
  }

  if (charsLeft === 1) {
    /* Last character. Return the ID. */
    return nextEntry.id;
  } else {
    return tableLookup(term, index + 1, nextTable);
  }
}


/**
 * Returns the associated number with a vocabulary term. If the term is not in
 * the vocabulary, undefined is returned.
 */
Vocabulary.prototype.lookup = function lookup(term) {
  var termArray;

  /* Zero-string does not even make sense. */
  if (!term.length) {
    throw new Error('Cannot look-up empty string.');
  }

  /* Return a special character. */
  if (term.charAt(0) === SPECIAL_HEADER) {
    return this.special[term.substring(1)];
  }

  termArray = term.split('');
  return tableLookup(termArray, 0, this.table);
};


/**
 * Returns the number associated with a vocabulary term. If the term is not in
 * the vocabulary, it is added. A number is always added *UNLESS* a new
 * special term is added (which will fail).
 */
Vocabulary.prototype.vivfy = function vivify(term) {
  var value, termArray;

  /* If it's a special term, simply delegate to standard look-up. */
  if (term.charAt(0) === SPECIAL_HEADER) {
    value = this.lookup(term);
    if (value === undefined) {
      throw new Error('Cannot vivify a new special vocabulary term.');
    }
    return value;
  }

  termArray = term.split('');

  if (!termArray.length) {
    throw new Error('Requires a string with at least one character.');
  }

  return lookupOrInsert(termArray, this, this.nextID);
};


function lookupOrInsert(term, entry, getNextID) {
  var nextChar = term.shift();

  console.assert(entry !== undefined);
  console.assert(entry.table !== undefined);

  /* Reached the end. Create an ID here. */
  if (nextChar === undefined) {
    if (entry.id === undefined) {
      entry.id = getNextID();
    }
    return entry.id;
  }

  var nextEntry = entry.table[nextChar];

  if (nextEntry === undefined || nextEntry === null) {
    nextEntry = { table: {} };
    entry.table[nextChar] = nextEntry;
  }

  return lookupOrInsert(term, nextEntry, getNextID);
}


/*
 * The structure of the recursive structure is like this.
 *
 *  {
 *    table: {
 *        C: {
 *            table: { ... },
 *            id: blah
 *           }
 *      }
 *  }
 */
