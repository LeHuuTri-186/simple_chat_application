String escapeSpecialCharacters(String input) {
  // List of special characters that should be escaped
  final specialChars = RegExp(r'[-[\]{}()*+?.,\\^$|#\s]');

  // Replace each special character with the escaped version
  return input.replaceAllMapped(specialChars, (match) => '\\${match[0]}');
}
