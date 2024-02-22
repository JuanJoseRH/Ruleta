import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ruletafirebase/src/modelos/modelo.dart';
import 'package:ruletafirebase/src/screens/ruletaPersonalizada.dart';
import 'package:ruletafirebase/src/screens/ruletaView.dart';

class AgregarActividad extends StatefulWidget {
  final String tipoRuleta;
  AgregarActividad({Key key, this.tipoRuleta}) : super(key: key);

  @override
  _AgregarActividadState createState() => _AgregarActividadState();
}

class _AgregarActividadState extends State<AgregarActividad> {
  TextEditingController textDescripcionCtrl = TextEditingController();
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List actividades = [];
    List<Actividad> _item = [];

    final actividad =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;

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
      onPressed: () async {
        List<String> lista = textDescripcionCtrl.text.split("\n");
        int id = 0;
        int nume = 1;
        await FirebaseFirestore.instance
            .collection("actividades")
            .where('estado', isEqualTo: 'sin asignar')
            .where('tipo', isEqualTo: actividad['tipo'])
            .orderBy('numero')
            .get()
            .then((value) {
          if (value.docs.length != 0) {
            for (var doc in value.docs) {
              actividades.add(doc.data());
              print(actividades);
            }
          }
        });

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

        for (int i = 0; i < lista.length; i++) {
          if (_item.length != 0) {
            id = _item.elementAt(_item.length - 1).numero + 1;
            nume = _item.elementAt(_item.length - 1).numero + 1;
          }

          while (id > 7) {
            id -= 8;
          }

          Actividad actividadResiente = Actividad(
            numero: nume,
            descripcion: lista[i],
            color: colores.elementAt(id),
            tipo: actividad['tipo'],
            estado: "sin asignar",
          );

          _item.add(actividadResiente);

          FirebaseFirestore.instance.collection("actividades").add({
            'numero': actividadResiente.numero,
            'descripcion': actividadResiente.descripcion,
            'color': actividadResiente.color,
            'tipo': actividadResiente.tipo,
            'estado': actividadResiente.estado,
          });
        }

        Navigator.of(context).pop();
        if (actividad['tipo'] == "Casa") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RuletaView(
                tipoRuleta: "Casa",
              ),
            ),
          );
        } else {
          if (actividad['tipo'] == "Salidas") {
            Navigator.pushReplacement(
              context,
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
          'Agregar actividad de ' + actividad['tipo'],
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Agregar actividad"),
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
          child: ListView(
            children: [
              SizedBox(height: 20),
              Center(
                child: Text(
                  "Agregar actividad de " + actividad['tipo'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width -
                          (MediaQuery.of(context).size.width - 30),
                      vertical: 20),
                  child: textDescripcion),
              Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width -
                        (MediaQuery.of(context).size.width - 30),
                  ),
                  child: btnAgregar),
            ],
          ),
        ),
      ),
    );
  }
}
