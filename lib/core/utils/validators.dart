class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email wajib diisi';
    final re = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w]{2,4}$');
    if (!re.hasMatch(value.trim())) return 'Format email tidak valid';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password wajib diisi';
    if (value.length < 6) return 'Password minimal 6 karakter';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Konfirmasi password wajib diisi';
    if (value != password) return 'Password tidak cocok';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nama wajib diisi';
    if (value.trim().length < 3) return 'Nama minimal 3 karakter';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nomor HP wajib diisi';
    final re = RegExp(r'^(\+62|62|0)8[1-9][0-9]{6,10}$');
    if (!re.hasMatch(value.trim())) return 'Format nomor HP tidak valid';
    return null;
  }

  static String? address(String? value) {
    if (value == null || value.trim().isEmpty) return 'Alamat wajib diisi';
    if (value.trim().length < 10) return 'Alamat terlalu pendek';
    return null;
  }
}
