import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nice/model/review_model.dart';

class ReviewsController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  // قائمة التقييمات المكتملة
  var reviewedList = <ReviewModel>[
    ReviewModel(
      productName: 'آيفون 15 برو ماكس',
      date: '12 ديسمبر 2025',
      rating: 5,
      comment: 'جهاز رائع جداً وتوصيل سريع من متجر محسوب، أنصح به بشدة!',
      icon: Icons.phone_iphone,
    ),
    ReviewModel(
      productName: 'سماعة سوني WH-1000XM5',
      date: '05 ديسمبر 2025',
      rating: 4,
      comment: 'عزل الصوت ممتاز ولكن السعر مرتفع قليلاً.',
      icon: Icons.headphones,
    ),
  ].obs;

  // قائمة بانتظار التقييم
  var pendingList = <ReviewModel>[
    ReviewModel(
      productName: 'شاحن سريع 65 واط',
      date: 'تم التوصيل في 28 ديسمبر',
      icon: Icons.power,
      isPending: true,
    ),
    ReviewModel(
      productName: 'ماوس لوجيتيك MX Master 3',
      date: 'تم التوصيل في 25 ديسمبر',
      icon: Icons.mouse,
      isPending: true,
    ),
  ].obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}