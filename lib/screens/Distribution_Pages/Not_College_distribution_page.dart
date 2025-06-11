import 'package:aitu_app/screens/Distribution_Pages/Distribution_choice.dart';
import 'package:aitu_app/screens/Distribution_Pages/PDFViewerPage.dart';
import 'package:aitu_app/shared/constant.dart';
import 'package:aitu_app/shared/reuableWidgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Add_New_Factory_Request_Page.dart';

import 'FactoryData.dart';

class Not_College_distribution_page extends StatefulWidget {
  const Not_College_distribution_page({super.key});

  @override
  State<Not_College_distribution_page> createState() =>
      _Not_College_distribution_pageState();
}

class _Not_College_distribution_pageState
    extends State<Not_College_distribution_page> {
  String? selectedGovernorate;
  List<String> governorateNames = [];
  String? selectedFactory;
  List<String> factoryNames = [];
  String? nominationCardUrl;
  // addFactories() async {
  //   WriteBatch batch = FirebaseFirestore.instance.batch();
  //
  //   List<Map<String, dynamic>> factories = [
  //     // {"FName": "شركة المقاولون العرب (عثمان أحمد عثمان)", "Governorate": "أسيوط", "Address": "أسيوط – شارع النيل"},
  //     // {"FName": "شركة المقاولون العرب (عثمان أحمد عثمان)", "Governorate": "أسيوط", "Address": "منطقة جحدم الصناعية  - بني غالب"},
  //     // {"FName": "الشركة المالية والصناعية المصرية(مصنع أسيوط للأسمدة)", "Governorate": "أسيوط", "Address": "أسيوط - منقباد"},
  //     // {"FName": "مصنع ليوني وايرنج سيستمز", "Governorate": "أسيوط", "Address": "منطقة ساحل سليم الصناعية"},
  //     // {"FName": "شركة مصر العليا للأدوية(مصنع تي ثري ايه سابقًا)", "Governorate": "أسيوط", "Address": "أسيوط – مدينة عرب العوامر الصناعية"},
  //     // {"FName": "مصنع الدولية للمستلزمات الطبية", "Governorate": "أسيوط", "Address": "منطقة الزرابي الصناعية- أبوتيج"},
  //     // {"FName": "شركة العالمية للمطاحن", "Governorate": "أسيوط", "Address": "منطقة الصفاء الصناعية  - بني غالب"},
  //     // {"FName": "شركة النيل للزيوت والمنظفات", "Governorate": "أسيوط", "Address": "أسيوط - القوصية  - بني قرة"},
  //     // {"FName": "شركة الاصدقاء للمطاحن والأعلاف", "Governorate": "أسيوط", "Address": "منطقة عرب العوامر الصناعية –أبنوب"},
  //     // {"FName": "مصنع الأصدقاء للبلاستيك", "Governorate": "أسيوط", "Address": "منطقة الصفاء الصناعية  - بني غالب"},
  //     // {"FName": "شركة بي أم للصناعة والاستثمار", "Governorate": "أسيوط", "Address": "منطقة الصفاء الصناعية  - بني غالب"},
  //     // {"FName": "جمعية أسيوط للانشاء والتعمير", "Governorate": "أسيوط", "Address": "أسيوط – الهلالي"},
  //     // {"FName": "مكتب المهندس علاء كمال للإنشاءات المتكاملة", "Governorate": "أسيوط", "Address": "أسيوط -ش النيل"},
  //     // {"FName": "مطاحن  وأعلاف  الدولية", "Governorate": "أسيوط", "Address": "منطقة الصفاء الصناعية  - بني غالب"},
  //     // {"FName": "شركة الوطنية للمصاعد والاعمال الكهروميكانيكية", "Governorate": "أسيوط", "Address": "أسيوط"},
  //     // {"FName": "مطاحن سندريلا", "Governorate": "أسيوط", "Address": "منطقة الصفاء الصناعية  - بني غالب"},
  //     // {"FName": "مصنع الأصدقاء لتشكيل المعادن", "Governorate": "أسيوط", "Address": "منطقة الصفاء الصناعية  - بني غالب"},
  //     // {"FName": "مكتب عبدربه محمد احمد", "Governorate": "أسيوط", "Address": "أسيوط"},
  //     // {"FName": "مصنع كوكاكولا", "Governorate": "أسيوط", "Address": "أسيوط – منطقة عرب العوامر الصناعية"},
  //     // {"FName": "شركة المعالي لتشكيل المعادن", "Governorate": "أسيوط", "Address": "أسيوط – الصفاء الصناعية"},
  //     // {"FName": "ورش صيانة جامعة أسيوط)  تبريد وتكييف– طلمبات وأعمال كهربائية)", "Governorate": "أسيوط", "Address": "جامعة أسيوط"},
  //     // {"FName": "مصنع الماس للمستلزمات الطبية", "Governorate": "أسيوط", "Address": "أسيوط – أبوتيج – منطقة الزرابي الصناعية"},
  //     // {"FName": "الشركة الهندسية للصناعات الخفيفة", "Governorate": "أسيوط", "Address": "أسيوط - الصفا"},
  //     // {"FName": "الشركة المصرية للنظم الألكترونية والتحكم Egy-Tronix", "Governorate": "أسيوط", "Address": "فرع أسيوط –فريال – ش مكة المكرمة"},
  //     // {"FName": "مصنع أرو للمستلزمات الطبية", "Governorate": "أسيوط", "Address": "أسيوط – منطقة عرب العوامر الصناعية"},
  //     // {"FName": "مركز صيانة الاجهزة العلمية  - كلية الهندسة - جامعة أسيوط", "Governorate": "أسيوط", "Address": "جامعة أسيوط"},
  //     // {"FName": "مصنع العالمية لتشكيل المعادن", "Governorate": "أسيوط", "Address": "منطقة الصفاء الصناعية  - بني غالب"},
  //     // {"FName": "مصنع الصفا لتصنيع القطن الطبي", "Governorate": "أسيوط", "Address": "منطقة الصفاء الصناعية  - بني غالب"},
  //     // {"FName": "مصنع الرحاب لتصنيع الكرتون", "Governorate": "أسيوط", "Address": "أسيوط – منطقة عرب العوامر الصناعية"},
  //     // {"FName": "شركة التحكم العالي للمصاعد والسلالم الكهربائية", "Governorate": "أسيوط", "Address": "أسيوط - المعلمين"},
  //     // {"FName": "مطاحن حورس", "Governorate": "أسيوط", "Address": "أسيوط – منطقة عرب العوامر الصناعية"},
  //     // {"FName": "مصنع الترا للمستلزمات الطبية", "Governorate": "أسيوط", "Address": "أسيوط – منطقة عرب العوامر الصناعية"},
  //     // {"FName": "مصنع شيبسي", "Governorate": "أسيوط", "Address": "أسيوط – منطقة عرب العوامر الصناعية"},
  //     // {"FName": "مطاحن أولاد علي", "Governorate": "أسيوط", "Address": "أسيوط -منطقة الزرابي الصناعية – أبو تيج"},
  //     // {"FName": "مطحن عيون", "Governorate": "أسيوط", "Address": "أسيوط - منطقة دشلوط الصناعية"},
  //     // {"FName": "ورش مديرية الري بأسيوط", "Governorate": "أسيوط", "Address": "أسيوط - الوليدية"},
  //     // {"FName": "شركة IdeaSpace (القرية الذكية)", "Governorate": "أسيوط", "Address": "مدينة أسيوط الجديدة"},
  //     // {"FName": "مطاحن الأخوة المتحدين", "Governorate": "أسيوط", "Address": "أسيوط -منطقة الزرابي الصناعية – أبو تيج"},
  //     // {"FName": "مطحن الملكة", "Governorate": "أسيوط", "Address": "منطقة الصفاء الصناعية  - بني غالب"},
  //     // {"FName": "مركز تدريب القوى العاملة", "Governorate": "أسيوط", "Address": "أسيوط"},
  //     // {"FName": "مصنع ميكس", "Governorate": "أسيوط", "Address": "أسيوط – مدينة الصفا الصناعية"},
  //     // {"FName": "شركة تشيلرز", "Governorate": "أسيوط", "Address": "سوهاج - طريق إخميم"},
  //     // {"FName": "شركة الصفا", "Governorate": "أسيوط", "Address": "أسيوط – مدينة الصفا الصناعية"},
  //     // {"FName": "مصنع أسيوستيل AsioSteel", "Governorate": "أسيوط", "Address": "أسيوط – مدينة الصفا الصناعية"},
  //     // {"FName": "شركة الكان للصيانة والتوريدات", "Governorate": "أسيوط", "Address": "أسيوط – فريال"},
  //     // {"FName": "مركز النيل للتدريب المهني وصيانة السيارات", "Governorate": "أسيوط", "Address": "أسيوط - المعلمين"},
  //     ///**********************************************
  //     // {"FName": "مجمع مصانع الألمونيوم بنجع حمادي", "Governorate": "قنا", "Address": "قنا – نجع حمادي"},
  //     // {"FName": "مجموعة مصانع فريش لتصنيع الأجهزة الكهربائية والمنزلية", "Governorate": "القاهرة", "Address": "مدينة العاشر من رمضان - القاهرة"},
  //     // {"FName": "مصنع الفاتح للمحولات الكهربائية", "Governorate": "القاهرة", "Address": "القاهرة - مدينة العبور الصناعية"},
  //     // {"FName": "غازتك - الشركة المصرية الدولية لتكنولوجيا الغاز", "Governorate": "القاهرة", "Address": "القاهرة -القاهرة الجديدة -ش التسعين"},
  //     // {"FName": "مصنع بيدو لتطوير تقنيات التعليم", "Governorate": "القاهرة", "Address": "القاهرة – مدينة 6 أكتوبر الصنااعية"},
  //     // {"FName": "مصنع المهندس للمحولات الكهربائية", "Governorate": "القاهرة", "Address": "القاهرة – مدينة 6 أكتوبر الصنااعية"},
  //     // {"FName": "جمعية المستثمرين بالعبور – القاهرة", "Governorate": "القاهرة", "Address": "القاهرة – مدينة العبور الصناعية"},
  //     // {"FName": "جمعية مستثمري السادس من أكتوبر", "Governorate": "القاهرة", "Address": "القاهرة – مدينة 6 أكتوبر الصنااعية"},
  //     // {"FName": "مصانع الانتاج الحربي", "Governorate": "القاهرة", "Address": "القاهرة – مدينة نصر"},
  //     // {"FName": "مصنع بيبسي كو", "Governorate": "القاهرة", "Address": "القاهرة"},
  //     // {"FName": "شركة أبناء الحج أحمد ضيف الله للتجارة والمقاولات", "Governorate": "سوهاج", "Address": "شارع الجمهورية - سوهاج"},
  //
  //   ];
  //
  //   CollectionReference factoriesRef = FirebaseFirestore.instance.collection("Factories");
  //
  //   for (var factory in factories) {
  //     DocumentReference docRef = factoriesRef.doc(); // إنشاء مرجع للوثيقة بدون id محدد
  //     batch.set(docRef, factory);
  //   }
  //
  //   await batch.commit(); // تنفيذ العملية مرة واحدة
  // }

  // دالة لجلب بيانات المحافظات من Firestore

  Future<void> fetchGovernorates() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("Governorates").get();

    // تحويل البيانات إلى قائمة من النصوص
    setState(() {
      governorateNames =
          querySnapshot.docs.map((doc) => doc["GName"] as String).toList();
    });
  }

  Future<void> fetchFactories(String gName) async {
    selectedFactory = null;
    factoryNames = [];

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection("Factories").get();

      List<QueryDocumentSnapshot> filteredDocs =
          querySnapshot.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;

            return data.containsKey("Governorate") &&
                data.containsKey("isApproved") &&
                data.containsKey("type") &&
                data.containsKey("name") &&
                data["Governorate"] == gName &&
                data["isApproved"] == true &&
                data["type"] == "external";
          }).toList();

      setState(() {
        factoryNames =
            filteredDocs.map((doc) => doc["name"] as String).toList();
      });
    } catch (e) {
      print("🔥 Error fetching factories: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    // addFactories();
    fetchGovernorates();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          Get.locale?.languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: const Color.fromARGB(255, 10, 10, 10),
            ),
            onPressed: () {
              Get.offAll(() => Distribution_choice());
            },
          ),
          // actions: <Widget>[
          //   // Language Selector Icon
          //   PopupMenuButton<String>(
          //     icon: Icon(Icons.language, color: Colors.white),
          //     onSelected: (value) {
          //       // Update the app's locale based on the selection
          //       if (value == 'en') {
          //         Get.updateLocale(Locale('en'));
          //       } else if (value == 'ar') {
          //         Get.updateLocale(Locale('ar'));
          //       }
          //     },
          //     itemBuilder: (BuildContext context) {
          //       return [
          //         PopupMenuItem(value: 'en', child: Text('English')),
          //         PopupMenuItem(value: 'ar', child: Text('العربية')),
          //       ];
          //     },
          //   ),
          // ],
        ),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "Not_College_distribution_text".tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Tajawal',
                    fontSize: 16.0,
                  ),
                ),
                SizedBox(height: 20.0),

                /// choosing the government
                governorateNames.isEmpty
                    ? CircularProgressIndicator() // تحميل البيانات
                    : Container(
                      // width: MediaQuery.of(context).size.width * 0.9,
                      padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        // border: Border.all(
                        //   color: Color(0xFF0187c4),
                        //   width: 1,
                        // ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value:
                              governorateNames.contains(selectedGovernorate)
                                  ? selectedGovernorate
                                  : null,
                          hint: Text(
                            "pick_governorate_name".tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF0187c4),
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Tajawal',

                              fontSize: 16,
                            ),
                          ),
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: Color(0xFF0187c4),
                          ),
                          dropdownColor: Colors.white,
                          items:
                              governorateNames.map((governorate) {
                                return DropdownMenuItem<String>(
                                  value: governorate,
                                  child: Text(
                                    governorate,
                                    textAlign: TextAlign.center,

                                    style: TextStyle(
                                      color: Color(0xFF0187c4),
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Tajawal',

                                      fontSize: 16,
                                    ),
                                  ),
                                );
                              }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              // selectedFactory = null;
                              selectedGovernorate = newValue;
                              fetchFactories(newValue!);
                            });
                          },
                        ),
                      ),
                    ),

                /// choosing the factory
                Column(
                  children: [
                    Visibility(
                      visible:
                          selectedGovernorate != null &&
                          factoryNames.isNotEmpty,
                      child:
                          factoryNames.isEmpty
                              ? CircularProgressIndicator() // تحميل البيانات
                              : Container(
                                // width: MediaQuery.of(context).size.width * 0.8,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    borderRadius: BorderRadius.circular(20),
                                    isExpanded: true,
                                    value: selectedFactory,
                                    hint: Text(
                                      "pick_factory_name".tr,
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 0, 0, 0),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        fontFamily: 'Tajawal',
                                      ),
                                    ),
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: Color(0xFF0187c4),
                                    ),
                                    dropdownColor: Colors.white,
                                    items:
                                        factoryNames.map((factory) {
                                          return DropdownMenuItem<String>(
                                            value: factory,
                                            child: Text(
                                              factory,
                                              style: TextStyle(
                                                color: Color(0xFF0187c4),
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16,
                                                fontFamily: 'Tajawal',
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedFactory = newValue;
                                      });
                                    },
                                  ),
                                ),
                              ),
                    ),
                    Visibility(
                      visible:
                          selectedGovernorate != null &&
                          factoryNames.isNotEmpty,
                      child: Opacity(
                        opacity: selectedFactory != null ? 1 : 0.5,
                        child: GestureDetector(
                          onTap: () async {
                            if (selectedFactory != null) {
                              Get.to(
                                FactoryData(selectedFactory: selectedFactory),
                              );
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 4.0,
                            ),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                "factory_data".tr,
                                style: TextStyle(
                                  color: mainColor,
                                  fontFamily: 'Tajawal',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: factoryNames.isEmpty && selectedGovernorate != null,
                  child: Text(
                    "no_factory_data_in_this_gov".tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                    ),
                  ),
                ),
                Visibility(
                  visible: selectedFactory != null,
                  child: SizedBox(
                    width: double.infinity,
                    height: 40.0,
                    child: CreateButton(
                      title: Text(
                        "تأكيد المصنع".tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Tajawal',
                          fontSize: 14.0,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final String? studentEmail = prefs.getString("email");
                        if (studentEmail != null) {
                          await FirebaseFirestore.instance
                              .collection('StudentsTable')
                              .where('email', isEqualTo: studentEmail)
                              .get()
                              .then((querySnapshot) {
                                if (querySnapshot.docs.isNotEmpty) {
                                  querySnapshot.docs.first.reference.update({
                                    'isReportUploaded': false,
                                  });
                                }
                              });
                        }
                        Get.to(PDFViewerPage(pdfType: "nominationCard"));
                      },
                    ),
                  ),
                ),

                SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey, thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        "or".tr,
                        style: TextStyle(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Tajawal',
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey, thickness: 1)),
                  ],
                ),

                // SizedBox(height: 40,),
                CreateButton(
                  title: Text(
                    "add_new_factory_request".tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Tajawal',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () async {
                    Get.to(Add_New_Factory_Request_Page());
                  },
                ),
                // CreateButton(
                //   title: Text('test for up', textAlign: TextAlign.center),
                //   onPressed: () async {
                //     Get.to(UplooadRerport());
                //   },
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
