                    ],
                    if (email != null && email != 'غير معروف') ...[
                      const SizedBox(width: 10),
                      const Icon(Icons.person_outline_rounded,
                          size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(email,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 11)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForType(String type) {
    if (type.contains('فلترة')) return Icons.public_off_rounded;
    if (type.contains('APK')) return Icons.android_rounded;
    if (type.contains('اختبار')) return Icons.warning_amber_rounded;
    return Icons.notifications_active_rounded;
  }

  Color _colorForType(String type) {
    if (type.contains('اختبار')) return AppColors.warning;
    return AppColors.accent;
  }
}
