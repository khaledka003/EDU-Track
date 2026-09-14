import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSearchPicker extends StatelessWidget {
  final String title;
  final String hint;
  final String? selectedItem;
  final RxList<String> items; // ✅ تغيير إلى RxList
  final Function(String) onSelected;
  final IconData icon;

  const CustomSearchPicker({
    super.key,
    required this.title,
    required this.hint,
    this.selectedItem,
    required this.items,
    required this.onSelected,
    this.icon = Icons.search,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openPicker(context),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[350]!),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF0077B6), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedItem ?? hint,
                style: TextStyle(
                  fontSize: 14,
                  color: selectedItem == null ? Colors.grey : Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _openPicker(BuildContext context) {
    // نسخة محلية للبحث
    final searchController = TextEditingController();
    final filteredItems = <String>[].obs;

    // مزامنة القائمة المفلترة مع القائمة الأصلية
    filteredItems.value = items.toList();

    Get.bottomSheet(
      Container(
        height: 500,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "ابحث هنا...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (val) {
                  if (val.isEmpty) {
                    filteredItems.value = items.toList();
                  } else {
                    filteredItems.value = items
                        .where((e) => e.contains(val))
                        .toList();
                  }
                },
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Obx(
                () => ListView.separated(
                  itemCount: filteredItems.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) => ListTile(
                    title: Text(filteredItems[i]),
                    onTap: () {
                      onSelected(filteredItems[i]);
                      Get.back();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
