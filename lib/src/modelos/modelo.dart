import 'package:firebase_database/firebase_database.dart';

class Actividad {
  String id;
  int numero;
  String descripcion;
  int color;
  String tipo;
  String estado;

  Actividad({
    this.id,
    this.numero,
    this.descripcion,
    this.color,
    this.tipo,
    this.estado,
  });

  Actividad.map(dynamic obj) {
    this.descripcion = obj['descripcion'];
    this.tipo = obj['tipo'];
    this.estado = obj['estado'];
    this.numero = obj['numero'];
    this.color = obj['color'];
  }

  Actividad.fromSnapshot(DataSnapshot snapshot) {
    id = snapshot.key;
    descripcion = snapshot.value['descripcion'];
    tipo = snapshot.value['tipo'];
    estado = snapshot.value['estado'];
    numero = snapshot.value['numero'];
    color = snapshot.value['color'];
  }

  factory Actividad.fromJSON(Map<String, dynamic> map) {
    return Actividad(
      id: map['id'],
      numero: map['numero'],
      descripcion: map['descripcion'],
      color: map['color'],
      tipo: map['tipo'],
      estado: map['estado'],
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      "id": id,
      "numero": numero,
      "descripcion": descripcion,
      "color": color,
      "tipo": tipo,
      "estado": estado,
    };
  }
}
