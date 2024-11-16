import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lelang_fb/core/assets/assets.gen.dart';

class ItemsCard extends StatelessWidget {
  final String grade;
  final String imageURL;
  final String judul;
  final String tahunMobil;
  final String tipe;
  final String platNomor;
  final String harga;
  final String tanggal;
  final String bulan;
  final String tahun;
  final String lokasi;
  final String jamBidding;
  const ItemsCard({
    required this.grade,
    required this.imageURL,
    required this.judul,
    required this.tahunMobil,
    required this.tipe,
    required this.platNomor,
    required this.harga,
    required this.tanggal,
    required this.bulan,
    required this.tahun,
    required this.lokasi,
    required this.jamBidding,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20, left: 10, bottom: 20),
      child: Container(
        width: 200,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10), color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset(
                  width: double.infinity,
                  fit: BoxFit.cover,
                  imageURL,
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    height: 12,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: Colors.green,
                    ),
                    child: Center(
                      child: Text(
                        "GRADE " + grade,
                        style: TextStyle(color: Colors.white, fontSize: 8),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    judul,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    tahunMobil + " | " + tipe + " | " + platNomor,
                    style: TextStyle(
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    harga,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green),
                  ),
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/svg/calender.svg',
                      ),
                      Text(
                        tanggal + " " + bulan + " " + tahun,
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 12),
                      Text(
                        lokasi,
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Will Begin",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w300),
                      ),
                      Text(
                        jamBidding,
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w300),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
