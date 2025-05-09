import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:murafiq/core/utils/systemVarible.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('سياسة الخصوصية'.tr),
        centerTitle: true,
        backgroundColor: systemColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              systemColors.primary.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: systemColors.primary.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.privacy_tip_rounded,
                          color: systemColors.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'سياسة الخصوصية'.tr,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: systemColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: systemColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'آخر تحديث: 18 يناير 2025',
                        style: TextStyle(
                          color: systemColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildSection(
                title: '',
                content: [
                  'تصف سياسة الخصوصية هذه سياساتنا وإجراءاتنا بشأن جمع واستخدام وكشف معلوماتك عند استخدام الخدمة وتخبرك عن حقوق الخصوصية الخاصة بك وكيف يحميك القانون.',
                  'نحن نستخدم بياناتك الشخصية لتقديم وتحسين الخدمة. باستخدام الخدمة، فإنك توافق على جمع واستخدام المعلومات وفقًا لسياسة الخصوصية هذه.',
                ],
              ),
              _buildSection(
                title: 'التفسير والتعريفات',
                content: [
                  'الكلمات التي يبدأ حرفها الأول بحرف كبير لها معاني محددة في الشروط التالية. التعريفات التالية سيكون لها نفس المعنى بغض النظر عما إذا كانت تظهر بصيغة المفرد أو الجمع.',
                ],
              ),
              _buildSection(
                title: 'جمع واستخدام بياناتك الشخصية',
                content: [],
                subsections: [
                  _buildSubsection(
                    title: 'أنواع البيانات المجمعة',
                    content: [
                      'البيانات الشخصية',
                      'أثناء استخدام خدمتنا، قد نطلب منك تزويدنا بمعلومات تعريف شخصية معينة يمكن استخدامها للاتصال بك أو التعرف عليك. قد تتضمن معلومات التعريف الشخصية، على سبيل المثال لا الحصر:',
                    ],
                    bulletPoints: [
                      'الاسم الأول والأخير',
                      'رقم الهاتف',
                      'العنوان، الولاية، المقاطعة، الرمز البريدي، المدينة',
                      'بيانات الاستخدام',
                    ],
                  ),
                  _buildSubsection(
                    title: 'بيانات الاستخدام',
                    content: [
                      'يتم جمع بيانات الاستخدام تلقائيًا عند استخدام الخدمة.',
                      'قد تتضمن بيانات الاستخدام معلومات مثل عنوان بروتوكول الإنترنت الخاص بجهازك (مثل عنوان IP)، ونوع المتصفح، وإصدار المتصفح، وصفحات خدمتنا التي تزورها، ووقت وتاريخ زيارتك، والوقت المستغرق على تلك الصفحات، ومعرفات الأجهزة الفريدة وبيانات التشخيص الأخرى.',
                    ],
                  ),
                  _buildSubsection(
                    title: 'معلومات تم جمعها أثناء استخدام التطبيق',
                    content: [
                      'أثناء استخدام تطبيقنا، لتوفير ميزات تطبيقنا، قد نقوم بجمع، بموافقتك المسبقة:',
                    ],
                    bulletPoints: [
                      'معلومات حول موقعك',
                      'الصور ومعلومات أخرى من كاميرا جهازك ومكتبة الصور',
                    ],
                  ),
                ],
              ),
              _buildSection(
                title: 'استخدام بياناتك الشخصية',
                content: [
                  'قد تستخدم الشركة البيانات الشخصية للأغراض التالية:',
                ],
                bulletPoints: [
                  'لتقديم وصيانة خدمتنا، بما في ذلك مراقبة استخدام خدمتنا.',
                  'لإدارة حسابك: لإدارة تسجيلك كمستخدم للخدمة.',
                  'لأداء العقد: تطوير وتنفيذ عقد الشراء للمنتجات أو العناصر أو الخدمات التي اشتريتها.',
                  'للاتصال بك: للاتصال بك عبر البريد الإلكتروني أو المكالمات الهاتفية أو الرسائل القصيرة أو غيرها من أشكال الاتصال الإلكتروني المكافئة.',
                ],
              ),
              _buildSection(
                title: 'اتصل بنا',
                content: [
                  'إذا كان لديك أي أسئلة حول سياسة الخصوصية هذه، يمكنك الاتصال بنا:',
                ],
              ),
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: systemColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: systemColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.phone,
                      color: systemColors.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'عبر رقم الهاتف: +218927775066',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: systemColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<String> content,
    List<String>? bulletPoints,
    List<Widget>? subsections,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: systemColors.primary,
              ),
            ),
            const SizedBox(height: 12),
          ],
          ...content.map((text) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              )),
          if (bulletPoints != null && bulletPoints.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...bulletPoints.map((point) => Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: systemColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          point,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
          if (subsections != null && subsections.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...subsections,
          ],
        ],
      ),
    );
  }

  Widget _buildSubsection({
    required String title,
    required List<String> content,
    List<String>? bulletPoints,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: systemColors.primary.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        ...content.map((text) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            )),
        if (bulletPoints != null && bulletPoints.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...bulletPoints.map((point) => Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: systemColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        point,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}
