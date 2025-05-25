import 'package:finpay/model/sitema_reservas.dart';
import 'package:get/get.dart';
import 'package:finpay/api/local.db.service.dart';
import 'package:flutter/material.dart';

class AlumnoController extends GetxController {
  final db = LocalDBService();

  // Observables
  RxList<Piso> pisos = <Piso>[].obs;
  Rx<Piso?> pisoSeleccionado = Rx<Piso?>(null);

  RxList<Lugar> lugaresDisponibles = <Lugar>[].obs;
  Rx<Lugar?> lugarSeleccionado = Rx<Lugar?>(null);

  Rx<DateTime?> horarioInicio = Rx<DateTime?>(null);
  Rx<DateTime?> horarioSalida = Rx<DateTime?>(null);
  RxInt duracionSeleccionada = 0.obs;

  RxList<Auto> autosCliente = <Auto>[].obs;
  Rx<Auto?> autoSeleccionado = Rx<Auto?>(null);

  String codigoClienteActual = 'cliente_1'; // ← puede venir del login

  @override
  void onInit() {
    super.onInit();
    resetearCampos();
    cargarAutosDelCliente();
    cargarPisosYLugares();
  }

  Future<void> cargarPisosYLugares() async {
    final rawPisos = await db.getAll("pisos.json");
    final rawLugares = await db.getAll("lugares.json");
    final rawReservas = await db.getAll("reservas.json");

    final reservas = rawReservas.map((e) => Reserva.fromJson(e)).toList();
    final lugaresReservados = reservas.map((r) => r.codigoReserva).toSet();
    final todosLugares = rawLugares.map((e) => Lugar.fromJson(e)).toList();

    pisos.value = rawPisos.map((pJson) {
      final codigoPiso = pJson['codigo'];
      final lugaresDelPiso =
          todosLugares.where((l) => l.codigoPiso == codigoPiso).toList();

      return Piso(
        codigo: codigoPiso,
        descripcion: pJson['descripcion'],
        lugares: lugaresDelPiso,
      );
    }).toList();

    lugaresDisponibles.value = todosLugares.where((l) {
      return !lugaresReservados.contains(l.codigoLugar);
    }).toList();
  }

  Future<void> seleccionarPiso(Piso piso) async {
    pisoSeleccionado.value = piso;
    lugarSeleccionado.value = null;

    final lugaresFiltrados = lugaresDisponibles
        .where((lugar) => lugar.codigoPiso == piso.codigo)
        .toList();

    lugaresDisponibles.value = lugaresFiltrados;
  }

  Future<void> confirmarReserva() async {
    if (pisoSeleccionado.value == null ||
        lugarSeleccionado.value == null ||
        horarioInicio.value == null ||
        horarioSalida.value == null ||
        autoSeleccionado.value == null) {
      Get.snackbar(
        "Campos incompletos",
        "Por favor completá todos los datos para confirmar.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
      return;
    }

    final duracionEnHoras =
        horarioSalida.value!.difference(horarioInicio.value!).inMinutes / 60;

    if (duracionEnHoras <= 0) {
      Get.snackbar(
        "Duración inválida",
        "La hora de salida debe ser posterior a la de inicio.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.black,
      );
      return;
    }

    final montoCalculado = (duracionEnHoras * 10000).roundToDouble();

    final nuevaReserva = Reserva(
      codigoReserva: "RES-${DateTime.now().millisecondsSinceEpoch}",
      horarioInicio: horarioInicio.value!,
      horarioSalida: horarioSalida.value!,
      monto: montoCalculado,
      estadoReserva: "PENDIENTE",
      chapaAuto: autoSeleccionado.value!.chapa,
    );

    try {
      final reservas = await db.getAll("reservas.json");
      reservas.add(nuevaReserva.toJson());
      await db.saveAll("reservas.json", reservas);

      final lugares = await db.getAll("lugares.json");
      final index = lugares.indexWhere(
        (l) => l['codigoLugar'] == lugarSeleccionado.value!.codigoLugar,
      );
      if (index != -1) {
        lugares[index]['estado'] = "RESERVADO";
        await db.saveAll("lugares.json", lugares);
      }

      Get.snackbar(
        "Reserva confirmada",
        "Tu reserva ha sido registrada con éxito.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.black,
      );

      resetearCampos();
      await cargarPisosYLugares();
    } catch (e) {
      Get.snackbar(
        "Error",
        "No se pudo guardar la reserva.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
      print("Error al guardar reserva: $e");
    }
  }

  void resetearCampos() {
    pisoSeleccionado.value = null;
    lugarSeleccionado.value = null;
    horarioInicio.value = null;
    horarioSalida.value = null;
    duracionSeleccionada.value = 0;
    autoSeleccionado.value = null;
  }

  Future<void> cargarAutosDelCliente() async {
    final rawAutos = await db.getAll("autos.json");
    final autos = rawAutos.map((e) => Auto.fromJson(e)).toList();

    autosCliente.value =
        autos.where((a) => a.clienteId == codigoClienteActual).toList();
  }

  @override
  void onClose() {
    resetearCampos();
    super.onClose();
  }
}
