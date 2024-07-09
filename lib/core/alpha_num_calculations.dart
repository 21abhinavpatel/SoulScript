int alphaNumToNum(String alpha) {
  const chars =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
  int num = 0;
  for (int i = 0; i < alpha.length; i++) {
    int value = chars.indexOf(alpha[i]);
    num = num * 62 + value;
  }
  return num;
}

String numToAlphaNum(int num, int digits) {
  const chars =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
  String result = '';
  if (num == 0) {
    return result.padLeft(digits, '0');
  }
  while (num > 0) {
    int remainder = num % 62;
    result = chars[remainder] + result;
    num ~/= 62;
  }
  if (digits == 10) {
    return result;
  }
  return result.padLeft(digits, '0');
}
