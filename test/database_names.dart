/// A list of database names to test
///
/// The database names must be composed by following next rules:
///
///  -  Name must begin with a lowercase letter (a-z)
///  -  Lowercase characters (a-z)
///  -  Digits (0-9)
///  -  Any of the characters _, $, (, ), +, -, and /.
const databaseValidNames = [
  r'testf67f1e3018f8479394dec92b427b2d5d',
  r'test-with--hyphens-',
  r'test_with__underscores_',
  r'test$with$$dollar$signs$',
  r'test((with))parens)(',
  r'test+with+plus++',
  r'test-with--hypens-',
  r'test/with/slashes///',
  r'test_injection/_revs_limit',
  r'test_injection/_find',
];

const databaseInvalidNames = [
  r'_no-leading-underscore',
  r'0_no_leading_number',
  r'$_no_leadking_dollar_sign',
  r'(_no_leading_open_parens',
  r')_no_leading_close_parens',
  r'+_no_leading_plus_sign',
  r'-_no_leading_minus_sign',
  r'/_no_leading_slash',
  r'NO-UPPER_CASE',
  r'no-âçcèñțș',
  r'no space',
];