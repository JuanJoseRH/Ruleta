import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ruletafirebase/src/modelos/detalleActividad.dart';
import 'package:ruletafirebase/src/modelos/modelo.dart';
import 'package:ruletafirebase/src/widgets/card_detalle.dart';

class ActividadCompletada extends StatefulWidget {
  final String tipoRuleta;
  final List<DetalleActividad> detalles;

  ActividadCompletada(
      {Key key, @required this.tipoRuleta, @required this.detalles})
      : super(key: key);

  @override
  _ActividadCompletadaState createState() => _ActividadCompletadaState();
}

class _ActividadCompletadaState extends State<ActividadCompletada> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('actividades')
            .where('estado', isEqualTo: "Terminada")
            .where('tipo', isEqualTo: widget.tipoRuleta)
            .orderBy('numero')
            .snapshots(includeMetadataChanges: true),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Ocurrio algun error al momento de cargar los datos',
                  style: TextStyle(color: Colors.white)),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data == null || snapshot.data.docs.length == 0) {
            return ListView(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: [
                Center(
                  child: Text(
                    "Sin actividades terminadas",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            );
          }

          if (snapshot.connectionState == ConnectionState.active) {
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

          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget _listActividades(List<Actividad> actividades) {
    Orientation horientacion = MediaQuery.of(context).orientation;
    double width = MediaQuery.of(this.context).size.width;
    double height = MediaQuery.of(this.context).size.height;

    Widget lista = Column(
      children: [
        SizedBox(height: 20),
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(10),
          child: Text(
            'Actividades Completadas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return CardDetalle(
                posicion: index,
                actividades: actividades,
                detalles: widget.detalles,
                tipoRuleta: widget.tipoRuleta,
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
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Actividades Completadas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                      ),
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: (height < 400) ? 2 : 3,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        return CardDetalle(
                          posicion: index,
                          actividades: actividades,
                          detalles: widget.detalles,
                          tipoRuleta: widget.tipoRuleta,
                        );
                      },
                      itemCount: actividades.length,
                    ),
                  ),
                ],
              );
  }
}
