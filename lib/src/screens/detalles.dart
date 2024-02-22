import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ruletafirebase/src/modelos/detalleActividad.dart';
import 'package:ruletafirebase/src/modelos/modelo.dart';
import 'package:ruletafirebase/src/screens/ruletaPersonalizada.dart';
import 'package:ruletafirebase/src/screens/ruletaView.dart';

class Detalle extends StatelessWidget {
  const Detalle({
    Key key,
    @required this.posicion,
    @required this.actividades,
    @required this.detalles,
    @required this.tipoRuleta,
  }) : super(key: key);

  final int posicion;
  final List<DetalleActividad> detalles;
  final List<Actividad> actividades;
  final String tipoRuleta;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(actividades[posicion].tipo),
        backgroundColor: Color(0xFF102E89),
      ),
      body: Container(
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
        child: PageView.builder(
          physics: BouncingScrollPhysics(),
          controller: PageController(initialPage: posicion),
          itemCount: detalles.length,
          itemBuilder: (context, index) {
            Actividad actividad = actividades[index];
            DetalleActividad detalle;
            for (int i = 0; i < detalles.length; i++) {
              if (detalles.elementAt(i).idActividad == actividad.id) {
                detalle = detalles.elementAt(i);
              }
            }
            return DetalleCompleto(
              detalle: detalle,
              actividad: actividad,
              tipoRuleta: tipoRuleta,
            );
          },
        ),
      ),
    );
  }
}

class DetalleCompleto extends StatelessWidget {
  const DetalleCompleto({
    Key key,
    @required this.actividad,
    @required this.detalle,
    @required this.tipoRuleta,
  }) : super(key: key);

  final DetalleActividad detalle;
  final Actividad actividad;
  final String tipoRuleta;

