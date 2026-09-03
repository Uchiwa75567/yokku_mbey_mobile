import 'package:flutter/material.dart';

class BuyerAddressData {
  const BuyerAddressData({
    required this.name,
    required this.region,
    required this.city,
    required this.neighborhood,
    required this.details,
    required this.phone,
    required this.icon,
    required this.accentColor,
    required this.backgroundColor,
    this.isPrimary = false,
  });

  final String name;
  final String region;
  final String city;
  final String neighborhood;
  final String details;
  final String phone;
  final IconData icon;
  final Color accentColor;
  final Color backgroundColor;
  final bool isPrimary;

  BuyerAddressData copyWith({
    String? name,
    String? region,
    String? city,
    String? neighborhood,
    String? details,
    String? phone,
    IconData? icon,
    Color? accentColor,
    Color? backgroundColor,
    bool? isPrimary,
  }) {
    return BuyerAddressData(
      name: name ?? this.name,
      region: region ?? this.region,
      city: city ?? this.city,
      neighborhood: neighborhood ?? this.neighborhood,
      details: details ?? this.details,
      phone: phone ?? this.phone,
      icon: icon ?? this.icon,
      accentColor: accentColor ?? this.accentColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}
