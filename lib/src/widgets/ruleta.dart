import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ruletafirebase/src/modelos/modelo.dart';
import 'package:ruletafirebase/src/screens/ruletaView.dart';
import 'package:ruletafirebase/src/widgets/board_view.dart';

class Ruleta extends StatefulWidget {
  final String tipoRuleta;

  Ruleta({Key key, @required this.tipoRuleta}) : super(key: key);

  @override
  _RuletaState createState() => _RuletaState();
}

class _RuletaState extends State<Ruleta> with SingleTickerProviderStateMixin {
  double _angle = 0;
  double _current = 0;
  AnimationController _ctrl;
  Animation _ani;

  //Atributos
  List actividades = [];
  List<Actividad> items = [];

  @override
  void initState() {
    super.initState();
    var _duration = Duration(milliseconds: 5000);
    _ctrl = AnimationController(vsync: this, duration: _duration);
    _ani = CurvedAnimation(parent: _ctrl, curve: Curves.fastLinearToSlowEaseIn);
    setState(() {
      getDatos();
    });
  }

  void getDatos() async {
    await FirebaseFirestore.instance
        .collection("actividades")
        .where('estado', isEqualTo: 'sin asignar')
        .where('tipo', isEqualTo: widget.tipoRuleta)
        .orderBy("numero")
        .get()
        .then(
      (value) {
        if (value.docs.length != 0) {
          for (var doc in value.docs) {
            actividades.add(doc.data());
            print("Solicitud a firebase");
          }
        }
        for (var i = 0; i < actividades.length; i++) {
          items.add(
            Actividad(
              id: value.docs[i].id,
              descripcion: actividades.elementAt(i)['descripcion'],
              numero: actividades.elementAt(i)['numero'],
              estado: actividades.elementAt(i)['estado'],
              color: actividades.elementAt(i)['color'],
              tipo: actividades.elementAt(i)['tipo'],
            ),
          );
        }
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Orientation horientacion = MediaQuery.of(this.context).orientation;
    double width = MediaQuery.of(this.context).size.width;

    return Container(
      child: Container(
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
        child: AnimatedBuilder(
          animation: _ani,
          builder: (context, child) {
            final _value = _ani.value;
            final _angle = _value * this._angle;
            if (items == null || items.length == 0) {
              return ListView(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: [
                  Center(
                    child: Text(
                      "Sin actividades de " + widget.tipoRuleta,
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
              return horientacion == Orientation.portrait
                  ? Container(
                      child: ListView(
                        shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                        children: <Widget>[
                          Center(
                              child: btnActividades(
                            tipoRuleta: widget.tipoRuleta,
                          )),
                          SizedBox(
                            height: 20,
                          ),
                          Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              BoardView(
                                items: items,
                                current: _current,
                                angle: _angle,
                              ),
                              _buildGo(),
                            ],
                          ),
                          btnLista(
                            tipoRuleta: widget.tipoRuleta,
                          ),
                          SizedBox(
                            height: 85,
                          ),
                          _buildResult(_value)
                        ],
                      ),
                    )
                  : (width < 400)
                      ? Container(
                          child: ListView(
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            children: <Widget>[
                              btnActividades(
                                tipoRuleta: widget.tipoRuleta,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  BoardView(
                                    items: items,
                                    current: _current,
                                    angle: _angle,
                                  ),
                                  _buildGo(),
                                ],
                              ),
                              btnLista(
                                tipoRuleta: widget.tipoRuleta,
                              ),
                              SizedBox(
                                height: 85,
                              ),
                              _buildResult(_value)
                            ],
                          ),
                        )
                      : ListView(
                          physics: BouncingScrollPhysics(),
                          shrinkWrap: true,
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 10),
                              alignment: Alignment.center,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: <Widget>[
                                      BoardView(
                                        items: items,
                                        current: _current,
                                        angle: _angle,
                                      ),
                                      _buildGo(),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildResult(_value),
                                      btnLista(
                                        tipoRuleta: widget.tipoRuleta,
                                      ),
                                      btnActividades(
                                        tipoRuleta: widget.tipoRuleta,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
            }
          },
        ),
      ),
    );
  }

  _buildGo() {
    return Material(
      color: Colors.white,
      shape: CircleBorder(),
      child: InkWell(
        customBorder: CircleBorder(),
        child: Container(
          alignment: Alignment.center,
          height: 72,
          width: 72,
          child: Text(
            "GO",
            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
          ),
        ),
        onTap: _animation,
      ),
    );
  }

  _animation() {
    if (!_ctrl.isAnimating) {
      var _random = Random().nextDouble();
      _angle = 20 + Random().nextInt(5) + _random;
      _ctrl.forward(from: 0.0).then((_) {
        _current = (_current + _random);
        _current = _current - _current ~/ 1;
        _ctrl.reset();
      });
    }
  }

  int _calIndex(value) {
    var _base = (2 * pi / items.length / 2) / (2 * pi);
    return (((_base + value) % 1) * items.length).floor();
  }

  _buildResult(_value) {
    final horientacion = MediaQuery.of(context).orientation;
    var index = _calIndex(_value * _angle + _current);
    String descripcion = items[index].descripcion;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: horientacion == Orientation.portrait
            ? 500
            : MediaQuery.of(context).size.width / 2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
        ),
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              Container(
                height: 50,
                child: Text(
                  descripcion,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                child: TextButton(
                  onPressed: () async {
                    Actividad actividadProceso;
                    await FirebaseFirestore.instance
                        .collection("actividades")
                        .where('estado', isEqualTo: 'en proceso')
                        .where('tipo', isEqualTo: widget.tipoRuleta)
                        .get()
                        .then(
                          (value) async => {
                            if (value.docs.length != 0)
                              {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('¡Aviso!'),
                                      content: Text(
                                          "Ya hay una actividad en proceso"),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: Text('Vale'),
                                        )
                                      ],
                                    );
                                  },
                                ),
                              }
                            else
                              {
                                actividadProceso = items[index],
                                await FirebaseFirestore.instance
                                    .collection('actividades')
                                    .doc(items[index].id)
                                    .update({
                                  'estado': "en proceso",
                                }).then(
                                  (value) => {
                                    print("actividad en proceso"),
                                    print("Solicitud a firebase"),
                                    items.remove(actividadProceso),
                                    setState(() {}),
                                  },
                                ),
                              }
                          },
                        );
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
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
                      "Comenzar actividad",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    height: 50,
                    width: 200,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
