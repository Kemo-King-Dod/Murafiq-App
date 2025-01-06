import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:murafiq/core/utils/systemVarible.dart';
import 'package:murafiq/admin/controllers/offers_management_controller.dart';

class OffersMangementPage extends StatelessWidget {
  final OffersManagementController _controller =
      Get.put(OffersManagementController());

  OffersMangementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'الاعلانات',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: systemColors.primary,
        leading: Container(
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: systemColors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: systemColors.primary,
            ),
            onPressed: () => Get.back(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOfferBottomSheet(context),
        label: Text(
          'إضافة إعلان',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        icon: Icon(Icons.add_circle_outline, color: Colors.white),
        backgroundColor: systemColors.primary,
      ),
      body: Column(
        children: [
          _buildSearchAndFilterSection(),
          Expanded(
            child: Obx(() => _buildOffersList()),
          ),
        ],
      ),
    );
  }

  final List<Map<String, String>> _sortOptions = [
    {'title': 'أحدث الإعلانات', 'value': 'newest'},
    {'title': 'أقدم الإعلانات', 'value': 'oldest'},
    {'title': 'السعر: من الأقل إلى الأعلى', 'value': 'price_asc'},
    {'title': 'السعر: من الأعلى إلى الأقل', 'value': 'price_desc'},
  ];

  Widget _buildSearchAndFilterSection() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller.searchController,
              onChanged: (value) => _controller.filterOffers(value),
              decoration: InputDecoration(
                hintText: 'البحث عن إعلان...',
                prefixIcon: Icon(Icons.search, color: systemColors.primary),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),
          SizedBox(width: 10),
          // Sorting Dropdown
          _buildDropdownButton(
            icon: Icons.sort,
            items: _sortOptions,
            onChanged: (value) {
              if (value != null) {
                _controller.setSortOption(value);
              }
            },
          ),
          SizedBox(width: 10),
          // Filtering Dropdown
        ],
      ),
    );
  }

  Widget _buildDropdownButton({
    required List<Map<String, String>> items,
    required void Function(String?) onChanged,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: systemColors.primary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: PopupMenuButton<String>(
        offset: Offset(0, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        icon: Icon(icon, color: Colors.white),
        onSelected: onChanged,
        color: Colors.white,
        itemBuilder: (BuildContext context) {
          return items.map((item) {
            return PopupMenuItem<String>(
              value: item['value'],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['title']!,
                    style: TextStyle(
                      fontSize: 14,
                      color: systemColors.primary,
                    ),
                  ),
                  Icon(
                    icon,
                    color: systemColors.primary,
                    size: 20,
                  ),
                ],
              ),
            );
          }).toList();
        },
      ),
    );
  }

  Widget _buildOffersList() {
    return _controller.filteredOffers.isEmpty
        ? _buildEmptyStateWidget()
        : ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: _controller.filteredOffers.length,
            itemBuilder: (context, index) {
              final offer = _controller.filteredOffers[index];
              return AnimatedContainer(
                duration: Duration(milliseconds: 300),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () => _showOfferDetailsBottomSheet(offer),
                    child: Row(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.2),
                                spreadRadius: 1,
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: offer.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Center(
                                child: CircularProgressIndicator(
                                  color: systemColors.primary,
                                ),
                              ),
                              errorWidget: (context, url, error) => Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  offer.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '${offer.price.toStringAsFixed(2)} د.ل',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: systemColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }

  Widget _buildEmptyStateWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.web_asset_off_rounded,
            size: 80,
            color: Colors.grey[300],
          ),
          SizedBox(height: 16),
          Text(
            'لا توجد إعلانات حالياً',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'يمكنك إضافة إعلان جديد بالضغط على زر الإضافة',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showOfferDetailsBottomSheet(dynamic offer) {
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: 900,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                margin: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                child: CachedNetworkImage(
                  imageUrl: offer.imageUrl,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                      color: systemColors.primary,
                    ),
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '${offer.price.toStringAsFixed(2)} د.ل',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: systemColors.primary,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _controller.removeOffer(offer.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: systemColors.error,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text('حذف'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddOfferBottomSheet(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _descriptionController =
        TextEditingController();
    final TextEditingController _priceController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.3),
                    spreadRadius: 5,
                    blurRadius: 15,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: ListView(
                controller: controller,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 50,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'إضافة إعلان جديد',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: systemColors.primary,
                          ),
                        ),
                        SizedBox(height: 20),
                        GetBuilder<OffersManagementController>(
                            id: "offerImage",
                            builder: (imagectrl) {
                              return Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _controller.addOfferImage();
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: 200,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 2,
                                          color: imagectrl.imageFile == null
                                              ? systemColors.error
                                              : systemColors.primary,
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: imagectrl.imageFile != null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.file(
                                                imagectrl.imageFile!,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.add_a_photo_outlined,
                                                    color: imagectrl
                                                                .imageFile ==
                                                            null
                                                        ? systemColors.error
                                                        : systemColors.primary,
                                                    size: 50,
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text(
                                                    'إضافة صورة الإعلان',
                                                    style: TextStyle(
                                                      color: imagectrl
                                                                  .imageFile ==
                                                              null
                                                          ? systemColors.error
                                                          : systemColors
                                                              .primary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                    ),
                                  ),
                                  if (imagectrl.imageFile != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          imagectrl.removeOfferImage();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: systemColors.error,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                        ),
                                        child: Text('حذف الصورة'),
                                      ),
                                    ),
                                ],
                              );
                            }),
                        SizedBox(height: 15),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _titleController,
                                decoration: InputDecoration(
                                  labelText: 'عنوان الإعلان',
                                  prefixIcon: Icon(Icons.title,
                                      color: systemColors.primary),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'الرجاء إدخال عنوان الإعلان';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 15),
                              TextFormField(
                                controller: _descriptionController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  labelText: 'وصف الإعلان (اختياري)',
                                  prefixIcon: Icon(Icons.description,
                                      color: systemColors.primary),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                              SizedBox(height: 15),
                              TextFormField(
                                controller: _priceController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'السعر',
                                  prefixIcon: Icon(Icons.price_change,
                                      color: systemColors.primary),
                                  suffixText: 'د.ل',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'الرجاء إدخال السعر';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'الرجاء إدخال سعر صحيح';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async{
                                        // Validate image first
                                        if (_controller.imageFile == null) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'الرجاء إضافة صورة للإعلان'),
                                              backgroundColor:
                                                  systemColors.error,
                                            ),
                                          );
                                          return;
                                        }

                                        // Then validate form
                                        if (_formKey.currentState!.validate()) {
                                          // Create offer logic
                                          final newOffer = Offer(
                                            id: DateTime.now()
                                                .millisecondsSinceEpoch
                                                .toString(),
                                            title: _titleController.text,
                                            description:
                                                _descriptionController.text,
                                            price: double.parse(
                                                _priceController.text),
                                            imageUrl:
                                                '', // Will be updated later
                                          );

                                          await _controller.addOffer(newOffer);
                                          Get.back();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'تم إضافة الإعلان بنجاح'),
                                              backgroundColor:
                                                  systemColors.primary,
                                            ),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: systemColors.primary,
                                        padding:
                                            EdgeInsets.symmetric(vertical: 15),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                      child: Text(
                                        'إضافة الإعلان',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
