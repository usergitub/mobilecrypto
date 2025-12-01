import 'package:flutter/material.dart';

class Country {
  final String name;
  final String code; // Code pays (ex: "CI", "SN")
  final String dialCode; // Indicatif téléphonique (ex: "+225")
  final String flagEmoji; // Emoji du drapeau
  final List<Color> flagColors; // Couleurs du drapeau pour affichage personnalisé

  const Country({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flagEmoji,
    required this.flagColors,
  });
}

// Liste des pays disponibles
final List<Country> availableCountries = [
  const Country(
    name: "Côte d'Ivoire",
    code: "CI",
    dialCode: "+225",
    flagEmoji: "🇨🇮",
    flagColors: [Color(0xFFF77F00), Color(0xFFFFFFFF), Color(0xFF009639)],
  ),
  const Country(
    name: "Burkina Faso",
    code: "BF",
    dialCode: "+226",
    flagEmoji: "🇧🇫",
    flagColors: [Color(0xFFEF2B2D), Color(0xFF009639), Color(0xFFFCD116)],
  ),
  const Country(
    name: "Cameroun",
    code: "CM",
    dialCode: "+237",
    flagEmoji: "🇨🇲",
    flagColors: [Color(0xFF007A5E), Color(0xFFCE1126), Color(0xFFFCD116)],
  ),
  const Country(
    name: "Gambie",
    code: "GM",
    dialCode: "+220",
    flagEmoji: "🇬🇲",
    flagColors: [Color(0xFFCE1126), Color(0xFF0C1C8C), Color(0xFF3A7728), Color(0xFFFFFFFF)],
  ),
  const Country(
    name: "Mali",
    code: "ML",
    dialCode: "+223",
    flagEmoji: "🇲🇱",
    flagColors: [Color(0xFF14B53A), Color(0xFFFCD116), Color(0xFFCE1126)],
  ),
  const Country(
    name: "Niger",
    code: "NE",
    dialCode: "+227",
    flagEmoji: "🇳🇪",
    flagColors: [Color(0xFF14B53A), Color(0xFFFFFFFF), Color(0xFFE05206)],
  ),
  const Country(
    name: "Ouganda",
    code: "UG",
    dialCode: "+256",
    flagEmoji: "🇺🇬",
    flagColors: [Color(0xFF000000), Color(0xFFFCDD09), Color(0xFFDE2910)],
  ),
  const Country(
    name: "Sierra Leone",
    code: "SL",
    dialCode: "+232",
    flagEmoji: "🇸🇱",
    flagColors: [Color(0xFF0072C6), Color(0xFFFFFFFF), Color(0xFF1EB53A)],
  ),
  const Country(
    name: "Sénégal",
    code: "SN",
    dialCode: "+221",
    flagEmoji: "🇸🇳",
    flagColors: [Color(0xFF00853F), Color(0xFFFCD116), Color(0xFFE31B23)],
  ),
];

