import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ruletafirebase/src/screens/ruletaPersonalizada.dart';
import 'package:ruletafirebase/src/screens/ruletaView.dart';

class EditarActividad extends StatefulWidget {
  EditarActividad({Key key}) : super(key: key);

  @override
  _EditarActividadState createState() => _EditarActividadState();
}

class _EditarActividadState extends State<EditarActividad> {
  @override
  Widget build(BuildContext context) {
    TextEditingController textDescripcionCtrl = TextEditingController();
    final actividad =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    textDescripcionCtrl.text = actividad['descripcion'];

    final textDescripcion = TextFormField(
      maxLines: 10,
      controller: textDescripcionCtrl,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white24,
        prefixIcon: Icon(Icons.description),
        labelText: 'Descripcion',
        labelStyle: TextStyle(color: Colors.white54),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      style: TextStyle(color: Colors.white, fontSize: 15),
    );

    final btnAgregar = ElevatedButton(
      onPressed: () {
        FirebaseFirestore.instance
            .collection('actividades')
            .doc(actividad['id'])
            .update(
          {
            'descripcion': textDescripcionCtrl.text,
          },
        );

        Navigator.pop(context);
        Navigator.pop(context);
        if (actividad['tipo'] == "Casa") {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => RuletaView(
                tipoRuleta: "Casa",
              ),
            ),
          );
        } else {
          if (actividad['tipo'] == "Salidas") {
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
              MaterialPageRoute(builder: (context) => RuletaPersonalizada()),
            );
          }
        }
      },
      style: ElevatedButton.styleFrom(
        textStyle: TextStyle(color: Colors.white),
        padding: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              colors: <Color>[
                Color(0xFFFF4F2C),
                Color(0xFFEF2295),
              ],
            )),
        padding: EdgeInsets.all(15.0),
        width: 10000,
        child: Text(
          'Guardar',
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Editar actividad"),
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListView(
              children: [
                SizedBox(height: 20),
                Center(
                  child: Text(
                    "Editar actividad número " +
                        actividad['numero'].toString() +
                        " de " +
                        actividad['tipo'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                textDescripcion,
                SizedBox(height: 20),
                btnAgregar,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
