import 'package:get/get.dart';
import 'package:bytore/core/constants/constants.dart';

class StoresController extends GetxController {
  final List<Map<String, dynamic>> allStores = [
    {
      'name': 'عالم التقنية',
      'logo': 'https://cdn-icons-png.flaticon.com/512/3067/3067260.png',
      'category': 'إلكترونيات ولابتوبات',
      'rating': 4.8,
      'isVerified': true,
      'color': kSecondaryColor,
    },
    {
      'name': 'آفاق الكمبيوتر',
      'logo': 'https://cdn-icons-png.flaticon.com/512/2586/2586488.png',
      'category': 'شاشات وقطع هاردوير',
      'rating': 4.5,
      'isVerified': true,
      'color': kSecondaryColor,
    },
    {
      'name': 'مركز الحلول',
      'logo': 'https://cdn-icons-png.flaticon.com/512/27/27130.png',
      'category': 'إكسسوارات وملحقات',
      'rating': 4.9,
      'isVerified': false,
      'color': kSecondaryColor,
    },
    {
      'name': 'المتجر الذكي',
      'logo': 'https://cdn-icons-png.flaticon.com/512/2906/2906231.png',
      'category': 'أجهزة ذكية وساعات',
      'rating': 4.2,
      'isVerified': true,
      'color': kSecondaryColor,
    },
    {
      'name': 'كمبيوتك',
      'logo': 'https://cdn-icons-png.flaticon.com/512/2171/2171344.png',
      'category': 'صيانة وقطع غيار',
      'rating': 4.7,
      'isVerified': true,
      'color': kSecondaryColor,
    },
    {
      'name': 'متجر النخبة',
      'logo': 'https://cdn-icons-png.flaticon.com/512/2888/2888407.png',
      'category': 'برمجيات وألعاب',
      'rating': 4.6,
      'isVerified': false,
      'color': kSecondaryColor,
    },
  ];

  var filteredStores = <Map<String, dynamic>>[].obs;
  var searchText = "".obs;

  @override
  void onInit() {
    super.onInit();
    filteredStores.assignAll(allStores);
  }

  void filterStores(String query) {
    searchText.value = query;
    if (query.isEmpty) {
      filteredStores.assignAll(allStores);
    } else {
      filteredStores.assignAll(allStores.where((store) => 
        store['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
        store['category'].toString().toLowerCase().contains(query.toLowerCase())
      ).toList());
    }
  }
}
