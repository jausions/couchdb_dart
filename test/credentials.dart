/// Credentials for tests. Each key is a username
/// and its value is a password.
const Map<String, String> credentials = {
  // Basic
  r'admin': r'abc123',

  // Special passwords
  r'with_colon': r':123:abc:',
  r'with_percent': r'hello%%25',
  r'with_ampersand': r'&amp;',
  r'with_at_sign': r'password@',
  r'with_slash': r'slash/',
  r'with_backslash': r'\0backslash',
  r'with_accent': r'àçɕéñțß',
  r'with_space': r'white space',

  // Special user names
//  r'with:colon': r'abc123',     // Not supported by CouchDB
//  r'withslash/': r'abc123',     // Not supported by CouchDB
//  r';withsemicolon': r'abc123', // Not supported by CouchDB
//  r'with = sign': r'abc123',    // Not supported by CouchDB
  r'with space': r'abc123',
  r'with%25cent': r'abc123',
  r'with&amp;': r'abc123',
  r'with-at-sign@': r'abc123',
  r'with\nbackslash': r'abc123',
  r'wïth_àçéñt': r'abc123',
//  r'wïţħ_àçɕéñțß': r'abc123', // Not supported by CouchDB
};
