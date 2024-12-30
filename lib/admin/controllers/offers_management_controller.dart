import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:murafiq/core/constant/Constatnt.dart';
import 'package:murafiq/core/functions/errorHandler.dart';
import 'package:murafiq/main.dart';

class Offer {
  final String id;
  final String title;
  final double price;
  final String imageUrl;
  final String? description;
  final DateTime? createdAt;

  Offer({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    this.description,
    this.createdAt,
  });
  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['_id'],
      title: json['title'],
      price: double.parse(json['price'].toString()),
      imageUrl:
          '${serverConstant.serverUrl}/public/uploads/offers/${json['imageUrl'].split('/').last}',
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class OffersManagementController extends GetxController {
  File? imageFile;

  final TextEditingController searchController = TextEditingController();

  // Mock offers list for demonstration
  final RxList<Offer> _offers = <Offer>[
    // Offer(
    //   id: '1',
    //   title: 'سيارة مرسيدس للبيع',
    //   price: 50000.00,
    //   imageUrl:
    //       'https://images.unsplash.com/photo-1469285994282-454ceb49e63c?q=80&w=2071&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    //   description: 'سيارة مرسيدس بحالة ممتازة، موديل 2020، اللون أسود',
    //   createdAt: DateTime.now(),
    // ),
    // Offer(
    //   id: '2',
    //   title: 'شقة للإيجار في بنغازي',
    //   price: 25000.00,
    //   imageUrl:
    //       'https://plus.unsplash.com/premium_photo-1684175656320-5c3f701c082c?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    //   description: 'شقة مفروشة بالكامل، موقع مميز، 3 غرف نوم',
    //   createdAt: DateTime.now().subtract(Duration(days: 2)),
    // ),
  ].obs;

  RxList<Offer> get filteredOffers => _filteredOffers;
  final RxList<Offer> _filteredOffers = <Offer>[].obs;

  // Sorting and filtering options
  final RxString _currentSortOption = 'newest'.obs;
  final RxString _currentFilterOption = 'all'.obs;

  @override
  onReady() {
    fetchOffers();

    super.onReady();
  }

  fetchOffers() async {
    _filteredOffers.clear();
    final response = await sendRequestWithHandler(
        endpoint: "/admin/get_offers",
        method: "GET",
        loadingMessage: "جاري التحميل");
    // print(response.toString());
    if (response != null &&
        response['data'] != null &&
        response["data"]["offers"] != null) {
      final offersList = response['data']["offers"] as List? ?? [];
      _offers.value =
          offersList.map((offerData) => Offer.fromJson(offerData)).toList();
    }
    _filteredOffers.addAll(_offers);
    update();
  }

  void filterOffers(String query) {
    if (query.isEmpty) {
      _filteredOffers.clear();
      _filteredOffers.addAll(_offers);
    } else {
      _filteredOffers.clear();
      _filteredOffers.addAll(
        _offers.where((offer) =>
            offer.title.toLowerCase().contains(query.toLowerCase()) ||
            (offer.description?.toLowerCase().contains(query.toLowerCase()) ??
                false)),
      );
    }
    _applySorting();
  }

  void _applySorting() {
    switch (_currentSortOption.value) {
      case 'newest':
        _filteredOffers.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
        break;
      case 'oldest':
        _filteredOffers.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
        break;
      case 'price_asc':
        _filteredOffers.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        _filteredOffers.sort((a, b) => b.price.compareTo(a.price));
        break;
    }
  }

  void setSortOption(String sortOption) {
    _currentSortOption.value = sortOption;
    _applySorting();
  }

  void setFilterOption(String filterOption) {
    _currentFilterOption.value = filterOption;
    _applyFiltering();
  }

  void _applyFiltering() {
    switch (_currentFilterOption.value) {
      case 'all':
        _filteredOffers.clear();
        _filteredOffers.addAll(_offers);
        break;
      case 'cars':
        _filteredOffers.clear();
        _filteredOffers.addAll(_offers
            .where((offer) => offer.title.toLowerCase().contains('سيارة')));
        break;
      case 'real_estate':
        _filteredOffers.clear();
        _filteredOffers.addAll(_offers.where((offer) =>
            offer.title.toLowerCase().contains('شقة') ||
            offer.title.toLowerCase().contains('عقار')));
        break;
    }
    _applySorting();
  }

  void addOffer(Offer offer) async {
    if (imageFile != null) {
      try {
        final dioo = dio.Dio();
        final formData = dio.FormData.fromMap({
          'title': offer.title,
          'price': offer.price,
          'description': offer.description,
          'image': await dio.MultipartFile.fromFile(imageFile!.path,
              filename: imageFile!.path.split('/').last),
        });

        final response = await dioo.post(
          '${serverConstant.serverUrl}/admin/add_offer',
          data: formData,
          options: dio.Options(
            headers: {
              'Authorization': 'Bearer ${shared!.getString('token')}',
              'Content-Type': 'multipart/form-data',
            },
          ),
        );
        print(response.toString());
        if (response.statusCode == 200) {
          // Parse the response to get the created offer with its imageUrl
          try {
            final createdOffer = Offer(
              id: response.data['data']['offer']['_id'].toString(),
              title: response.data['data']['offer']['title'].toString(),
              description:
                  response.data['data']['offer']['description'].toString(),
              price: response.data['data']['offer']['price'].toDouble(),
              imageUrl:
                  '${serverConstant.serverUrl}/public/uploads/offers/${response.data['data']['offer']['imageUrl'].split('/').last}',
              createdAt: DateTime.parse(
                  response.data['data']['offer']['createdAt'].toString()),
            );

            _offers.add(createdOffer);
            _filteredOffers.add(createdOffer);
          } catch (e) {
            print(e.toString());
          }

          _applySorting();

          Get.snackbar(
            'نجاح',
            'تم إضافة الإعلان بنجاح',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          // Reset image file
          imageFile = null;
          update(["offerImage"]);
        } else {
          Get.snackbar(
            'خطأ',
            'حدث خطأ أثناء إضافة الإعلان',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        Get.snackbar(
          'خطأ',
          'حدث خطأ غير متوقع: ${e.toString()}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      Get.snackbar(
        'خطأ',
        'يرجى إضافة صورة للإعلان',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> addOfferImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
    }
    update(["offerImage"]);
  }

  void removeOfferImage() {
    imageFile = null;
    update(["offerImage"]);
  }

  void removeOffer(String offerId) async {
    final response = await sendRequestWithHandler(
      endpoint: '/admin/remove_offer',
      method: 'DELETE',
      body: {
        'offerId': offerId,
      },
    );
    if (response != null && response['status'] == 'success') {
      Get.snackbar(
        'نجاح',
        'تم حذف الإعلان بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      fetchOffers();
      Get.back();
    } else {
      Get.snackbar(
        'خطاء',
        'حدث خطاء',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      fetchOffers();
    }
  }

  void updateOffer(Offer updatedOffer) {
    final index = _offers.indexWhere((offer) => offer.id == updatedOffer.id);
    if (index != -1) {
      _offers[index] = updatedOffer;
      filterOffers(searchController.text);
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
