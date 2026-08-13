import 'dart:convert';
import 'dart:io';

/// Gera strings ofuscadas para `lib/app/constants/api_keys.dart`
///
/// Uso:
///   dart run tool/obfuscate_key.dart "ca-app-pub-xxx/banner" ad
///   dart run tool/obfuscate_key.dart "AIzaSy..." gemini
void main(List<String> args) {
  if (args.length < 2) {
    stderr.writeln('Uso: dart run tool/obfuscate_key.dart "<valor>" <ad|gemini>');
    exit(1);
  }

  final plain = args[0];
  final type = args[1].toLowerCase();
  final key = type == 'gemini' ? 0x5A : 0x3C;

  final encoded = base64.encode(utf8.encode(plain).map((b) => b ^ key).toList());
  stdout.writeln('Tipo: $type (XOR ${key.toRadixString(16)})');
  stdout.writeln('Ofuscado: $encoded');
}
