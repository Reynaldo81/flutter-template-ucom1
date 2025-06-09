import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({Key? key}) : super(key: key);

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  List<Map<String, dynamic>> reservations = [];

  @override
  void initState() {
    super.initState();
    loadReservations();
  }

  Future<void> loadReservations() async {
    final String response = await rootBundle.loadString('assets/data/reservas.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      reservations = data.map((e) => Map<String, dynamic>.from(e)).toList();
    });
  }

  Future<void> registerPayment(int index) async {
    final reservation = reservations[index];
    final payment = {
      "codigoPago": "PAG${DateTime.now().millisecondsSinceEpoch}",
      "codigoReservaAsociada": reservation["codigoReserva"],
      "montoPagado": reservation["amount"],
      "fechaPago": DateTime.now().toIso8601String(),
    };

    // Update reservation status
    setState(() {
      reservations[index]["status"] = "PAGADA";
      reservations[index]["statusColor"] = Colors.green;
      reservations[index]["icon"] = Icons.check_circle;
    });

    // Save payment to pagos.json
    final String pagosResponse = await rootBundle.loadString('assets/data/pagos.json');
    final List<dynamic> pagosData = json.decode(pagosResponse);
    pagosData.add(payment);

    // Simulate saving to file (replace with actual file saving logic)
    print(json.encode(pagosData));
  }

  Future<void> cancelReservation(int index) async {
    setState(() {
      reservations.removeAt(index);
    });

    // Simulate saving updated reservations to reservas.json (replace with actual file saving logic)
    print(json.encode(reservations));
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
