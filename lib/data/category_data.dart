import 'package:flutter/material.dart';

class CategoryData {
  static const List<Map<String, dynamic>> categories = [
    {
      'name': 'الكل',
      'slug': 'all',
      'icon': Icons.grid_view_rounded,
      'image': 'https://images.unsplash.com/photo-1498049794561-7780e7231661?q=80&w=1000', // صورة تجميعية للتقنية
      'subcategories': []
    },
    {
      'name': 'لابتوبات',
      'slug': 'laptops',
      'icon': Icons.laptop_mac_rounded,
      'image': 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?q=80&w=1000', // صورة ماك بوك
      'subcategories': [
        {'name': 'الكل', 'slug': 'laptops', 'icon': Icons.laptop_mac},
        {'name': 'ألترا بوك', 'slug': 'ultrabook', 'icon': Icons.laptop_chromebook},
        {'name': 'جيمنج', 'slug': 'gaming_laptops', 'icon': Icons.sports_esports},
        {'name': 'ماك بوك', 'slug': 'macbook', 'icon': Icons.apple},
      ]
    },
    {
      'name': 'شاشات',
      'slug': 'monitors',
      'icon': Icons.monitor_rounded,
      'image': 'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?q=80&w=1000', // صورة شاشة احترافية
      'subcategories': [
        {'name': 'الكل', 'slug': 'monitors', 'icon': Icons.monitor},
        {'name': '4K', 'slug': '4k_monitors', 'icon': Icons.four_k},
        {'name': 'Curved', 'slug': 'curved_monitors', 'icon': Icons.screenshot_monitor},
        {'name': 'Gaming', 'slug': 'gaming_monitors', 'icon': Icons.gamepad},
      ]
    },
    {
      'name': 'سماعات',
      'slug': 'audio',
      'icon': Icons.headset_rounded,
      'image': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=1000', // صورة سماعة رأس
      'subcategories': [
        {'name': 'الكل', 'slug': 'audio', 'icon': Icons.headset},
        {'name': 'لاسلكية', 'slug': 'wireless', 'icon': Icons.bluetooth},
        {'name': 'سلكية', 'slug': 'wired', 'icon': Icons.settings_input_component},
        {'name': 'رياضية', 'slug': 'sports_audio', 'icon': Icons.directions_run},
      ]
    },
    {
      'name': 'طابعات',
      'slug': 'printers',
      'icon': Icons.print_rounded,
      'image': 'https://images.unsplash.com/photo-1612815154858-60aa4c59eaa6?q=80&w=1000', // صورة طابعة
      'subcategories': [
        {'name': 'الكل', 'slug': 'printers', 'icon': Icons.print},
        {'name': 'ليزر', 'slug': 'laser', 'icon': Icons.wb_iridescent},
        {'name': 'حبر', 'slug': 'inkjet', 'icon': Icons.invert_colors},
      ]
    },
    {
      'name': 'كاميرات',
      'slug': 'cameras',
      'icon': Icons.camera_alt_rounded,
      'image': 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=1000', // صورة كاميرا كانون
      'subcategories': [
        {'name': 'الكل', 'slug': 'cameras', 'icon': Icons.camera_alt},
        {'name': 'DSLR', 'slug': 'dslr', 'icon': Icons.camera_enhance},
        {'name': 'Mirrorless', 'slug': 'mirrorless', 'icon': Icons.camera},
        {'name': 'Action', 'slug': 'action_cam', 'icon': Icons.videocam},
      ]
    },
    {
      'name': 'إكسسوارات',
      'slug': 'accessories',
      'icon': Icons.mouse_rounded,
      'image': 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?q=80&w=1000', // صورة ماوس وكيبورد
      'subcategories': [
        {'name': 'الكل', 'slug': 'accessories', 'icon': Icons.mouse},
        {'name': 'ماوس', 'slug': 'mouse', 'icon': Icons.mouse_outlined},
        {'name': 'كيبورد', 'slug': 'keyboard', 'icon': Icons.keyboard},
        {'name': 'حقائب', 'slug': 'bags', 'icon': Icons.backpack},
      ]
    },
  ];
}