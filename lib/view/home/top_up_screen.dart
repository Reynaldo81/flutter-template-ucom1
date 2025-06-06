// ignore_for_file: deprecated_member_use

import 'package:finpay/config/images.dart';
import 'package:finpay/config/textstyle.dart';
import 'package:finpay/view/home/topup_dialog.dart';
import 'package:finpay/view/home/widget/amount_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:swipe/swipe.dart';

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({Key? key}) : super(key: key);

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final List<Map<String, dynamic>> reservations = [
    {
      "title": "Reserva #12345",
      "date": "3 de junio de 2025",
      "amount": "\$150.00",
      "status": "PAGADA",
      "statusColor": Colors.green,
      "icon": Icons.check_circle,
    },
    {
      "title": "Reserva #12346",
      "date": "4 de junio de 2025",
      "amount": "\$200.00",
      "status": "PENDIENTE",
      "statusColor": Colors.orange,
      "icon": Icons.access_time,
    },
    {
      "title": "Reserva #12347",
      "date": "5 de junio de 2025",
      "amount": "\$300.00",
      "status": "PAGADA",
      "statusColor": Colors.green,
      "icon": Icons.check_circle,
    },
    {
      "title": "Reserva #12348",
      "date": "6 de junio de 2025",
      "amount": "\$100.00",
      "status": "PENDIENTE",
      "statusColor": Colors.orange,
      "icon": Icons.access_time,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reservas"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: reservations.length,
          itemBuilder: (context, index) {
            final reservation = reservations[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ReservationCard(
                title: reservation["title"],
                date: reservation["date"],
                amount: reservation["amount"],
                status: reservation["status"],
                statusColor: reservation["statusColor"],
                icon: reservation["icon"],
              ),
            );
          },
        ),
      ),
    );
  }
}

class ReservationCard extends StatelessWidget {
  final String title;
  final String date;
  final String amount;
  final String status;
  final Color statusColor;
  final IconData icon;

  const ReservationCard({
    Key? key,
    required this.title,
    required this.date,
    required this.amount,
    required this.status,
    required this.statusColor,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: statusColor,
              size: 40,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    amount,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
