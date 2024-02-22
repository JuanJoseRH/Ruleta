import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ruletafirebase/src/modelos/modelo.dart';
import 'package:ruletafirebase/src/widgets/card_actividad.dart';

class VerActividades extends StatefulWidget {
  VerActividades({Key key}) : super(key: key);

  @override
  _VerActividadesState createState() => _VerActividadesState();
}

class _VerActividadesState extends State<VerActividades> {
  int posicion = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final actividad =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text("Actividades de " + actividad['tipo']),
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
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('actividades')
                .where('tipo', isEqualTo: actividad['tipo'])
                .orderBy('numero')
                .snapshots(includeMetadataChanges: true),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Ocurrio algun error al momento de cargar los datos',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.data.size != 0) {
                  List<QueryDocumentSnapshot> docs = snapshot.data.docs;
                  List<Actividad> actividadesList = [];
                  for (var i = 0; i < docs.length; i++) {
                    actividadesList.add(
                      Actividad(
                        id: docs.elementAt(i).id,
                        descripcion: docs.elementAt(i)['descripcion'],
                        numero: docs.elementAt(i)['numero'],
                        color: docs.elementAt(i)['color'],
                        estado: docs.elementAt(i)['estado'],
                        tipo: docs.elementAt(i)['tipo'],
                      ),
                    );
                  }
                  return _listActividades(actividadesList);
                }
              }

              return Center(
                child: CircularProgressIndicator(),
              );
            }),
      ),
    );
  }

  Widget _listActividades(List<Actividad> actividades) {
    final horientacion = MediaQuery.of(context).orientation;
    double width = MediaQuery.of(this.context).size.width;
    double height = MediaQuery.of(this.context).size.height;

    Column lista = Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          child: Text(
            'Actividades',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              Actividad actividad = actividades[index];
              return CardActividad(
                actividad: actividad,
              );
            },
            itemCount: actividades.length,
          ),
        ),
      ],
    );

    return horientacion == Orientation.portrait
        ? lista
        : (width < 645)
            ? lista
            : Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Actividades',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: (height < 400) ? 2 : 3,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        Actividad actividad = actividades[index];
                        return CardActividad(
                          actividad: actividad,
                        );
                      },
                      itemCount: actividades.length,
                    ),
                  ),
                ],
              );
  }
}
