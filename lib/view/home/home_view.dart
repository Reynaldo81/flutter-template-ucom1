// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'package:card_swiper/card_swiper.dart';
import 'package:finpay/config/images.dart';
import 'package:finpay/config/textstyle.dart';
import 'package:finpay/controller/home_controller.dart';
import 'package:finpay/controller/reserva_controller.dart';
import 'package:finpay/utils/utiles.dart';
import 'package:finpay/view/home/top_up_screen.dart';
import 'package:finpay/view/home/transfer_screen.dart';
import 'package:finpay/view/home/widget/circle_card.dart';
import 'package:finpay/view/home/widget/custom_card.dart';
import 'package:finpay/view/home/widget/transaction_list.dart';
import 'package:finpay/view/reservas/reservas_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class HomeView extends StatelessWidget {
  final HomeController homeController;

  const HomeView({Key? key, required this.homeController}) : super(key: key);

  Future<int> obtenerPagosRealizadosMesActual() async {
    final pagosPath = await _getFilePath('pagos.json');
    final pagosData = await _readJsonFile(pagosPath);

    final ahora = DateTime.now();
    final mesActual = ahora.month;
    final anioActual = ahora.year;

    return pagosData.where((pago) {
      final fechaPago = DateTime.parse(pago["fechaPago"]);
      return fechaPago.month == mesActual && fechaPago.year == anioActual;
    }).length;
  }

  Future<int> obtenerPagosPendientes() async {
    final pagosPath = await _getFilePath('pagos.json');
    final pagosData = await _readJsonFile(pagosPath);

    return pagosData.where((pago) => pago["status"] == "PENDIENTE").length;
  }

  Future<int> obtenerCantidadAutos() async {
    final autosPath = await _getFilePath('autos.json');
    final autosData = await _readJsonFile(autosPath);

    return autosData.length;
  }

  Future<String> _getFilePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName';
  }

  Future<List<dynamic>> _readJsonFile(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      return [];
    }
    final content = await file.readAsString();
    return json.decode(content);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.isLightTheme == false
          ? const Color(0xff15141F)
          : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Good morning",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).textTheme.bodySmall!.color,
                          ),
                    ),
                    Text(
                      "Resumen del mes",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                          ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      height: 28,
                      width: 69,
                      decoration: BoxDecoration(
                        color: const Color(0xffF6A609).withOpacity(0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            DefaultImages.ranking,
                          ),
                          Text(
                            "Gold",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: const Color(0xffF6A609),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: Image.asset(
                        DefaultImages.avatar,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: FutureBuilder(
              future: Future.wait([
                obtenerPagosRealizadosMesActual(),
                obtenerPagosPendientes(),
                obtenerCantidadAutos(),
              ]),
              builder: (context, AsyncSnapshot<List<int>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text("Error al cargar datos"));
                }

                final pagosRealizados = snapshot.data![0];
                final pagosPendientes = snapshot.data![1];
                final cantidadAutos = snapshot.data![2];

                return Column(
                  children: [
                    _buildResumenCard(
                      title: "Pagos realizados este mes",
                      value: pagosRealizados.toString(),
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    _buildResumenCard(
                      title: "Pagos pendientes",
                      value: pagosPendientes.toString(),
                      icon: Icons.access_time,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    _buildResumenCard(
                      title: "Cantidad de autos registrados",
                      value: cantidadAutos.toString(),
                      icon: Icons.directions_car,
                      color: Colors.blue,
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.isLightTheme == false
                              ? HexColor('#15141f')
                              : Theme.of(context).appBarTheme.backgroundColor,
                          border: Border.all(
                            color: HexColor(AppTheme.primaryColorString!)
                                .withOpacity(0.05),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            children: [
                              customContainer(
                                title: "USD",
                                background: AppTheme.primaryColorString,
                                textColor: Colors.white,
                              ),
                              const SizedBox(width: 5),
                              customContainer(
                                title: "IDR",
                                background: AppTheme.isLightTheme == false
                                    ? '#211F32'
                                    : "#FFFFFF",
                                textColor: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
                              )
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.add,
                            color: HexColor(AppTheme.primaryColorString!),
                            size: 20,
                          ),
                          Text(
                            "Add Currency",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: HexColor(AppTheme.primaryColorString!),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: SizedBox(
                    height: 180,
                    width: Get.width,
                    child: Swiper(
                      itemBuilder: (BuildContext context, int index) {
                        return SvgPicture.asset(
                          DefaultImages.debitcard,
                          fit: BoxFit.fill,
                        );
                      },
                      itemCount: 3,
                      viewportFraction: 1,
                      scale: 0.9,
                      autoplay: true,
                      itemWidth: Get.width,
                      itemHeight: 180,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      focusColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () {
                        Get.to(const TopUpScreen(),
                            transition: Transition.downToUp,
                            duration: const Duration(milliseconds: 500));
                      },
                      child: circleCard(
                        image: DefaultImages.topup,
                        title: "Pagar",
                      ),
                    ),
                    InkWell(
                      focusColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () {},
                      child: circleCard(
                        image: DefaultImages.withdraw,
                        title: "Withdraw",
                      ),
                    ),
                    InkWell(
                      focusColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () {
                        Get.to(
                          () => ReservaScreen(),
                          binding: BindingsBuilder(() {
                            Get.delete<
                                ReservaController>(); // 🔥 elimina instancia previa

                            Get.create(() => ReservaController());
                          }),
                          transition: Transition.downToUp,
                          duration: const Duration(milliseconds: 500),
                        );
                      },
                      child: circleCard(
                        image: DefaultImages.transfer,
                        title: "Reservar",
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 30),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 10, right: 10, bottom: 50),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.isLightTheme == false
                          ? const Color(0xff211F32)
                          : const Color(0xffFFFFFF),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff000000).withOpacity(0.10),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Pagos Previos",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Obx(() {
                          return Column(
                            children: homeController.pagosPrevios.map((pago) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  leading: const Icon(Icons.payments_outlined),
                                  title: Text(
                                      "Reserva: ${pago.codigoReservaAsociada}"),
                                  subtitle: Text(
                                      "Fecha: ${UtilesApp.formatearFechaDdMMAaaa(pago.fechaPago)}"),
                                  trailing: Text(
                                    "- ${UtilesApp.formatearGuaranies(pago.montoPagado)}",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        }),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
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
            Icon(icon, color: color, size: 40),
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
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
