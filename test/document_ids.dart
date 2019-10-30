/// A list of valid document ids to test, which might have potential
/// to causing bugs.
///
/// This file is UTF-8 encoded
const documentValidIds = [
  r' with spaces ',
  '\twith\ttabs\t',
  r'../',
  r'/with-leading-slash',
  r'LOWERCASE',
  r'lowercase',
  r'with%25percent%252F',
  r'with-encoded-question-mark%3F',
  r'with-encoded-trailing-slash%2F',
  r'with-mid/dle-slash',
  r'with-question-mark?',
  r'with-trailing-slash/',
  r'Привет', // "Hello" in Russian
  r'مرحبا', // "Hello" in Arabic
  r'你好', // "Hello" in Chinese
];
