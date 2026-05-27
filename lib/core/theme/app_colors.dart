import 'package:flutter/material.dart';

/// Color palette for NotifyQ. Each reminder type has a dedicated color token
/// used consistently throughout the app (cards, icons, calendar dots).
class AppColors {
  AppColors._();

  // ── Brand ────────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFF22D3EE);
  static const Color accent = Color(0xFFFFD60A);

  // ── Reminder Type Colors ──────────────────────────────────────────────────────
  static const Color expense = Color(0xFFEF4444);       // Red
  static const Color subscription = Color(0xFFF97316);  // Orange
  static const Color birthday = Color(0xFF3B82F6);      // Blue
  static const Color insurance = Color(0xFFA855F7);     // Purple
  static const Color custom = Color(0xFF6B7280);        // Gray

  // ── Surfaces (Light) ─────────────────────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF8F9FE);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFF1F5FF);

  // ── Surfaces (Dark) ──────────────────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF0F0F1A);
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color cardDark = Color(0xFF16213E);

  // ── Text ─────────────────────────────────────────────────────────────────────
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);

  // ── Status ───────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ── Gradients ────────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF9333EA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkHeaderGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
