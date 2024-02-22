class DetalleActividad {
  String id;
  String idActividad;
  int calificacion;
  String foto;

  DetalleActividad({this.id, this.idActividad, this.calificacion, this.foto});

  factory DetalleActividad.fromJSON(Map<String, dynamic> map) {
    return DetalleActividad(
      id: map['id'],
      idActividad: map['idActividad'],
      calificacion: map['calificacion'],
      foto: map['foto'],
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      "id": id,
      "idActividad": idActividad,
      "calificacion": calificacion,
      "foto": foto,
    };
  }
}
