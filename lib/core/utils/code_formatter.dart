/// Utility helpers for formatting voucher or purchase codes for display.
String sanitizedVoucherCode(String? code) {
  if (code == null) return '';

  const prefix = 'PURCHASE:';
  if (code.startsWith(prefix)) {
    return code.substring(prefix.length);
  }

  return code;
}





