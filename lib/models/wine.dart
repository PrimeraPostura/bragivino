class Wine {
  final String id;
  final String nombre;
  final String bodega;
  final List<String> variedadUva;
  final int anioCosecha;
  final String notaCata;
  final double valoracion;
  final String region;

  Wine({
    required this.id,
    required this.nombre,
    required this.bodega,
    required this.variedadUva,
    required this.anioCosecha,
    required this.notaCata,
    required this.valoracion,
    required this.region,
  });

  // Convierte un objeto Wine a un Map para almacenar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'bodega': bodega,
      'variedad_uva': variedadUva,
      'año_cosecha': anioCosecha,
      'nota_cata': notaCata,
      'valoracion': valoracion,
      'region': region,
    };
  }

  // Convierte un Map de Firestore a un objeto Wine
  factory Wine.fromMap(String id, Map<String, dynamic> map) {
    return Wine(
      id: id,
      nombre: map['nombre'],
      bodega: map['bodega'],
      variedadUva: List<String>.from(map['variedad_uva']),
      anioCosecha: map['año_cosecha'],
      notaCata: map['nota_cata'],
      valoracion: map['valoracion'],
      region: map['region'],
    );
  }
}
