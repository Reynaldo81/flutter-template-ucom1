import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({Key? key}) : super(key: key);

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  List<Map<String, dynamic>> reservations = [
    {
      "title": "Reserva #12345",
      "date": "3 de junio de 2025",
      "amount": "\$150.00",
      "status": "PENDIENTE",
      "statusColor": Colors.orange,
      "icon": Icons.access_time,
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
  ];

  void registerPayment(int index) {
    setState(() {
      reservations[index]["status"] = "PAGADA";
      reservations[index]["statusColor"] = Colors.green;
      reservations[index]["icon"] = Icons.check_circle;
    });
  }

  void cancelReservation(int index) {
    setState(() {
      reservations.removeAt(index);
    });
  }

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
                onRegisterPayment: () => registerPayment(index),
                onCancelReservation: () => cancelReservation(index),
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
  final VoidCallback onRegisterPayment;
  final VoidCallback onCancelReservation;

  const ReservationCard({
    Key? key,
    required this.title,
    required this.date,
    required this.amount,
    required this.status,
    required this.statusColor,
    required this.icon,
    required this.onRegisterPayment,
    required this.onCancelReservation,
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
        child: Column(
          children: [
            Row(
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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: onRegisterPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text("Registrar Pago"),
                ),
                ElevatedButton(
                  onPressed: onCancelReservation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text("Cancelar Reserva"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
