import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:finpay/controller/Alumn/Alumno_controller.dart';
import 'package:finpay/model/sitema_reservas.dart';
import 'package:finpay/utils/utiles.dart';

class ReservaScreen extends StatelessWidget {
  final controller = Get.put(AlumnoController());

  ReservaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reservar lugar")),
      body: Obx(() => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDropdown<Auto>(
                  label: "Auto",
                  value: controller.autoSeleccionado.value,
                  items: controller.autosCliente,
                  itemLabel: (a) => "${a.chapa} - ${a.marca} ${a.modelo}",
                  onChanged: (a) => controller.autoSeleccionado.value = a,
                ),
                _buildDropdown<Piso>(
                  label: "Piso",
                  value: controller.pisoSeleccionado.value,
                  items: controller.pisos,
                  itemLabel: (p) => p.descripcion,
                  onChanged: (p) => controller.seleccionarPiso(p!),
                ),
                const SizedBox(height: 12),
                _buildLugaresGrid(controller),
                const SizedBox(height: 12),
                _buildHorarioSelector(context, controller),
                _buildDuracionChips(controller),
                const SizedBox(height: 12),
                _buildMontoEstimado(controller),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.confirmarReserva,
                    child: const Text("Confirmar Reserva"),
                  ),
                ),
              ],
            ),
          )),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        DropdownButton<T>(
          isExpanded: true,
          value: value,
          hint: Text("Seleccionar $label"),
          onChanged: onChanged,
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(itemLabel(item)),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildLugaresGrid(AlumnoController controller) {
    final piso = controller.pisoSeleccionado.value;
    final lugares = controller.lugaresDisponibles
        .where((l) => l.codigoPiso == piso?.codigo)
        .toList();

    return SizedBox(
      height: 180,
      child: GridView.count(
        crossAxisCount: 5,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        children: lugares.map((lugar) {
          final seleccionado = lugar == controller.lugarSeleccionado.value;
          final color = lugar.estado == "RESERVADO"
              ? Colors.red
              : seleccionado
                  ? Colors.green
                  : Colors.grey.shade300;

          return GestureDetector(
            onTap: lugar.estado == "DISPONIBLE"
                ? () => controller.lugarSeleccionado.value = lugar
                : null,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(lugar.codigoLugar),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHorarioSelector(BuildContext context, AlumnoController controller) {
    return Row(
      children: [
        Expanded(child: _buildTimeButton(context, true, controller)),
        const SizedBox(width: 8),
        Expanded(child: _buildTimeButton(context, false, controller)),
      ],
    );
  }

  Widget _buildTimeButton(BuildContext context, bool isInicio, AlumnoController controller) {
    return Obx(() {
      final date = isInicio
          ? controller.horarioInicio.value
          : controller.horarioSalida.value;

      return ElevatedButton.icon(
        onPressed: () async {
          final pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 30)),
          );
          if (pickedDate == null) return;

          final pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (pickedTime == null) return;

          final fullDate = DateTime(pickedDate.year, pickedDate.month,
              pickedDate.day, pickedTime.hour, pickedTime.minute);

          if (isInicio) {
            controller.horarioInicio.value = fullDate;
          } else {
            controller.horarioSalida.value = fullDate;
          }
        },
        icon: Icon(isInicio ? Icons.access_time : Icons.timer_off),
        label: Text(
          date == null
              ? (isInicio ? "Inicio" : "Salida")
              : "${UtilesApp.formatearFechaDdMMAaaa(date)} ${TimeOfDay.fromDateTime(date).format(context)}",
        ),
      );
    });
  }

  Widget _buildDuracionChips(AlumnoController controller) {
    return Wrap(
      spacing: 6,
      children: [1, 2, 4, 6].map((h) {
        return Obx(() => ChoiceChip(
              label: Text("$h h"),
              selected: controller.duracionSeleccionada.value == h,
              onSelected: (_) {
                final inicio =
                    controller.horarioInicio.value ?? DateTime.now();
                controller.horarioInicio.value = inicio;
                controller.horarioSalida.value =
                    inicio.add(Duration(hours: h));
                controller.duracionSeleccionada.value = h;
              },
            ));
      }).toList(),
    );
  }

  Widget _buildMontoEstimado(AlumnoController controller) {
    return Obx(() {
      final inicio = controller.horarioInicio.value;
      final salida = controller.horarioSalida.value;

      if (inicio == null || salida == null) return const SizedBox();

      final monto =
          ((salida.difference(inicio).inMinutes / 60) * 10000).round();
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          "Monto estimado: ₲${UtilesApp.formatearGuaranies(monto)}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    });
  }
}

