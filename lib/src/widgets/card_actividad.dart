import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ruletafirebase/src/modelos/modelo.dart';
import 'package:ruletafirebase/src/screens/ruletaPersonalizada.dart';
import 'package:ruletafirebase/src/screens/ruletaView.dart';

class CardActividad extends StatelessWidget {
  const CardActividad({Key key, @required this.actividad}) : super(key: key);

  final Actividad actividad;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    Container lista = Container(
      width: (width < 221)
          ? (MediaQuery.of(context).size.width / 2) - 110
          : (width > 645)
              ? (width / 2) - 227
              : width - 222,
      child: Text(
        actividad.descripcion,
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );

    FloatingActionButton btnEditar = FloatingActionButton(
      heroTag: null,
      backgroundColor: Colors.transparent,
      elevation: 0,
      onPressed: () {
        if (actividad.estado == 'Terminada') {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('¡Atencion!'),
                content: Text("No puedes editar una actividad terminada"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Vale'),
                  )
                ],
              );
            },
          );
        } else {
          Navigator.pushNamed(
            context,
            '/editarActividad',
            arguments: {
              'id': actividad.id,
              'numero': actividad.numero,
              'descripcion': actividad.descripcion,
              'color': actividad.color,
              'estado': actividad.estado,
              'tipo': actividad.tipo,
            },
          );
        }
      },
      child: Container(
        width: 30,
        height: 30,
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
          Icons.edit,
          color: Colors.white,
        ),
      ),
    );

    FloatingActionButton btnEliminar = FloatingActionButton(
      heroTag: null,
      backgroundColor: Colors.transparent,
      elevation: 0,
      onPressed: () async {
        if (actividad.estado == 'en proceso') {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('¡Atencion!'),
                content: Text("No puedes eliminar una actividad en proceso"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Vale'),
                  )
                ],
              );
            },
          );
        } else {
          if (actividad.estado == 'Terminada') {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('¡Atencion!'),
                  content: Text("No puedes eliminar una actividad terminada"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Vale'),
                    )
                  ],
                );
              },
            );
          } else {
            if (await confirm(
              context,
              title: Text("Borrar actividad"),
              content: Text(
                  "¿Desea borrar la actividad: " + actividad.descripcion + "?"),
              textOK: Text("Borrar"),
              textCancel: Text("Cancelar"),
            )) {
              FirebaseFirestore.instance
                  .collection('actividades')
                  .doc(actividad.id)
                  .delete();
              Navigator.pop(context);
              if (actividad.tipo == "Casa") {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => RuletaView(
                      tipoRuleta: "Casa",
                    ),
                  ),
                );
              } else {
                if (actividad.tipo == "Salidas") {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => RuletaView(
                        tipoRuleta: "Salidas",
                      ),
                    ),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RuletaPersonalizada(),
                    ),
                  );
                }
              }
            }
          }
        }
      },
      child: Container(
        width: 30,
        height: 30,
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
          Icons.delete,
          color: Colors.white,
        ),
      ),
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Color(actividad.color).withOpacity(0.7),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Container(
          margin: EdgeInsets.all(20),
          child: Row(
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
                    ),
                  ),
                ),
              ),
              SizedBox(width: 20),
              lista,
              btnEditar,
              btnEliminar,
            ],
          ),
        ),
      ),
    );
  }
}
