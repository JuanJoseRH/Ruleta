import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ruletafirebase/src/modelos/detalleActividad.dart';
import 'package:ruletafirebase/src/widgets/actividad_completada.dart';
import 'package:ruletafirebase/src/widgets/ruleta.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class RuletaView extends StatefulWidget {
  final String tipoRuleta;

  RuletaView({Key key, this.tipoRuleta}) : super(key: key);

  @override
  _RuletaViewState createState() => _RuletaViewState();
}

class _RuletaViewState extends State<RuletaView> {
  //final List<Actividad> items = [];
  final picker = ImagePicker();

  String imagePath = "";
  bool btn1 = true, btn2 = false, btn3 = false, btn4 = false, btn5 = false;
  int calificacion = 1;
  List<DetalleActividad> detalles = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      getDetalle();
    });
  }

  void getDetalle() async {
    await FirebaseFirestore.instance
        .collection("actividades")
        .where('estado', isEqualTo: 'Terminada')
        .where('tipo', isEqualTo: widget.tipoRuleta)
        .get()
        .then(
          (value) async => {
            if (value.docs.length != 0)
              {
                for (var i = 0; i < value.docs.length; i++)
                  {
                    await FirebaseFirestore.instance
                        .collection("detalles")
                        .where('idActividad',
                            isEqualTo: value.docs.elementAt(i).id)
                        .get()
                        .then(
                          (value) => {
                            if (value.docs.length != 0)
                              {
                                detalles.add(
                                  DetalleActividad(
                                    id: value.docs.elementAt(0).id,
                                    idActividad:
                                        value.docs.elementAt(0)['idActividad'],
                                    calificacion:
                                        value.docs.elementAt(0)['calificacion'],
                                    foto: value.docs.elementAt(0)['foto'],
                                  ),
                                ),
                              },
                          },
                        ),
                  }
              }
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    final Orientation horientacion = MediaQuery.of(context).orientation;
    final double width = MediaQuery.of(this.context).size.width;

    Widget cambiar({String text, DocumentSnapshot data}) {
      return FloatingActionButton(
        onPressed: () async {
          if (await confirm(
            context,
            title: Text("Cambiar actividad"),
            content: Text(text),
            textOK: Text("Si"),
            textCancel: Text("No"),
          )) {
            await FirebaseFirestore.instance
                .collection('actividades')
                .doc(data.id)
                .update({
              'estado': "sin asignar",
            }).then(
              (value) => {
                print("actividad sin asignar"),
                print("Solicitud a firebase"),
                setState(() {}),
              },
            );
          }
        },
        child: Icon(Icons.repeat),
        backgroundColor: Colors.transparent,
        elevation: 1,
      );
    }

    Widget encabezado(DocumentSnapshot data) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Actividad en proceso",
            style: TextStyle(color: Colors.white, fontSize: 28),
          ),
          cambiar(
              text: "¿Desea cambiar la actividad " +
                  data.get('descripcion') +
                  "?",
              data: data),
        ],
      );
    }

    Widget actividad(DocumentSnapshot data) {
      return Row(
        children: [
          ClipRRect(
            child: Container(
              height: 30,
              width: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFF4F2C),
                    Color(0xFFEF2295),
                  ],
                ),
              ),
              child: Text(
                data.get('numero').toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          SizedBox(width: 20),
          Container(
            child: Text(
              data.get('descripcion'),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
        ],
      );
    }

    Row estrellas = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          color: Colors.amber,
          icon: (btn1) ? Icon(Icons.star) : Icon(Icons.star_border),
          onPressed: () {
            setState(() {
              btn1 = true;
              btn2 = false;
              btn3 = false;
              btn4 = false;
              btn5 = false;
              calificacion = 1;
              print("1");
            });
          },
        ),
        IconButton(
          color: Colors.amber,
          icon: (btn2) ? Icon(Icons.star) : Icon(Icons.star_border),
          onPressed: () {
            setState(() {
              btn1 = true;
              btn2 = true;
              btn3 = false;
              btn4 = false;
              btn5 = false;
              calificacion = 2;
              print("2");
            });
          },
        ),
        IconButton(
          color: Colors.amber,
          icon: (btn3) ? Icon(Icons.star) : Icon(Icons.star_border),
          onPressed: () {
            setState(() {
              btn1 = true;
              btn2 = true;
              btn3 = true;
              btn4 = false;
              btn5 = false;
              calificacion = 3;
              print("3");
            });
          },
        ),
        IconButton(
          color: Colors.amber,
          icon: (btn4) ? Icon(Icons.star) : Icon(Icons.star_border),
          onPressed: () {
            setState(() {
              btn1 = true;
              btn2 = true;
              btn3 = true;
              btn4 = true;
              btn5 = false;
              calificacion = 4;
              print("4");
            });
          },
        ),
        IconButton(
          color: Colors.amber,
          icon: (btn5) ? Icon(Icons.star) : Icon(Icons.star_border),
          onPressed: () {
            setState(() {
              btn1 = true;
              btn2 = true;
              btn3 = true;
              btn4 = true;
              btn5 = true;
              calificacion = 5;
              print("5");
            });
          },
        ),
      ],
    );

    Widget agregarFoto() {
      return Container(
        padding: EdgeInsets.fromLTRB(110, 0, 110, 0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            textStyle: TextStyle(color: Colors.white),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: () async {
            final pickedFile =
                await picker.pickImage(source: ImageSource.gallery);
            imagePath = pickedFile.path;
            setState(() => {});
          },
          child: Text(
            'Agregar foto',
            style: TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    Widget foto() {
      return (imagePath.isEmpty)
          ? Container(
              alignment: Alignment.center,
              child: ClipRRect(
                child: Image.asset(
                  "asset/image/foto.png",
                  height: horientacion == Orientation.portrait ? 400 : 250,
                  width: 450,
                ),
              ),
            )
          : Container(
              alignment: Alignment.center,
              child: ClipRRect(
                child: Image.file(
                  File(imagePath),
                  height: horientacion == Orientation.portrait ? 400 : 250,
                  width: 450,
                ),
              ),
            );
    }

    Widget completar(DocumentSnapshot data) {
      return TextButton(
        onPressed: () async {
          var imagenURL;
          if (!imagePath.isEmpty) {
            var imagenNombre = Uuid().v1();
            var imagenPath = "/actividad/${data.id}/${imagenNombre}.jpg";
            final firebase_storage.Reference references =
                firebase_storage.FirebaseStorage.instance.ref(imagenPath);
            await references.putFile(File(imagePath));
            imagenURL = await references.getDownloadURL();
          } else {
            imagenURL = "";
          }

          await FirebaseFirestore.instance.collection("detalles").add({
            'idActividad': data.id,
            'calificacion': calificacion,
            'foto': imagenURL,
          }).then(
            (value) => {
              print('Detalles de actividad agregada\nSolicitud a firabase'),
            },
          );

          await FirebaseFirestore.instance
              .collection('actividades')
              .doc(data.id)
              .update({
            'estado': "Terminada",
          }).then(
            (value) => {
              print("actividad Terminada"),
              print("Solicitud a firebase"),
              detalles.add(
                DetalleActividad(
                  idActividad: data.id,
                  calificacion: calificacion,
                  foto: imagenURL,
                ),
              ),
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('¡Bien!'),
                    content: Text("Actividad terminada"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Vale'),
                      )
                    ],
                  );
                },
              ),
              imagePath = "",
              calificacion = 1,
              btn1 = true,
              btn2 = false,
              btn3 = false,
              btn4 = false,
              btn5 = false,
              setState(() {})
            },
          );
        },
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFF4F2C),
                Color(0xFFEF2295),
              ],
            ),
          ),
          child: Center(
            child: Text(
              "Completar",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
        ),
      );
    }

    Container actividadEnproceso(DocumentSnapshot data) {
      return Container(
        child: ListView(
          shrinkWrap: true,
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.all(15),
          children: [
            encabezado(data),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  actividad(data),
                  SizedBox(height: 20),
                  estrellas,
                  agregarFoto(),
                  SizedBox(height: 10),
                  foto(),
                  SizedBox(height: 20),
                  completar(data),
                ],
              ),
            ),
          ],
        ),
      );
    }

    getWidthDetalle() {
      return horientacion == Orientation.portrait
          ? width - 130
          : (width < 650)
              ? (width / 2) + 50
              : (width / 2) + 100;
    }

    return Scaffold(
      floatingActionButton: btnAgregar(
        tipoRuleta: widget.tipoRuleta,
      ),
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          physics: NeverScrollableScrollPhysics(),
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(widget.tipoRuleta),
                ),
                backgroundColor: Color(0xFF102E89),
              ),
              SliverPersistentHeader(
                floating: false,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    physics: BouncingScrollPhysics(),
                    indicatorColor: Color(0xFFEF2295), //Indicador
                    labelColor: Color(0xFFEF2295), //TabSeleccionado
                    unselectedLabelColor: Colors.white, //TabSinSeleccion
                    tabs: [
                      Tab(icon: Icon(Icons.home)),
                      Tab(icon: Icon(Icons.timer_rounded)),
                      Tab(icon: Icon(Icons.assignment_turned_in_rounded)),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              Ruleta(
                tipoRuleta: widget.tipoRuleta,
              ),
              //Actividad Proceso
              Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF102E89),
                      Color(0xFF020818),
                    ],
                  ),
                ),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('actividades')
                      .where('estado', isEqualTo: "en proceso")
                      .where('tipo', isEqualTo: widget.tipoRuleta)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError)
                      return Center(
                        child: Text(
                            'Ocurrio algun error al momento de cargar los datos'),
                      );
                    else {
                      if (snapshot.data == null ||
                          snapshot.data.docs.length == 0) {
                        return ListView(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          children: [
                            Center(
                              child: Text(
                                "Sin actividades en proceso",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        List<DocumentSnapshot> docs = snapshot.data.docs;
                        return horientacion == Orientation.portrait
                            ? actividadEnproceso(docs.elementAt(0))
                            : (getWidthDetalle() < 300)
                                ? actividadEnproceso(docs.elementAt(0))
                                : ListView(
                                    physics: BouncingScrollPhysics(),
                                    shrinkWrap: true,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            margin: EdgeInsets.all(10),
                                            child: foto(),
                                            width: width / 3,
                                          ),
                                          Container(
                                            child: Column(
                                              children: [
                                                encabezado(docs.elementAt(0)),
                                                actividad(docs.elementAt(0)),
                                                estrellas,
                                                agregarFoto(),
                                                completar(docs.elementAt(0)),
                                              ],
                                            ),
                                            width: getWidthDetalle(),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                      }
                    }
                  },
                ),
              ),
              ActividadCompletada(
                tipoRuleta: widget.tipoRuleta,
                detalles: detalles,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class btnAgregar extends StatelessWidget {
  final String tipoRuleta;
  const btnAgregar({Key key, @required this.tipoRuleta}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pushNamed(
          context,
          '/agregarActividad',
          arguments: {'tipo': tipoRuleta},
        );
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF4F2C),
              Color(0xFFEF2295),
            ],
          ),
        ),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

class btnLista extends StatelessWidget {
  final String tipoRuleta;
  const btnLista({
    Key key,
    @required this.tipoRuleta,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/verLista',
            arguments: {'tipo': tipoRuleta},
          );
        },
        child: Text(
          "Ver ruleta",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class btnActividades extends StatelessWidget {
  final String tipoRuleta;
  const btnActividades({
    Key key,
    @required this.tipoRuleta,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/verActividades',
            arguments: {'tipo': tipoRuleta},
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.view_list_rounded,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Text(
              "Actividades",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      color: Color(0xFF102E89),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
