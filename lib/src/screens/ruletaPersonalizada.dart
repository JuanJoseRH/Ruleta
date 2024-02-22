import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ruletafirebase/src/modelos/modelo.dart';
import 'package:ruletafirebase/src/widgets/board_view.dart';

class RuletaPersonalizada extends StatefulWidget {
  RuletaPersonalizada({Key key}) : super(key: key);

  @override
  _RuletaPersonalizadaState createState() => _RuletaPersonalizadaState();
}

class _RuletaPersonalizadaState extends State<RuletaPersonalizada>
    with SingleTickerProviderStateMixin {
  double _angle = 0;
  double _current = 0;
  AnimationController _ctrl;
  Animation _ani;

  List<Actividad> _items = [];
  List actividades = [];

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
        .where('tipo', isEqualTo: "Personalizada")
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
          _items.add(
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
    final horientacion = MediaQuery.of(context).orientation;

    FloatingActionButton btnAgregar = FloatingActionButton(
      backgroundColor: Colors.transparent,
      elevation: 0,
      onPressed: () {
        Navigator.pushNamed(
          context,
          '/agregarActividad',
          arguments: {'tipo': 'Personalizada'},
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

    Container btnLista = Container(
      margin: EdgeInsets.symmetric(horizontal: 160),
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/verLista',
            arguments: {'tipo': 'Personalizada'},
          );
        },
        child: Text(
          "Ver lista",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );

    TextButton btnActividades = TextButton(
      onPressed: () {
        Navigator.pushNamed(
          context,
          '/verActividades',
          arguments: {'tipo': 'Personalizada'},
        );
      },
      child: Row(
        children: [
          Icon(
            Icons.list,
            color: Colors.white,
          ),
          SizedBox(width: 10),
          Text(
            "Ver actividades",
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );

    TextButton btnBorrar = TextButton(
      onPressed: () async {
        List<QueryDocumentSnapshot> ac = [];
        await FirebaseFirestore.instance
            .collection('actividades')
            .where('tipo', isEqualTo: 'Personalizada')
            .get()
            .then(
              (value) => {
                ac = value.docs,
              },
            );
        if (ac.isEmpty) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Ruleta personalizada'),
                content: Text("No hay datos en la ruleta personalizada"),
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
            content: Text("¿Desea borrar la ruleta?"),
            textOK: Text("Si"),
            textCancel: Text("No"),
          )) {
            return setState(() async {
              _items.clear();
              for (var i = 0; i < ac.length; i++) {
                FirebaseFirestore.instance
                    .collection('actividades')
                    .doc(ac.elementAt(i).id)
                    .delete();
              }
              setState(() {});
            });
          }
        }
      },
      child: Icon(
        Icons.delete,
        color: Colors.white,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Ruleta personalizada"),
        backgroundColor: Color(0xFF102E89),
        actions: [
          btnBorrar,
        ],
      ),
      floatingActionButton: btnAgregar,
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
        child: AnimatedBuilder(
          animation: _ani,
          builder: (context, child) {
            final _value = _ani.value;
            final _angle = _value * this._angle;
            if (_items == null || _items.length == 0) {
              return Center(
                child: Text(
                  "Sin actividades personalizadas",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              );
            } else {
              return horientacion == Orientation.portrait
                  ? ListView(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 100),
                          padding: const EdgeInsets.only(left: 30),
                          child: btnActividades,
                        ),
                        SizedBox(
                          height: 60,
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            BoardView(
                              items: _items,
                              current: _current,
                              angle: _angle,
                            ),
                            _buildGo(),
                          ],
                        ),
                        btnLista,
                        SizedBox(
                          height: 85,
                        ),
                        _buildResult(_value)
                      ],
                    )
                  : Container(
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 10),
                            child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                BoardView(
                                  items: _items,
                                  current: _current,
                                  angle: _angle,
                                ),
                                _buildGo(),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              _buildResult(_value),
                              btnLista,
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 100),
                                padding: const EdgeInsets.only(left: 30),
                                child: btnActividades,
                              ),
                            ],
                          ),
                        ],
                      ),
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
    var _base = (2 * pi / _items.length / 2) / (2 * pi);
    return (((_base + value) % 1) * _items.length).floor();
  }

  _buildResult(_value) {
    final horientacion = MediaQuery.of(context).orientation;
    var index = _calIndex(_value * _angle + _current);
    String descripcion = _items[index].descripcion;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Container(
            width: horientacion == Orientation.portrait
                ? 500
                : MediaQuery.of(context).size.width - 450,
            height: 163,
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
                  SizedBox(height: 50),
                  Container(
                    child: TextButton(
                      onPressed: () {
                        Actividad a = _items[index];
                        FirebaseFirestore.instance
                            .collection('actividades')
                            .doc(a.id)
                            .delete();
                        _items.remove(a);
                        setState(() {});
                      },
                      child: Container(
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
                            "Seleccionar",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    height: 50,
                    width: 200,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
