import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ruletafirebase/src/modelos/detalleActividad.dart';
import 'package:ruletafirebase/src/modelos/modelo.dart';
import 'package:ruletafirebase/src/screens/detalles.dart';

class CardDetalle extends StatefulWidget {
  const CardDetalle({
    Key key,
    @required this.posicion,
    @required this.actividades,
    @required this.tipoRuleta,
    @required this.detalles,
  }) : super(key: key);

  final List<Actividad> actividades;
  final List<DetalleActividad> detalles;
  final int posicion;
  final String tipoRuleta;

  @override
  State<CardDetalle> createState() => _CardDetalleState();
}

class _CardDetalleState extends State<CardDetalle> {
  Actividad actividad;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    actividad = widget.actividades[widget.posicion];
    double width = MediaQuery.of(context).size.width;

    DetalleActividad getDetalle() {
      DetalleActividad detalle;
      for (int i = 0; i < widget.detalles.length; i++) {
        if (widget.detalles.elementAt(i).idActividad == actividad.id) {
          detalle = widget.detalles.elementAt(i);
        }
      }
      return detalle;
    }

    Widget detallesDescripcion = Container(
      alignment: Alignment.centerLeft,
      width: (width < 221)
          ? (MediaQuery.of(context).size.width / 2) - 46
          : (width > 645)
              ? (width / 2) - 161
              : width - 156,
      height: 50,
      child: Text(
        actividad.descripcion,
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );

    Widget estrellas = Row(
      children: [
        Icon(
          Icons.star,
          color: Colors.amber,
        ),
        Text(
          getDetalle().calificacion.toString(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ],
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        // ignore: deprecated_member_use
        child: RaisedButton(
          color: Color(widget.actividades.elementAt(widget.posicion).color)
              .withOpacity(0.7),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Detalle(
                  posicion: widget.posicion,
                  actividades: widget.actividades,
                  detalles: widget.detalles,
                  tipoRuleta: widget.tipoRuleta,
                ),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.all(10),
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
                Expanded(
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        detallesDescripcion,
                        estrellas,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
