import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/provider/web/warnet_dashboard_provider.dart';
import 'package:provider/provider.dart';

class FoodOrdersCard extends StatefulWidget {
  const FoodOrdersCard({super.key});

  @override
  State<FoodOrdersCard> createState() => _FoodOrdersCardState();
}

class _FoodOrdersCardState extends State<FoodOrdersCard> {
  @override
  Widget build(BuildContext context) {
    return Consumer<WarnetDashboardProvider>(
        builder: (context, provider, child) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  'INDOREP Net - Food Orders',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 14),
                provider.isFoodOrdersLoading
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CupertinoActivityIndicator()),
                      )
                    : provider.foodOrders.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: Text(
                                'No food orders available',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey[600]),
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: provider.foodOrders.length,
                            itemBuilder: (context, index) {
                              final item = provider.foodOrders[index];
                              final isFirst = index == 0;
                              final isLast =
                                  index == provider.foodOrders.length - 1;

                              // Format the current item's date
                              final currentDate =
                                  DateFormat('yyyy-MM-dd').format(item.time);
                              // Format the previous item's date (if it exists)
                              final previousDate = index > 0
                                  ? DateFormat('yyyy-MM-dd').format(
                                      provider.foodOrders[index - 1].time)
                                  : null;

                              // Check if the day has changed
                              final isNewDay =
                                  index == 0 || currentDate != previousDate;

                              String timeInHours = DateFormat('HH:mm').format(
                                  DateTime.parse(item.time.toIso8601String()));

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Add a subtitle for the new day
                                  if (isNewDay)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Text(
                                        DateFormat(
                                                'EEEE - d MMMM yyyy', 'id_ID')
                                            .format(item.time),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Timeline indicator with vertical line
                                            Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                // Vertical line
                                                Column(
                                                  children: [
                                                    if (!isFirst)
                                                      Container(
                                                        width: 2,
                                                        height: 20,
                                                        color: Colors
                                                            .white, // Line above the circle
                                                      ),
                                                    Container(
                                                      width: 12,
                                                      height: 12,
                                                      decoration: BoxDecoration(
                                                        color: IndorepColor
                                                            .primary, // Circle color
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                    if (!isLast)
                                                      Container(
                                                        width: 2,
                                                        height: 20,
                                                        color: Colors
                                                            .white, // Line below the circle
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        '$timeInHours - PC ${item.pc}',
                                                        style: const TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                      Text(
                                                        Helper
                                                            .rupiahFormatterTwo(
                                                                item.total),
                                                        style: const TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  ListView.builder(
                                                    shrinkWrap: true,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    itemCount:
                                                        item.items.length,
                                                    itemBuilder:
                                                        (context, itemIndex) {
                                                      final foodItem =
                                                          item.items[itemIndex];
                                                      return Text(
                                                        '${foodItem.qty}x ${foodItem.name}',
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      );
                                                    },
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
