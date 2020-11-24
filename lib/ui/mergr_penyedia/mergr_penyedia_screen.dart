import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mergers/app_localizations.dart';

import 'package:mergers/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mergers/services/firestore_database.dart';
import 'package:provider/provider.dart';

import 'package:mergers/models/mergr_penyedia_model.dart';
import 'package:mergers/ui/mergr_penyedia/empty_content.dart';

import 'package:mergers/ui/drawer/app_drawer.dart';
import 'package:docx_template/docx_template.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

enum PrintOpt {
  PrintKualifikasi,
  PrintPernyataan,
  PrintPeralatan,
  PrintPersonel,
  PrintReferensi,
}

class MergrPenyediaScreen extends StatelessWidget {
  // var printOption = PrintOpt.PrintKualifikasi;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('Merger Penyedia'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).pushNamed(
            Routes.create_edit_mergr_penyedia,
          );
        },
      ),
      body: WillPopScope(
          onWillPop: () async => false, child: _buildBodySection(context)),
    );
  }

  Widget _buildBodySection(BuildContext context) {
    final firestoreDatabase =
        Provider.of<FirestoreDatabase>(context, listen: false);

    return StreamBuilder(
        stream: firestoreDatabase.mergrPenyediasStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<MergrPenyediaModel> mergrPenyedia = snapshot.data;
            if (mergrPenyedia.isNotEmpty) {
              return ListView.separated(
                itemCount: mergrPenyedia.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    background: Container(
                      color: Colors.red,
                      child: Center(
                          child: Text(
                        AppLocalizations.of(context)
                            .translate("todosDismissibleMsgTxt"),
                        style: TextStyle(color: Theme.of(context).canvasColor),
                      )),
                    ),
                    key: Key(mergrPenyedia[index].id),
                    // onDismissed: (direction) {
                    //   firestoreDatabase.deleteTodo(peralatan[index]);

                    //   _scaffoldKey.currentState.showSnackBar(SnackBar(
                    //     backgroundColor: Theme.of(context).appBarTheme.color,
                    //     content: Text(
                    //       AppLocalizations.of(context)
                    //               .translate("todosSnackBarContent") +
                    //           todos[index].task,
                    //       style:
                    //           TextStyle(color: Theme.of(context).canvasColor),
                    //     ),
                    //     duration: Duration(seconds: 3),
                    //     action: SnackBarAction(
                    //       label: AppLocalizations.of(context)
                    //           .translate("todosSnackBarActionLbl"),
                    //       textColor: Theme.of(context).canvasColor,
                    //       onPressed: () {
                    //         firestoreDatabase.setTodo(todos[index]);
                    //       },
                    //     ),
                    //   ));
                    // },
                    child: ListTile(
                      title: Text(mergrPenyedia[index].aNamaBadanUsaha),
                      trailing: _printOpt(
                          context, mergrPenyedia[index].aNamaBadanUsaha),
                      onTap: () {
                        Navigator.of(context).pushNamed(
                            Routes.create_edit_mergr_penyedia,
                            arguments: mergrPenyedia[index]);
                      },
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(height: 0.5);
                },
              );
            } else {
              return EmptyContentWidget(
                title: 'Tidak ada data penyedia',
                message: 'Tap + untuk menambah penyedia',
              );
            }
          } else if (snapshot.hasError) {
            return EmptyContentWidget(
              title: AppLocalizations.of(context)
                  .translate("peralatanErrorTopMsgTxt"),
              message: AppLocalizations.of(context)
                  .translate("peralatanErrorBottomMsgTxt"),
            );
          }
          return Center(child: CircularProgressIndicator());
        });
  }

  Widget _printOpt(BuildContext context, String a) {
    return PopupMenuButton(
      onSelected: (PrintOpt selectedValue) {
        if (selectedValue == PrintOpt.PrintKualifikasi) {
          genDocxKualifikasiV2(context, a);
        } else if (selectedValue == PrintOpt.PrintPernyataan) {
          genDocxPernyataanV2(context, a);
        } else if (selectedValue == PrintOpt.PrintPeralatan) {
          genDocxPeralatanV2(context, a);
        } else if (selectedValue == PrintOpt.PrintPersonel) {
          genDocxPersonelV2(context, a);
        } else if (selectedValue == PrintOpt.PrintReferensi) {
          genDocxReferensiV2(context, a);
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          child: Text('Doc Kualifikasi'),
          value: PrintOpt.PrintKualifikasi,
        ),
        PopupMenuItem(
          child: Text('Doc Pernyataan'),
          value: PrintOpt.PrintPernyataan,
        ),
        PopupMenuItem(
          child: Text('Doc Peralatan'),
          value: PrintOpt.PrintPeralatan,
        ),
        PopupMenuItem(
          child: Text('Doc Personel'),
          value: PrintOpt.PrintPersonel,
        ),
        PopupMenuItem(
          child: Text('Doc Referensi'),
          value: PrintOpt.PrintReferensi,
        ),
      ],
      icon: Icon(Icons.more_vert),
    );
  }

  void genDocxPernyataan(BuildContext context, String q1) async {
    // **** data1
    Map<String, dynamic> data1 = {};
    final qSnap1 = await Firestore.instance
        .collection('mergrPenyedia')
        .where('aNamaBadanUsaha', isEqualTo: q1)
        .getDocuments();
    for (DocumentSnapshot ds in qSnap1.documents) {
      data1 = ds.data;
    }
    // print(data1['xx1Tempat']);

    // **** data2
    Map<String, dynamic> data2 = {};
    final qSnap2 = await Firestore.instance
        .collection('masterPenyedia')
        .where('aNamaBadanUsaha', isEqualTo: q1)
        .getDocuments();
    for (DocumentSnapshot ds in qSnap2.documents) {
      data2 = ds.data;
    }
    // print(data2['cNama']);

    // // **** data3
    // List<Map<String, dynamic>> data3 = [];
    // final qSnap3 = await Firestore.instance
    //     .collection('mergrPersonel')
    //     .where('aNamaBadanUsaha', isEqualTo: q1)
    //     .getDocuments();
    // for (DocumentSnapshot ds in qSnap3.documents) {
    //   data3.add(ds.data);
    //   print(data3);
    // }
    // print('data3.length >> ${data3.length}');
    // print(data3);

    // start mergr doc
    FilePickerResult result = await FilePicker.platform.pickFiles();

    if (result == null) {
      print('no file selected');
      return;
    }

    File file = File(result.files.single.path);
    // print(file.absolute);
    final docx = await DocxTemplate.fromBytes(await file.readAsBytes());
    try {
      Content c = Content();

      c
            ..add(TextContent('cNama', data2['cNama']))
            ..add(TextContent('cJabatan', data2['cJabatan']))
            ..add(TextContent('aNamaBadanUsaha', data1['aNamaBadanUsaha']))
            ..add(TextContent('aAlamatPusat', data2['aAlamatPusat']))
            ..add(TextContent('aTelpPusat', data2['aTelpPusat']))
            ..add(TextContent('aEmailPusat', data2['aEmailPusat']))
            ..add(TextContent('xxTempat', data1['xx1Tempat']))
            ..add(TextContent('xxWaktu', data1['xx1Waktu']))
            ..add(TextContent('aNamaBadanUsaha', data1['aNamaBadanUsaha']))
            ..add(TextContent('cNama', data2['cNama']))
            ..add(TextContent('cJabatan', data2['cJabatan']))
            ..add(TextContent('xx1NamaPaket', data1['xx1NamaPaket']))
            ..add(TextContent(
                'xx1InstansiPemberiTugas', data1['xx1InstansiPemberiTugas']))

          //
          ;

      final d = await docx.generate(c);

      final Directory extDir = await getExternalStorageDirectory();
      final String dirPath = extDir.path.toString().substring(0, 20);
      await Directory(dirPath).create(recursive: true);
      final String filePath = '$dirPath';
      final of = new File('$filePath' +
          'Pictures/generated Mergr Pernyataan ${data1['aNamaBadanUsaha']}.docx');
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
      await of.writeAsBytes(d);
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content:
            Text('Mergr Pernyataan ${data1['aNamaBadanUsaha']} selesai dibuat'),
        duration: Duration(seconds: 3),
      ));
    } catch (err) {
      print(err);
    }
  }

  void genDocxKualifikasi(BuildContext context, String q1) async {
    // **** data1
    Map<String, dynamic> data1 = {};
    final qSnap1 = await Firestore.instance
        .collection('mergrPenyedia')
        .where('aNamaBadanUsaha', isEqualTo: q1)
        .getDocuments();
    for (DocumentSnapshot ds in qSnap1.documents) {
      data1 = ds.data;
    }
    // print(data1['xx1Tempat']);

    // **** data2
    Map<String, dynamic> data2 = {};
    final qSnap2 = await Firestore.instance
        .collection('masterPenyedia')
        .where('aNamaBadanUsaha', isEqualTo: q1)
        .getDocuments();
    for (DocumentSnapshot ds in qSnap2.documents) {
      data2 = ds.data;
    }
    // print(data2['cNama']);

    // **** data3
    List<Map<String, dynamic>> data3 = [];
    final qSnap3 = await Firestore.instance
        .collection('mergrPersonel')
        .where('aNamaBadanUsaha', isEqualTo: q1)
        .getDocuments();
    for (DocumentSnapshot ds in qSnap3.documents) {
      data3.add(ds.data);
      // print(data3);
    }
    // print('data3.length >> ${data3.length}');
    // print(data3);

    // **** data5 -- ij pengalaman
    List<Map<String, dynamic>> data5 = [];
    final qSnap5 = await Firestore.instance
        .collection('masterPengalaman')
        .where('iNamaPenyedia', isEqualTo: q1)
        .getDocuments();
    for (DocumentSnapshot ds in qSnap5.documents) {
      data5.add(ds.data);
      print(data5);
    }

    // **** data6 -- k pengalaman
    List<Map<String, dynamic>> data6 = [];
    final qSnap6 = await Firestore.instance
        .collection('masterPekerjaan')
        .where('kNamaPenyedia', isEqualTo: q1)
        .getDocuments();
    for (DocumentSnapshot ds in qSnap6.documents) {
      data6.add(ds.data);
      print(data6);
    }

    // start mergr doc
    FilePickerResult result = await FilePicker.platform.pickFiles();

    if (result == null) {
      print('no file selected');
      return;
    }

    File file = File(result.files.single.path);
    // print(file.absolute);
    final docx = await DocxTemplate.fromBytes(await file.readAsBytes());
    try {
      Content c = Content();

      // tabel personel H
      List<RowContent> aRow = [];
      for (int i = 0; i < data3.length; i++) {
        // **** data
        List<Map<String, dynamic>> data4 = [];
        final qSnap4 = await Firestore.instance
            .collection('masterPersonel')
            .where('hNama', isEqualTo: data3[i]['xhNama'])
            .getDocuments();
        for (DocumentSnapshot ds in qSnap4.documents) {
          data4.add(ds.data);
          // print(data4);
        }
        aRow.add(
          RowContent()
            ..add(TextContent("xxNo", i + 1))
            ..add(TextContent("xxNama", data3[i]['xhNama']))
            ..add(TextContent("xxPendidikan", data4[0]['hPendidikan']))
            ..add(TextContent("xxJabatan", data4[0]['hJabatan']))
            ..add(TextContent("xxPengalaman", data4[0]['hPengalaman']))
            ..add(TextContent("xxSertifikat", data4[0]['hSertifikat']))
            ..add(TextContent("xxBukti", data4[0]['hSetor'])),
        );
      }
      c..add(TableContent("table", aRow));

      // tabel personel I
      c
        // ..add(TextContent("jNo", i + 1))
        ..add(TextContent("iNamaPenyedia", data5[0]['iNamaPenyedia']))
        ..add(TextContent("iSubKlasifikasi", data5[0]['iSubKlasifikasi']))
        ..add(TextContent("iLingkup", data5[0]['iLingkup']))
        ..add(TextContent("iLokasi", data5[0]['iLokasi']))
        ..add(TextContent("iNamaPejabat", data5[0]['iNamaPejabat']))
        ..add(TextContent("iAlamatPejabat", data5[0]['iAlamatPejabat']))
        ..add(TextContent("iTeleponPejabat", data5[0]['iTeleponPejabat']))
        ..add(TextContent("iNomorKontrak", data5[0]['iNomorKontrak']))
        ..add(TextContent("iTanggalKontrak", data5[0]['iTanggalKontrak']))
        ..add(TextContent("iNilaiKontrak", data5[0]['iNilaiKontrak']))
        ..add(TextContent("iTanggalKontrakPho", data5[0]['iTanggalKontrakPho']))
        ..add(TextContent("iBaKontrakPho", data5[0]['iBaKontrakPho']));

      // tabel personel J
      List<RowContent> aRowJ = [];
      for (int i = 0; i < data5.length; i++) {
        // **** data
        aRowJ.add(
          RowContent()
            ..add(TextContent("jNo", i + 1))
            ..add(TextContent("jNamaPenyedia", data5[i]['iNamaPenyedia']))
            ..add(TextContent("jLingkup", data5[i]['iLingkup']))
            ..add(TextContent("jLokasi", data5[i]['iLokasi']))
            ..add(TextContent("jNamaPejabat", data5[i]['iNamaPejabat']))
            ..add(TextContent("jAlamatPejabat", data5[i]['iAlamatPejabat']))
            ..add(TextContent("jTeleponPejabat", data5[i]['iTeleponPejabat']))
            ..add(TextContent("jNomorKontrak", data5[i]['iNomorKontrak']))
            ..add(TextContent("jTanggalKontrak", data5[i]['iTanggalKontrak']))
            ..add(TextContent("jNilaiKontrak", data5[i]['iNilaiKontrak']))
            ..add(TextContent(
                "jTanggalKontrakPho", data5[i]['iTanggalKontrakPho']))
            ..add(TextContent("jBaKontrakPho", data5[i]['iBaKontrakPho'])),
        );
      }
      c..add(TableContent("tablej", aRowJ));

      // tabel personel K
      List<RowContent> aRowK = [];
      for (int i = 0; i < data6.length; i++) {
        // **** data
        aRowK.add(
          RowContent()
            ..add(TextContent("kNo", i + 1))
            ..add(TextContent("kNamaPenyedia", data6[i]['kNamaPenyedia']))
            ..add(TextContent("kKlasifikasi", data6[i]['kKlasifikasi']))
            ..add(TextContent("kSubKlasifikasi", data6[i]['kSubKlasifikasi']))
            ..add(TextContent("kLokasi", data6[i]['kLokasi']))
            ..add(TextContent("kNamaPejabat", data6[i]['kNamaPejabat']))
            ..add(TextContent("kAlamatPejabat", data6[i]['kAlamatPejabat']))
            ..add(TextContent("kTeleponPejabat", data6[i]['kTeleponPejabat']))
            ..add(TextContent("kNomorKontrak", data6[i]['kNomorKontrak']))
            ..add(TextContent("kTanggalKontrak", data6[i]['kTanggalKontrak']))
            ..add(TextContent("kNilaiKontrak", data6[i]['kNilaiKontrak']))
            ..add(TextContent("kNomorProgres", data6[i]['kNomorProgres']))
            ..add(TextContent("kTanggalProgres", data6[i]['kTanggalProgres']))
            ..add(TextContent("kTotalProgres", data6[i]['kTotalProgres'])),
        );
      }
      c..add(TableContent("tablek", aRowK));

      c
            // perihal
            ..add(TextContent('xx1Tempat', data1['xx1Tempat']))
            ..add(TextContent('xx1Waktu', data1['xx1Waktu']))
            ..add(TextContent(
                'xx1NomorSuratPenawaran', data1['xx1NomorSuratPenawaran']))
            ..add(TextContent(
                'xx1InstansiPemberiTugas', data1['xx1InstansiPemberiTugas']))
            ..add(TextContent(
                'xx1NomorSuratPenwaran', data1['xx1NomorSuratPenwaran']))
            ..add(TextContent('xx1Tempat', data1['xx1Tempat']))
            ..add(TextContent('xx1NamaPaket', data1['xx1NamaPaket']))
            ..add(TextContent('xx1NomorUndangan', data1['xx1NomorUndangan']))
            ..add(
                TextContent('xx1TanggalUndangan', data1['xx1TanggalUndangan']))
            ..add(TextContent('xx1NamaPaket', data1['xx1NamaPaket']))
            ..add(TextContent('xx1NilaiPenawaran', data1['xx1NilaiPenawaran']))
            ..add(TextContent('xx1JangkaWaktu', data1['xx1JangkaWaktu']))
            ..add(TextContent('xx1MasaBerlaku', data1['xx1MasaBerlaku']))
            ..add(TextContent('xx1Tempat', data1['xx1Tempat']))
            ..add(TextContent('xx1Waktu', data1['xx1Waktu']))
            ..add(TextContent('aNamaBadanUsaha', data1['aNamaBadanUsaha']))
            ..add(TextContent('cNama', data2['cNama']))
            ..add(TextContent('cJabatan', data2['cJabatan']))
            // pakta integritas
            ..add(TextContent('cNama', data2['cNama']))
            ..add(TextContent('cJabatan', data2['cJabatan']))
            ..add(TextContent('aNamaBadanUsaha', data1['aNamaBadanUsaha']))
            ..add(TextContent('xx1NamaPaket', data1['xx1NamaPaket']))
            ..add(TextContent(
                'xx1InstansiPemberiTugas', data1['xx1InstansiPemberiTugas']))
            ..add(TextContent('xx1Tempat', data1['xx1Tempat']))
            ..add(TextContent('xx1Waktu', data1['xx1Waktu']))
            ..add(TextContent('aNamaBadanUsaha', data1['aNamaBadanUsaha']))
            ..add(TextContent('cNama', data2['cNama']))
            ..add(TextContent('cJabatan', data2['cJabatan']))
            // isian
            ..add(TextContent('cNama', data2['cNama']))
            ..add(TextContent('cNomor', data2['cNomor']))
            ..add(TextContent('cJabatan', data2['cJabatan']))
            ..add(TextContent('aNamaBadanUsaha', data1['aNamaBadanUsaha']))
            ..add(TextContent('aAlamatPusat', data2['aAlamatPusat']))
            ..add(TextContent('aTelpPusat', data2['aTelpPusat']))
            ..add(TextContent('aEmailPusat', data2['aEmailPusat']))
            ..add(TextContent('bNomor', data2['bNomor']))
            ..add(TextContent('bTanggal', data2['bTanggal']))
            ..add(TextContent('bNamaNotaris', data2['bNamaNotaris']))
            // A
            ..add(TextContent('aNamaBadanUsaha', data1['aNamaBadanUsaha']))
            ..add(TextContent('aAlamatPusat', data2['aAlamatPusat']))
            ..add(TextContent('aTelpPusat', data2['aTelpPusat']))
            ..add(TextContent('aFaxPusat', data2['aFaxPusat']))
            ..add(TextContent('aEmailPusat', data2['aEmailPusat']))
            ..add(TextContent('bNomor', data2['bNomor']))
            ..add(TextContent('bTanggal', data2['bTanggal']))
            ..add(TextContent('bNamaNotaris', data2['bNamaNotaris']))
            ..add(TextContent('bNomorPengesahan', data2['bNomorPengesahan']))
            // C
            ..add(TextContent('cNama', data2['cNama']))
            ..add(TextContent('cNomor', data2['cNomor']))
            ..add(TextContent('cJabatan', data2['cJabatan']))
            // D
            ..add(TextContent('dNomor', data2['dNomor']))
            ..add(TextContent('dTanggal', data2['dTanggal']))
            ..add(TextContent('dMasa', data2['dMasa']))
            ..add(TextContent('dInstansi', data2['dInstansi']))
            // E
            ..add(TextContent('eNomor', data2['eNomor']))
            ..add(TextContent('eTanggal', data2['eTanggal']))
            ..add(TextContent('eMasa', data2['eMasa']))
            ..add(TextContent('eInstansi', data2['eInstansi']))
            ..add(TextContent('eKualifikasi', data2['eKualifikasi']))
            ..add(TextContent('eKlasifikasi', data2['eKlasifikasi']))
            ..add(TextContent('eSubKlasifikasi', data2['eSubKlasifikasi']))
            // G
            ..add(TextContent('g1Nama', data2['g1Nama']))
            ..add(TextContent('g1Identitas', data2['g1Identitas']))
            ..add(TextContent('g1Alamat', data2['g1Alamat']))
            ..add(TextContent('g1Persentase', data2['g1Persentase']))
            ..add(TextContent('g2Npwp', data2['g2Npwp']))
            ..add(TextContent('g2Nomor', data2['g2Nomor']))
            ..add(TextContent('g2Tanggal', data2['g2Tanggal']))
            // H

            // I

            // J
            ..add(TextContent('xxTempat', data1['xx1Tempat']))
            ..add(TextContent('xxWaktu', data1['xx1Waktu']))
            ..add(TextContent('aNamaBadanUsaha', data1['aNamaBadanUsaha']))
            ..add(TextContent('cNama', data2['cNama']))
            ..add(TextContent('cJabatan', data2['cJabatan']))
            // K
            ..add(TextContent('xxTempat', data1['xx1Tempat']))
            ..add(TextContent('xxWaktu', data1['xx1Waktu']))
            ..add(TextContent('aNamaBadanUsaha', data1['aNamaBadanUsaha']))
            ..add(TextContent('cNama', data2['cNama']))
            ..add(TextContent('cJabatan', data2['cJabatan']))
          //
          ;

      final d = await docx.generate(c);

      final Directory extDir = await getExternalStorageDirectory();
      final String dirPath = extDir.path.toString().substring(0, 20);
      await Directory(dirPath).create(recursive: true);
      final String filePath = '$dirPath';
      final of = new File('$filePath' +
          'Pictures/generated Mergr Kualifikasi ${data1['aNamaBadanUsaha']}.docx');
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
      await of.writeAsBytes(d);
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
            'Mergr Kualifikasi ${data1['aNamaBadanUsaha']} selesai dibuat'),
        duration: Duration(seconds: 3),
      ));
    } catch (err) {
      print(err);
    }
  }

  Future<String> get _localDocPath async {
    final Directory extDir = await getExternalStorageDirectory();
    final String dirPath = extDir.path.toString().substring(0, 20);
    await Directory(dirPath).create(recursive: true);
    return dirPath;
    // final String fileDocPath = '$dirPath';
  }

  void genDocxKualifikasiV2(BuildContext context, String q1) async {
    final docPath = await _localDocPath;

   var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Dokumen sedang di proses...'),
      duration: Duration(seconds: 1),
    ));

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Loading database...'),
      duration: Duration(seconds: 1),
    ));

    ////////// ********** start data

    // **** data1
    Map<String, dynamic> data1 = {};
    final qSnap1 = await Firestore.instance
        .collection('mergrPenyedia')
        .where('aNamaBadanUsaha', isEqualTo: q1)
        .getDocuments();
    for (DocumentSnapshot ds in qSnap1.documents) {
      data1 = ds.data;
    }
    // print(data1['xx1Tempat']);

    // **** data2
    Map<String, dynamic> data2 = {};
    final qSnap2 = await Firestore.instance
        .collection('masterPenyedia')
        .where('aNamaBadanUsaha', isEqualTo: q1)
        .getDocuments();
    for (DocumentSnapshot ds in qSnap2.documents) {
      data2 = ds.data;
    }
    // print(data2['cNama']);

    // **** data3
    List<Map<String, dynamic>> data3 = [];
    final qSnap3 = await Firestore.instance
        .collection('mergrPersonel')
        .where('aNamaBadanUsaha', isEqualTo: q1)
        .getDocuments();
    for (DocumentSnapshot ds in qSnap3.documents) {
      data3.add(ds.data);
      // print(data3);
    }
    // print('data3.length >> ${data3.length}');
    // print(data3);

    // **** data5 -- ij pengalaman
    List<Map<String, dynamic>> data5 = [];
    final qSnap5 = await Firestore.instance
        .collection('masterPengalaman')
        .where('iNamaPenyedia', isEqualTo: q1)
        .getDocuments();
    for (DocumentSnapshot ds in qSnap5.documents) {
      data5.add(ds.data);
      // print(data5);
    }

    // **** data6 -- k pengalaman
    List<Map<String, dynamic>> data6 = [];
    final qSnap6 = await Firestore.instance
        .collection('masterPekerjaan')
        .where('kNamaPenyedia', isEqualTo: q1)
        .getDocuments();
    for (DocumentSnapshot ds in qSnap6.documents) {
      data6.add(ds.data);
      // print(data6);
    }

    // start mergr doc
    // FilePickerResult result = await FilePicker.platform.pickFiles();

    // if (result == null) {
    //   print('no file selected');
    //   return;
    // }

    File file = File('$docPath' + 'Pictures/mDocKualifikasi_v1.docx');

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Opening template...'),
      duration: Duration(seconds: 1),
    ));

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Merging...'),
      duration: Duration(seconds: 1),
    ));

    // File file = File(result.files.single.path);
    // print(result.files.single.path);
    final docx = await DocxTemplate.fromBytes(await file.readAsBytes());
    try {
      Content c = Content();

      // tabel personel H
      List<RowContent> aRow = [];
      for (int i = 0; i < data3.length; i++) {
        // **** data
        List<Map<String, dynamic>> data4 = [];
        final qSnap4 = await Firestore.instance
            .collection('masterPersonel')
            .where('hNama', isEqualTo: data3[i]['xhNama'])
            .getDocuments();
        for (DocumentSnapshot ds in qSnap4.documents) {
          data4.add(ds.data);
          // print(data4);
        }
        aRow.add(
          RowContent()
            ..add(TextContent("xxNo", i + 1))
            ..add(TextContent("xxNama", data3[i]['xhNama']))
            ..add(TextContent("xxPendidikan", data4[0]['hPendidikan']))
            ..add(TextContent("xxJabatan", data4[0]['hJabatan']))
            ..add(TextContent("xxPengalaman", data4[0]['hPengalaman']))
            ..add(TextContent("xxSertifikat", data4[0]['hSertifikat']))
            ..add(TextContent("xxBukti", data4[0]['hSetor'])),
        );
      }
      c..add(TableContent("table", aRow));

      // tabel personel I
      c
        // ..add(TextContent("jNo", i + 1))
        ..add(TextContent("iNamaPenyedia", data5[0]['iNamaPenyedia']))
        ..add(TextContent("iSubKlasifikasi", data5[0]['iSubKlasifikasi']))
        ..add(TextContent("iLingkup", data5[0]['iLingkup']))
        ..add(TextContent("iLokasi", data5[0]['iLokasi']))
        ..add(TextContent("iNamaPejabat", data5[0]['iNamaPejabat']))
        ..add(TextContent("iAlamatPejabat", data5[0]['iAlamatPejabat']))
        ..add(TextContent("iTeleponPejabat", data5[0]['iTeleponPejabat']))
        ..add(TextContent("iNomorKontrak", data5[0]['iNomorKontrak']))
        ..add(TextContent("iTanggalKontrak", data5[0]['iTanggalKontrak']))
        ..add(TextContent("iNilaiKontrak", data5[0]['iNilaiKontrak']))
        ..add(TextContent("iTanggalKontrakPho", data5[0]['iTanggalKontrakPho']))
        ..add(TextContent("iBaKontrakPho", data5[0]['iBaKontrakPho']));

      // tabel personel J
      List<RowContent> aRowJ = [];
      for (int i = 0; i < data5.length; i++) {
        // **** data
        aRowJ.add(
          RowContent()
            ..add(TextContent("jNo", i + 1))
            ..add(TextContent("jNamaPenyedia", data5[i]['iNamaPenyedia']))
            ..add(TextContent("jLingkup", data5[i]['iLingkup']))
            ..add(TextContent("jLokasi", data5[i]['iLokasi']))
            ..add(TextContent("jNamaPejabat", data5[i]['iNamaPejabat']))
            ..add(TextContent("jAlamatPejabat", data5[i]['iAlamatPejabat']))
            ..add(TextContent("jTeleponPejabat", data5[i]['iTeleponPejabat']))
            ..add(TextContent("jNomorKontrak", data5[i]['iNomorKontrak']))
            ..add(TextContent("jTanggalKontrak", data5[i]['iTanggalKontrak']))
            ..add(TextContent("jNilaiKontrak", data5[i]['iNilaiKontrak']))
            ..add(TextContent(
                "jTanggalKontrakPho", data5[i]['iTanggalKontrakPho']))
            ..add(TextContent("jBaKontrakPho", data5[i]['iBaKontrakPho'])),
        );
      }
      c..add(TableContent("tablej", aRowJ));

      // tabel personel K
      List<RowContent> aRowK = [];
      for (int i = 0; i < data6.length; i++) {
        // **** data
        aRowK.add(
          RowContent()
            ..add(TextContent("kNo", i + 1))
            ..add(TextContent("kNamaPenyedia", data6[i]['kNamaPenyedia']))
            ..add(TextContent("kKlasifikasi", data6[i]['kKlasifikasi']))
            ..add(TextContent("kSubKlasifikasi", data6[i]['kSubKlasifikasi']))
            ..add(TextContent("kLokasi", data6[i]['kLokasi']))
            ..add(TextContent("kNamaPejabat", data6[i]['kNamaPejabat']))
            ..add(TextContent("kAlamatPejabat", data6[i]['kAlamatPejabat']))
            ..add(TextContent("kTeleponPejabat", data6[i]['kTeleponPejabat']))
            ..add(TextContent("kNomorKontrak", data6[i]['kNomorKontrak']))
            ..add(TextContent("kTanggalKontrak", data6[i]['kTanggalKontrak']))
            ..add(TextContent("kNilaiKontrak", data6[i]['kNilaiKontrak']))
            ..add(TextContent("kNomorProgres", data6[i]['kNomorProgres']))
            ..add(TextContent("kTanggalProgres", data6[i]['kTanggalProgres']))
            ..add(TextContent("kTotalProgres", data6[i]['kTotalProgres'])),
        );
      }
      c..add(TableContent("tablek", aRowK));

      c
            // perihal
            ..add(TextContent('xx1Tempat', data1['xx1Tempat']))
            ..add(TextContent('xx1Waktu', data1['xx1Waktu']))
            ..add(TextContent(
                'xx1NomorSuratPenawaran', data1['xx1NomorSuratPenawaran']))
            ..add(TextContent(
                'xx1InstansiPemberiTugas', data1['xx1InstansiPemberiTugas']))
            ..add(TextContent(
                'xx1NomorSuratPenwaran', data1['xx1NomorSuratPenwaran']))
            ..add(TextContent('xx1Tempat', data1['xx1Tempat']))
            ..add(TextContent('xx1NamaPaket', data1['xx1NamaPaket']))
            ..add(TextContent('xx1NomorUndangan', data1['xx1NomorUndangan']))
            ..add(
                TextContent('xx1TanggalUndangan', data1['xx1TanggalUndangan']))
            ..add(TextContent('xx1NamaPaket', data1['xx1NamaPaket']))
            ..add(TextContent('xx1NilaiPenawaran', data1['xx1NilaiPenawaran']))
            ..add(TextContent('xx1JangkaWaktu', data1['xx1JangkaWaktu']))
            ..add(TextContent('xx1MasaBerlaku', data1['xx1MasaBerlaku']))
            ..add(TextContent('xx1Tempat', data1['xx1Tempat']))
            ..add(TextContent('xx1Waktu', data1['xx1Waktu']))
            ..add(TextContent('aNamaBadanUsaha', data1['aNamaBadanUsaha']))
            ..add(TextContent('cNama', data2['cNama']))
            ..add(TextContent('cJabatan', data2['cJabatan']))
            // pakta integritas
            ..add(TextContent('cNama', data2['cNama']))
            ..add(TextContent('cJabatan', data2['cJabatan']))
            ..add(TextContent('aNamaBadanUsaha', data1['aNamaBadanUsaha']))
            ..add(TextContent('xx1NamaPaket', data1['xx1NamaPaket']))
            ..add(TextContent(
                'xx1InstansiPemberiTugas', data1['xx1InstansiPemberiTugas']))
            ..add(TextContent('xx1Tempat', data1['xx1Tempat']))
            ..add(TextContent('xx1Waktu', data1['xx1Waktu']))
            ..add(TextContent('aNamaBadanUsaha', data1['aNamaBadanUsaha']))
            ..add(TextContent('cNama', data2['cNama']))
            ..add(TextContent('cJabatan', data2['cJabatan']))
            // isian
            ..add(TextContent('cNama', data2['cNama']))
            ..add(TextContent('cNomor', data2['cNomor']))
            ..add(TextContent('cJabatan', data2['cJabatan']))
            ..add(TextContent('aNamaBadanUsaha', data1['aNamaBadanUsaha']))
            ..add(TextContent('aAlamatPusat', data2['aAlamatPusat']))
            ..add(TextContent('aTelpPusat', data2['aTelpPusat']))
            ..add(TextContent('aEmailPusat', data2['aEmailPusat']))
            ..add(TextContent('bNomor', data2['bNomor']))
            ..add(TextContent('bTanggal', data2['bTanggal']))
            ..add(TextContent('bNamaNotaris', data2['bNamaNotaris']))
            // A
            ..add(TextContent('aNamaBadanUsaha', data1['aNamaBadanUsaha']))
            ..add(TextContent('aAlamatPusat', data2['aAlamatPusat']))
            ..add(TextContent('aTelpPusat', data2['aTelpPusat']))
            ..add(TextContent('aFaxPusat', data2['aFaxPusat']))
            ..add(TextContent('aEmailPusat', data2['aEmailPusat']))
            ..add(TextContent('bNomor', data2['bNomor']))
            ..add(TextContent('bTanggal', data2['bTanggal']))
            ..add(TextContent('bNamaNotaris', data2['bNamaNotaris']))
            ..add(TextContent('bNomorPengesahan', data2['bNomorPengesahan']))
            // C
            ..add(TextContent('cNama', data2['cNama']))
            ..add(TextContent('cNomor', data2['cNomor']))
            ..add(TextContent('cJabatan', data2['cJabatan']))
            // D
            ..add(TextContent('dNomor', data2['dNomor']))
            ..add(TextContent('dTanggal', data2['dTanggal']))
            ..add(TextContent('dMasa', data2['dMasa']))
            ..add(TextContent('dInstansi', data2['dInstansi']))
            // E
            ..add(TextContent('eNomor', data2['eNomor']))
            ..add(TextContent('eTanggal', data2['eTanggal']))
            ..add(TextContent('eMasa', data2['eMasa']))
            ..add(TextContent('eInstansi', data2['eInstansi']))
            ..add(TextContent('eKualifikasi', data2['eKualifikasi']))
            ..add(TextContent('eKlasifikasi', data2['eKlasifikasi']))
            ..add(TextContent('eSubKlasifikasi', data2['eSubKlasifikasi']))
            // G
            ..add(TextContent('g1Nama', data2['g1Nama']))
            ..add(TextContent('g1Identitas', data2['g1Identitas']))
            ..add(TextContent('g1Alamat', data2['g1Alamat']))
            ..add(TextContent('g1Persentase', data2['g1Persentase']))
            ..add(TextContent('g2Npwp', data2['g2Npwp']))
            ..add(TextContent('g2Nomor', data2['g2Nomor']))
            ..add(TextContent('g2Tanggal', data2['g2Tanggal']))
            // H

            // I

            // J
            ..add(TextContent('xxTempat', data1['xx1Tempat']))
            ..add(TextContent('xxWaktu', data1['xx1Waktu']))
            ..add(TextContent('aNamaBadanUsaha', data1['aNamaBadanUsaha']))
            ..add(TextContent('cNama', data2['cNama']))
            ..add(TextContent('cJabatan', data2['cJabatan']))
            // K
            ..add(TextContent('xxTempat', data1['xx1Tempat']))
            ..add(TextContent('xxWaktu', data1['xx1Waktu']))
            ..add(TextContent('aNamaBadanUsaha', data1['aNamaBadanUsaha']))
            ..add(TextContent('cNama', data2['cNama']))
            ..add(TextContent('cJabatan', data2['cJabatan']))
          //
          ;

      ////////// ********** end data

      final d = await docx.generate(c);

      final of = new File('$docPath' +
          'Pictures/generated Mergr Kualifikasi ${data1['aNamaBadanUsaha']}.docx');
      // var status = await Permission.storage.status;
      // if (!status.isGranted) {
      //   await Permission.storage.request();
      // }
      await of.writeAsBytes(d);
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
            'Mergr Kualifikasi ${data1['aNamaBadanUsaha']} selesai dibuat'),
        duration: Duration(seconds: 3),
      ));
    } catch (err) {
      print(err);
    }
  }

  void genDocxPeralatanV2(BuildContext context, String q1) async {
    final docPath = await _localDocPath;

    var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Dokumen sedang di proses...'),
      duration: Duration(seconds: 1),
    ));

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Loading database...'),
      duration: Duration(seconds: 1),
    ));

    // **** data1
    Map<String, dynamic> data1 = {};
    final qSnap1 = await Firestore.instance
        .collection('mergrPenyedia')
        .where('aNamaBadanUsaha', isEqualTo: q1)
        .getDocuments();
    for (DocumentSnapshot ds in qSnap1.documents) {
      data1 = ds.data;
    }
    print(data1['xx1Tempat']);

    // **** data2
    Map<String, dynamic> data2 = {};
    final qSnap2 = await Firestore.instance
        .collection('masterPenyedia')
        .where('aNamaBadanUsaha', isEqualTo: q1)
        .getDocuments();
    for (DocumentSnapshot ds in qSnap2.documents) {
      data2 = ds.data;
    }
    print(data2['cNama']);

    // **** data3
    List<Map<String, dynamic>> data3 = [];
    final qSnap3 = await Firestore.instance
        .collection('mergrPeralatanDetail')
        .where('aNamaBadanUsaha', isEqualTo: q1)
        .getDocuments();
    for (DocumentSnapshot ds in qSnap3.documents) {
      data3.add(ds.data);
      print(data3);
    }
    print('data3.length >> ${data3.length}');
    print(data3);

    // start mergr doc
    // FilePickerResult result = await FilePicker.platform.pickFiles();

    // if (result == null) {
    //   print('no file selected');
    // }
    // File file = File(result.files.single.path);
    // print(file.absolute);

    File file = File('$docPath' + 'Pictures/mDocPeralatan_v1.docx');

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Opening template...'),
      duration: Duration(seconds: 1),
    ));

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Merging...'),
      duration: Duration(seconds: 1),
    ));

    final docx = await DocxTemplate.fromBytes(await file.readAsBytes());
    try {
      Content c = Content();

      List<RowContent> aRow = [];
      for (int i = 0; i < data3.length; i++) {
        // **** data
        List<Map<String, dynamic>> data4 = [];
        final qSnap4 = await Firestore.instance
            .collection('masterPeralatan')
            .where('xJenis', isEqualTo: data3[i]['xJenis'])
            .getDocuments();
        for (DocumentSnapshot ds in qSnap4.documents) {
          data4.add(ds.data);
          // print(data4);
        }
        aRow.add(
          RowContent()
            ..add(TextContent("xxNo", i + 1))
            ..add(TextContent("xxJenis", data3[i]['xJenis']))
            ..add(TextContent("xxMerk", data4[0]['xMerk']))
            ..add(TextContent("xxLokasi", data4[0]['xLokasi']))
            ..add(TextContent("xxKapasitas", data4[0]['xKapasitas']))
            ..add(TextContent("xxJumlah", data4[0]['xJumlah']))
            ..add(TextContent("xxStatus", data4[0]['xStatus'])),
        );
      }

      c
        //** doc peralatan */
        //** part tabel */
        ..add(TableContent("table", aRow));
      //** part ttd */
      c
        ..add(TextContent('xxTempat', data1['xx1Tempat']))
        ..add(TextContent('xxWaktu', data1['xx1Waktu']))
        ..add(TextContent('aNamaBadanUsaha', data1['aNamaBadanUsaha']))
        ..add(TextContent('cNama', data2['cNama']))
        ..add(TextContent('cJabatan', data2['cJabatan']));

      final d = await docx.generate(c);

      // final Directory extDir = await getExternalStorageDirectory();
      // final String dirPath = extDir.path.toString().substring(0, 20);
      // await Directory(dirPath).create(recursive: true);
      // final String filePath = '$dirPath';
      final of = new File('$docPath' +
          'Pictures/generated Mergr Peralatan ${data1['aNamaBadanUsaha']}.docx');
      // var status = await Permission.storage.status;
      // if (!status.isGranted) {
      //   await Permission.storage.request();
      // }
      await of.writeAsBytes(d);
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content:
            Text('Mergr Peralatan ${data1['aNamaBadanUsaha']} selesai dibuat'),
        duration: Duration(seconds: 3),
      ));
    } catch (err) {
      print(err);
    }
  }

  void genDocxPernyataanV2(BuildContext context, String q1) async {
    final docPath = await _localDocPath;

    var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Dokumen sedang di proses...'),
      duration: Duration(seconds: 1),
    ));

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Loading database...'),
      duration: Duration(seconds: 1),
    ));


    // **** data1
    Map<String, dynamic> data1 = {};
    final qSnap1 = await Firestore.instance
        .collection('mergrPenyedia')
        .where('aNamaBadanUsaha', isEqualTo: q1)
        .getDocuments();
    for (DocumentSnapshot ds in qSnap1.documents) {
      data1 = ds.data;
    }
    // print(data1['xx1Tempat']);

    // **** data2
    Map<String, dynamic> data2 = {};
    final qSnap2 = await Firestore.instance
        .collection('masterPenyedia')
        .where('aNamaBadanUsaha', isEqualTo: q1)
        .getDocuments();
    for (DocumentSnapshot ds in qSnap2.documents) {
      data2 = ds.data;
    }
    // print(data2['cNama']);

    // // **** data3
    // List<Map<String, dynamic>> data3 = [];
    // final qSnap3 = await Firestore.instance
    //     .collection('mergrPersonel')
    //     .where('aNamaBadanUsaha', isEqualTo: q1)
    //     .getDocuments();
    // for (DocumentSnapshot ds in qSnap3.documents) {
    //   data3.add(ds.data);
    //   print(data3);
    // }
    // print('data3.length >> ${data3.length}');
    // print(data3);

    // start mergr doc
    // FilePickerResult result = await FilePicker.platform.pickFiles();

    // if (result == null) {
    //   print('no file selected');
    //   return;
    // }

    // File file = File(result.files.single.path);
    // print(file.absolute);
    File file = File('$docPath' + 'Pictures/mDocPernyataan_v1.docx');

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Opening template...'),
      duration: Duration(seconds: 1),
    ));

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Merging...'),
      duration: Duration(seconds: 1),
    ));


    final docx = await DocxTemplate.fromBytes(await file.readAsBytes());
    try {
      Content c = Content();

      c
            ..add(TextContent('cNama', data2['cNama']))
            ..add(TextContent('cJabatan', data2['cJabatan']))
            ..add(TextContent('aNamaBadanUsaha', data1['aNamaBadanUsaha']))
            ..add(TextContent('aAlamatPusat', data2['aAlamatPusat']))
            ..add(TextContent('aTelpPusat', data2['aTelpPusat']))
            ..add(TextContent('aEmailPusat', data2['aEmailPusat']))
            ..add(TextContent('xxTempat', data1['xx1Tempat']))
            ..add(TextContent('xxWaktu', data1['xx1Waktu']))
            ..add(TextContent('aNamaBadanUsaha', data1['aNamaBadanUsaha']))
            ..add(TextContent('cNama', data2['cNama']))
            ..add(TextContent('cJabatan', data2['cJabatan']))
            ..add(TextContent('xx1NamaPaket', data1['xx1NamaPaket']))
            ..add(TextContent(
                'xx1InstansiPemberiTugas', data1['xx1InstansiPemberiTugas']))

          //
          ;

      final d = await docx.generate(c);

      // final Directory extDir = await getExternalStorageDirectory();
      // final String dirPath = extDir.path.toString().substring(0, 20);
      // await Directory(dirPath).create(recursive: true);
      // final String filePath = '$dirPath';
      final of = new File('$docPath' +
          'Pictures/generated Mergr Pernyataan ${data1['aNamaBadanUsaha']}.docx');
      // var status = await Permission.storage.status;
      // if (!status.isGranted) {
      //   await Permission.storage.request();
      // }
      await of.writeAsBytes(d);
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content:
            Text('Mergr Pernyataan ${data1['aNamaBadanUsaha']} selesai dibuat'),
        duration: Duration(seconds: 3),
      ));
    } catch (err) {
      print(err);
    }
  }

  void genDocxPersonelV2(BuildContext context, String q1) async {
    final docPath = await _localDocPath;

    var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Dokumen sedang di proses...'),
      duration: Duration(seconds: 1),
    ));

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Loading database...'),
      duration: Duration(seconds: 1),
    ));

    // **** data1
    Map<String, dynamic> data1 = {};
    final qSnap1 = await Firestore.instance
        .collection('mergrPenyedia')
        .where('aNamaBadanUsaha', isEqualTo: q1)
        .getDocuments();
    for (DocumentSnapshot ds in qSnap1.documents) {
      data1 = ds.data;
    }
    // print(data1['xx1Tempat']);

    // **** data2
    Map<String, dynamic> data2 = {};
    final qSnap2 = await Firestore.instance
        .collection('masterPenyedia')
        .where('aNamaBadanUsaha', isEqualTo: q1)
        .getDocuments();
    for (DocumentSnapshot ds in qSnap2.documents) {
      data2 = ds.data;
    }
    // print(data2['cNama']);

    // **** data3
    List<Map<String, dynamic>> data3 = [];
    final qSnap3 = await Firestore.instance
        .collection('mergrPersonel')
        .where('aNamaBadanUsaha', isEqualTo: q1)
        .getDocuments();
    for (DocumentSnapshot ds in qSnap3.documents) {
      data3.add(ds.data);
      print(data3);
    }
    // print('data3.length >> ${data3.length}');
    // print(data3);

    // start mergr doc
    // FilePickerResult result = await FilePicker.platform.pickFiles();

    // if (result == null) {
    //   print('no file selected');
    // }
    // File file = File(result.files.single.path);
    // print(file.absolute);

    

    File file = File('$docPath' + 'Pictures/mDocPersonel_v1.docx');

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Opening template...'),
      duration: Duration(seconds: 1),
    ));

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Merging...'),
      duration: Duration(seconds: 1),
    ));

    final docx = await DocxTemplate.fromBytes(await file.readAsBytes());
    try {
      Content c = Content();

      List<RowContent> aRow = [];
      for (int i = 0; i < data3.length; i++) {
        // **** data
        List<Map<String, dynamic>> data4 = [];
        final qSnap4 = await Firestore.instance
            .collection('masterPersonel')
            .where('hNama', isEqualTo: data3[i]['xhNama'])
            .getDocuments();
        for (DocumentSnapshot ds in qSnap4.documents) {
          data4.add(ds.data);
          // print(data4);
        }
        aRow.add(
          RowContent()
            ..add(TextContent("xxNo", i + 1))
            ..add(TextContent("xxNama", data3[i]['xhNama']))
            ..add(TextContent("xxPendidikan", data4[0]['hPendidikan']))
            ..add(TextContent("xxJabatan", data4[0]['hJabatan']))
            ..add(TextContent("xxPengalaman", data4[0]['hPengalaman']))
            ..add(TextContent("xxSertifikat", data4[0]['hSertifikat']))
            ..add(TextContent("xxBukti", data4[0]['hSetor'])),
        );
      }

      c
        //** doc peralatan */
        //** part tabel */
        ..add(TableContent("table", aRow));
      //** part ttd */
      c
        ..add(TextContent('xxTempat', data1['xx1Tempat']))
        ..add(TextContent('xxWaktu', data1['xx1Waktu']))
        ..add(TextContent('aNamaBadanUsaha', data1['aNamaBadanUsaha']))
        ..add(TextContent('cNama', data2['cNama']))
        ..add(TextContent('cJabatan', data2['cJabatan']));

      final d = await docx.generate(c);

      // final Directory extDir = await getExternalStorageDirectory();
      // final String dirPath = extDir.path.toString().substring(0, 20);
      // await Directory(dirPath).create(recursive: true);
      // final String filePath = '$dirPath';



      final of = new File('$docPath' +
          'Pictures/generated Mergr Personel ${data1['aNamaBadanUsaha']}.docx');
      
      await of.writeAsBytes(d);
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content:
            Text('Mergr Personel ${data1['aNamaBadanUsaha']} selesai dibuat'),
        duration: Duration(seconds: 3),
      ));
    } catch (err) {
      print(err);
    }
  }

  void genDocxReferensiV2(BuildContext context, String q1) async {
    final docPath = await _localDocPath;

   var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Dokumen sedang di proses...'),
      duration: Duration(seconds: 1),
    ));

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Loading database...'),
      duration: Duration(seconds: 1),
    ));

    // **** data1
    Map<String, dynamic> data1 = {};
    final qSnap1 = await Firestore.instance
        .collection('mergrPenyedia')
        .where('aNamaBadanUsaha', isEqualTo: q1)
        .getDocuments();
    for (DocumentSnapshot ds in qSnap1.documents) {
      data1 = ds.data;
    }
    print(data1);

    // **** data2
    Map<String, dynamic> data2 = {};
    final qSnap2 = await Firestore.instance
        .collection('masterPenyedia')
        .where('aNamaBadanUsaha', isEqualTo: q1)
        .getDocuments();
    for (DocumentSnapshot ds in qSnap2.documents) {
      data2 = ds.data;
    }
    print(data2);

    // **** data3
    List<Map<String, dynamic>> data3 = [];
    final qSnap3 = await Firestore.instance
        .collection('mergrPersonel')
        .where('aNamaBadanUsaha', isEqualTo: q1)
        .getDocuments();
    for (DocumentSnapshot ds in qSnap3.documents) {
      data3.add(ds.data);
      print(data3);
    }
    // print('data3.length >> ${data3.length}');
    // print(data3);

    // start mergr doc
    // FilePickerResult result = await FilePicker.platform.pickFiles();

    // if (result == null) {
    //   print('no file selected');
    // }
    // File file = File(result.files.single.path);
    // // print(file.absolute);

    File file = File('$docPath' + 'Pictures/mDocReferensi_v1.docx');

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Opening template...'),
      duration: Duration(seconds: 1),
    ));

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Merging...'),
      duration: Duration(seconds: 1),
    ));

    final docx = await DocxTemplate.fromBytes(await file.readAsBytes());
    try {
      Content c = Content();

      // List<PlainContent> aRow = [];
      final aRow = <PlainContent>[];
      List<Map<String, dynamic>> data4 = [];
      for (int i = 0; i < data3.length; i++) {
        final qSnap4 = await Firestore.instance
            .collection('masterReferensi')
            .where('xxx1Nama', isEqualTo: data3[i]['xhNama'])
            .getDocuments();
        for (DocumentSnapshot ds in qSnap4.documents) {
          data4.add(ds.data);
        }
      }

      for (int i = 0; i < data3.length; i++) {
        for (int ii = 0; ii < data4.length; ii++) {
          // print(data1['aNamaBadanUsaha']);
          // print(data2['cNama']);
          // print(data2['cJabatan']);
          // print(data2['aAlamatPusat']);
          aRow.add(PlainContent('xxx1Repeat')
                ..add(
                    TextContent("xxx1NomorSurat", data4[ii]['xxx1NomorSurat']))
                ..add(TextContent("aNamaBadanUsaha", data1['aNamaBadanUsaha']))
                ..add(TextContent("cNama", data2['cNama']))
                ..add(TextContent("cJabatan", data2['cJabatan']))
                ..add(TextContent("cAlamat", data2['aAlamatPusat']))
                ..add(TextContent("xxx1Nama", data4[ii]['xxx1Nama']))
                ..add(TextContent("xxx1Alamat", data4[ii]['xxx1Alamat']))
                ..add(TextContent("xxx1Jabatan", data4[ii]['xxx1Jabatan']))
                ..add(TextContent(
                    "xxx1NamaKontrak", data4[ii]['xxx1NamaKontrak']))
                ..add(TextContent(
                    "xxx1NomorKontrak", data4[ii]['xxx1NomorKontrak']))
                ..add(TextContent("xxx1Instansi", data4[ii]['xxx1Instansi']))
                ..add(TextContent("xxx1Periode", data4[ii]['xxx1Periode']))
                ..add(TextContent("aNamaBadanUsaha", data1['aNamaBadanUsaha']))
                ..add(TextContent("cNama", data2['cNama']))
                ..add(TextContent("cJabatan", data2['cJabatan']))
                ..add(TextContent("xxx1Tempat", data4[ii]['xxx1Tempat']))
                ..add(TextContent("xxx1Waktu", data4[ii]['xxx1Waktu']))
                ..add(TextContent("xxx1Instansi", data4[ii]['xxx1Instansi']))
                ..add(TextContent(
                    "xxx1NamaPejabat", data4[ii]['xxx1NamaPejabat']))
                ..add(
                    TextContent("xxx1NipPejabat", data4[ii]['xxx1NipPejabat']))
              // ..add(TextContent("xxx1Nama", data3[i]['xhNama'])
              );
        }
      }

      c..add(ListContent('ListRepeat', aRow));

      final d = await docx.generate(c);

      // final Directory extDir = await getExternalStorageDirectory();
      // final String dirPath = extDir.path.toString().substring(0, 20);
      // await Directory(dirPath).create(recursive: true);
      // final String filePath = '$dirPath';
      final of = new File('$docPath' +
          'Pictures/generated Mergr Referensi ${data1['aNamaBadanUsaha']}.docx');
      // var status = await Permission.storage.status;
      // if (!status.isGranted) {
      //   await Permission.storage.request();
      // }
      await of.writeAsBytes(d);
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content:
            Text('Mergr Referensi ${data1['aNamaBadanUsaha']} selesai dibuat'),
        duration: Duration(seconds: 3),
      ));
    } catch (err) {
      print(err);
    }
  }
}
