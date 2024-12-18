import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lelang_fb/app/utils/text.dart';
import '../../../../core/constants/color.dart';
import '../controllers/transaction_controller.dart';

class TransactionView extends GetView<TransactionController> {
  const TransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(TransactionController());
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(90, 70),
        child: appbarCust(
          title: 'Transaction',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            Obx(() {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    buttonTab('ON GOING', 0),
                    SizedBox(width: 10),
                    buttonTab('SUCCESS', 1),
                    SizedBox(width: 10),
                    buttonTab('FAILED', 2),
                  ],
                ),
              );
            }),
            Expanded(
              child: Obx(() {
                var filteredTickets = controller.getFilteredTickets();
                if (filteredTickets.isEmpty) {
                  return Center(
                    child: Text("No Transaction"),
                  );
                }
                return ListView.builder(
                  itemCount: filteredTickets.length,
                  itemBuilder: (context, index) {
                    final ticket = filteredTickets[index];
                    return Stack(
                      children: [
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: BorderSide(color: Colors.grey),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                ticket.gambar,
                                width: 100,
                                height: 100,
                                fit: BoxFit.contain,
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextCust(
                                    text: ticket.name,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  TextCust(
                                    text: ticket.price,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.hijauTua,
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        color: Colors.grey,
                                        size: 18,
                                      ),
                                      TextCust(
                                        text: ticket.location,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                  TextCust(
                                    text: ticket.date,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 15,
                          bottom: 10,
                          child: Container(
                            width: 55,
                            height: 18,
                            decoration: BoxDecoration(
                              color: AppColors.hijauMuda,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: TextCust(
                                text: ticket.status,
                                fontSize: 8,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector buttonTab(String text, int selectabValue) {
    return GestureDetector(
      onTap: () {
        controller.selectedTab.value = selectabValue;
      },
      child: Container(
        width: 100,
        height: 40,
        decoration: BoxDecoration(
          color: controller.selectedTab.value == selectabValue
              ? AppColors.hijauTua
              : Colors.grey,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class appbarCust extends StatelessWidget {
  final String title;
  appbarCust({
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leadingWidth: 90,
      toolbarHeight: 70,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        child: Container(
          padding: EdgeInsets.only(left: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: AppColors.grey,
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            color: Colors.white,
            onPressed: () {
              Get.back();
            },
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(
          color: AppColors.grey.withOpacity(0.2),
          thickness: 1.5,
        ),
      ),
    );
  }
}