  @override
  Widget build(BuildContext context) {
    Orientation horientacion = MediaQuery.of(context).orientation;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    List actividades = [];
    List<Actividad> _item = [];

    //DatabaseLocal _database = DatabaseLocal();
    bool btn1 = false, btn2 = false, btn3 = false, btn4 = false, btn5 = false;

    List<int> colores = [
      0xffff5252,
      0xffe040fb,
      0xff536dfe,
      0xff40c4ff,
      0xff64ffda,
      0xffb2ff59,
      0xffffff00,
      0xffffab40
    ];

    switch (detalle.calificacion) {
      case 1:
        btn1 = true;
        break;
      case 2:
        btn1 = true;
        btn2 = true;
        break;
      case 3:
        btn1 = true;
        btn2 = true;
        btn3 = true;
        break;
      case 4:
        btn1 = true;
        btn2 = true;
        btn3 = true;
        btn4 = true;
        break;
      case 5:
        btn1 = true;
        btn2 = true;
        btn3 = true;
        btn4 = true;
        btn5 = true;
        break;
    }

    Widget encabezado() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Actividad",
            style: TextStyle(color: Colors.white, fontSize: 28),
          ),
          FloatingActionButton(
            onPressed: () async {
              if (await confirm(
                context,
                title: Text("Agregar actividad"),
                content: Text("¿Agregar actividad " +
                    this.actividad.descripcion +
                    " nuevamente?"),
                textCancel: Text("Cancelar"),
                textOK: Text("Agregar"),
              )) {
                int id;
                int nume;
                await FirebaseFirestore.instance
                    .collection("actividades")
                    .where('estado', isEqualTo: 'Terminada')
                    .where('tipo', isEqualTo: tipoRuleta)
                    .get()
                    .then(
                  (value) {
                    if (value.docs.length != 0) {
                      for (var doc in value.docs) {
                        actividades.add(doc.data());
                        print(actividades);
                      }
                    }
                  },
                );

                for (var i = 0; i < actividades.length; i++) {
                  _item.add(
                    Actividad(
                      descripcion: actividades.elementAt(i)['descripcion'],
                      numero: actividades.elementAt(i)['numero'],
                      estado: actividades.elementAt(i)['estado'],
                      color: actividades.elementAt(i)['color'],
                      tipo: actividades.elementAt(i)['tipo'],
                    ),
                  );
                }

                if (_item.length != 0) {
                  id = _item.elementAt(_item.length - 1).numero + 1;
                  nume = _item.elementAt(_item.length - 1).numero + 1;
                }

                while (id > 7) {
                  id -= 8;
                }

                Actividad actividad = Actividad(
                  numero: nume,
                  descripcion: this.actividad.descripcion,
                  color: colores.elementAt(id),
                  estado: "sin asignar",
                  tipo: this.actividad.tipo,
                );

                _item.add(actividad);

                await FirebaseFirestore.instance.collection("actividades").add({
                  'numero': actividad.numero,
                  'descripcion': actividad.descripcion,
                  'color': actividad.color,
                  'tipo': actividad.tipo,
                  'estado': actividad.estado,
                }).then((value) => {
                      if (value != null)
                        {
                          Navigator.of(context).pop(),
                          if (this.actividad.tipo == "Casa")
                            {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RuletaView(
                                    tipoRuleta: "Casa",
                                  ),
                                ),
                              )
                            }
                          else
                            {
                              if (this.actividad.tipo == "Salidas")
                                {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RuletaView(
                                        tipoRuleta: "Salidas",
                                      ),
                                    ),
                                  )
                                }
                              else
                                {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RuletaPersonalizada(),
                                    ),
                                  )
                                }
                            }
                        }
                    });
              }
            },
            child: Icon(Icons.replay_rounded),
            backgroundColor: Colors.transparent,
            elevation: 1,
          ),
        ],
      );
    }

    Widget actividadDescripcion() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
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
                actividad.numero.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          SizedBox(width: 20),
          Container(
            alignment: Alignment.centerLeft,
            width: horientacion == Orientation.portrait
                ? MediaQuery.of(context).size.width - 130
                : (MediaQuery.of(context).size.width / 2) - 40,
            height: 50,
            child: Text(
              actividad.descripcion,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
        ],
      );
    }

    Widget estrellas() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            color: Colors.amber,
            icon: (btn1) ? Icon(Icons.star) : Icon(Icons.star_border),
            onPressed: () {},
          ),
          IconButton(
            color: Colors.amber,
            icon: (btn2) ? Icon(Icons.star) : Icon(Icons.star_border),
            onPressed: () {},
          ),
          IconButton(
            color: Colors.amber,
            icon: (btn3) ? Icon(Icons.star) : Icon(Icons.star_border),
            onPressed: () {},
          ),
          IconButton(
            color: Colors.amber,
            icon: (btn4) ? Icon(Icons.star) : Icon(Icons.star_border),
            onPressed: () {},
          ),
          IconButton(
            color: Colors.amber,
            icon: (btn5) ? Icon(Icons.star) : Icon(Icons.star_border),
            onPressed: () {},
          ),
        ],
      );
    }

    Widget foto() {
      return (detalle.foto.isEmpty)
          ? Container(
              alignment: Alignment.center,
              child: ClipRRect(
                child: Image.asset(
                  "asset/image/foto.png",
                  height: horientacion == Orientation.portrait ? 400 : 250,
                  width: 400,
                  fit: BoxFit.fitHeight,
                ),
              ),
            )
          : Container(
              alignment: Alignment.center,
              child: ClipRRect(
                child: Image.network(
                  detalle.foto,
                  height: horientacion == Orientation.portrait ? 400 : 300,
                  width: 400,
                  fit: BoxFit.fitHeight,
                ),
              ),
            );
    }

    Widget lista = ListView(
      physics: BouncingScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: encabezado(),
        ),
        Column(
          children: [
            SizedBox(height: 20),
            foto(),
            SizedBox(height: 20),
            actividadDescripcion(),
            SizedBox(height: 10),
            estrellas(),
          ],
        ),
      ],
    );

    getWidthDetalle() {
      return horientacion == Orientation.portrait
          ? width - 130
          : (width < 650)
              ? (width / 2) + 50
              : (width / 2) + 100;
    }

    return Container(
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
      child: Container(
        child: horientacion == Orientation.portrait
            ? lista
            : (getWidthDetalle() < 300)
                ? lista
                : ListView(
                    physics: BouncingScrollPhysics(),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                encabezado(),
                                actividadDescripcion(),
                                estrellas(),
                              ],
                            ),
                            width: getWidthDetalle() - 12,
                            height: height,
                          ),
                        ],
                      ),
                    ],
                  ),
      ),
    );
  }
}
