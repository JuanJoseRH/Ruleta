import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ruletafirebase/src/modelos/modelo.dart';

import 'arrow_view.dart';

class BoardView extends StatefulWidget {
  final double angle;
  final double current;
  final List<Actividad> items;

  const BoardView({Key key, this.angle, this.current, this.items})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _BoardViewState();
  }
}

class _BoardViewState extends State<BoardView> {
  Size get size => Size(
        (MediaQuery.of(context).orientation == Orientation.portrait)
            ? MediaQuery.of(context).size.width * 0.8
            : (MediaQuery.of(context).size.width < 400)
                ? MediaQuery.of(context).size.width * 0.6
                : MediaQuery.of(context).size.width * 0.3,
        (MediaQuery.of(context).orientation == Orientation.portrait)
            ? MediaQuery.of(context).size.width * 0.8
            : (MediaQuery.of(context).size.width < 400)
                ? MediaQuery.of(context).size.width * 0.6
                : MediaQuery.of(context).size.width * 0.3,
      );

  double _rotote(int index) => (index / widget.items.length) * 2 * pi;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        //shadow
        Container(
          height: size.height,
          width: size.width,
          decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
            BoxShadow(blurRadius: 20, color: Colors.black38),
          ]),
        ),
        Transform.rotate(
          angle: -(widget.current + widget.angle) * 2 * pi,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              for (var luck in widget.items) ...[_buildCard(luck)],
              for (var luck in widget.items) ...[_buildImage(luck)],
            ],
          ),
        ),
        Container(
          height: size.height,
          width: size.width,
          child: ArrowView(),
        ),
      ],
    );
  }

  _buildCard(Actividad luck) {
    var _angle;
    var _rotate = _rotote(widget.items.indexOf(luck));
    if (widget.items.length != 1)
      _angle = 2 * pi / widget.items.length;
    else
      _angle = 6.28315969;
    return Transform.rotate(
      angle: _rotate,
      child: ClipPath(
        clipper: _LuckPath(_angle),
        child: Container(
          height: size.height,
          width: size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(luck.color),
                Color(luck.color).withOpacity(0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildImage(Actividad luck) {
    var _rotate = _rotote(widget.items.indexOf(luck));
    return Transform.rotate(
      angle: _rotate,
      child: Container(
        height: size.height,
        width: size.width,
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints:
              BoxConstraints.expand(height: size.height / 3, width: 44),
          child: Center(
            child: Container(
              width: 25,
              child: Text(
                luck.numero.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LuckPath extends CustomClipper<Path> {
  final double angle;

  _LuckPath(this.angle);

  @override
  Path getClip(Size size) {
    Path _path = Path();
    Offset _center = size.center(Offset.zero);
    Rect _rect = Rect.fromCircle(center: _center, radius: size.width / 2);
    _path.moveTo(_center.dx, _center.dy);
    _path.arcTo(_rect, -pi / 2 - angle / 2, angle, false);
    _path.close();
    return _path;
  }

  @override
  bool shouldReclip(_LuckPath oldClipper) {
    return angle != oldClipper.angle;
  }
}
