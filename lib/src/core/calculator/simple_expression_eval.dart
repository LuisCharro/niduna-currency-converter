double? evaluateExpression(String expression) {
  final trimmed = expression
      .replaceAll(' ', '')
      .replaceAll('×', '*')
      .replaceAll('÷', '/');
  if (trimmed.isEmpty) return null;

  final tokens = <String>[];
  final buffer = StringBuffer();
  for (var i = 0; i < trimmed.length; i++) {
    final ch = trimmed[i];
    if ('+-*/'.contains(ch)) {
      if (buffer.isNotEmpty) tokens.add(buffer.toString());
      buffer.clear();
      tokens.add(ch);
    } else {
      buffer.write(ch);
    }
  }
  if (buffer.isNotEmpty) tokens.add(buffer.toString());
  if (tokens.isEmpty) return null;

  var result = double.tryParse(tokens[0]);
  if (result == null) return null;

  var i = 1;
  while (i < tokens.length) {
    final op = tokens[i];
    i++;
    if (i >= tokens.length) break;
    final nextVal = double.tryParse(tokens[i]);
    if (nextVal == null) break;
    switch (op) {
      case '+':
        result = result! + nextVal;
      case '-':
        result = result! - nextVal;
      case '*':
        result = result! * nextVal;
      case '/':
        if (nextVal == 0) return null;
        result = result! / nextVal;
      default:
        return null;
    }
    i++;
  }
  return result;
}
