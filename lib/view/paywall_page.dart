import 'package:flutter/material.dart';
import '../services/publicacion_service.dart';

class PaywallPage extends StatefulWidget {
  final String idPublicacion;
  final String nombreMascota;

  const PaywallPage({
    super.key,
    required this.idPublicacion,
    required this.nombreMascota,
  });

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  bool _procesando = false;
  static const Color turquesa = Color(0xFF20A39E);
  static const Color fondo = Color(0xFFF7F9F6);
  static const Color coral = Color(0xFFFF7A59);

  Future<void> _simularPago() async {
    if (_procesando) return;
    setState(() => _procesando = true);
    try {
      await PublicacionService().activarPremiumSimulado(widget.idPublicacion);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Premium activado por 7 días.')),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo activar Premium: $error')),
      );
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  Widget _beneficio(String texto, {bool premium = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(Icons.check_circle, color: premium ? turquesa : Colors.green, size: 19),
      const SizedBox(width: 8),
      Expanded(child: Text(texto, style: const TextStyle(fontSize: 13))),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        title: const Text('Destacá tu publicación'),
        backgroundColor: turquesa,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(child: ListView(padding: const EdgeInsets.all(18), children: [
        const Icon(Icons.campaign_rounded, size: 54, color: turquesa),
        const SizedBox(height: 10),
        const Text('¡Dale más visibilidad!', textAlign: TextAlign.center,
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Color(0xFF444444))),
        const SizedBox(height: 6),
        Text('Tu publicación de ${widget.nombreMascota.isEmpty ? 'tu mascota' : widget.nombreMascota} puede llegar a más personas.',
          textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 22),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Card(color: Colors.white, child: Padding(padding: const EdgeInsets.all(13), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('FREE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            const Text('\$0', style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold)),
            const Text('Siempre gratuito', style: TextStyle(color: Colors.black54, fontSize: 11)),
            const Divider(height: 22),
            _beneficio('Publicación normal'),
            _beneficio('Fotos y descripción'),
            _beneficio('Aparece en listados y mapa'),
            _beneficio('La publicación permanece visible'),
          ])))),
          const SizedBox(width: 9),
          Expanded(child: Card(shape: RoundedRectangleBorder(side: const BorderSide(color: turquesa, width: 2), borderRadius: BorderRadius.circular(12)), color: Colors.white, child: Padding(padding: const EdgeInsets.all(13), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('PREMIUM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: turquesa)),
            const Text('\$99', style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: turquesa)),
            const Text('UYU · 7 días', style: TextStyle(color: Colors.black54, fontSize: 11)),
            const Divider(height: 22),
            _beneficio('Todo lo incluido en Free', premium: true),
            _beneficio('Prioridad en los listados', premium: true),
            _beneficio('Distintivo Premium', premium: true),
            _beneficio('Marcador destacado en mapa', premium: true),
            _beneficio('Chat privado y avisos de mensajes', premium: true),
          ])))),
        ]),
        const SizedBox(height: 18),
        SizedBox(height: 52, child: ElevatedButton.icon(
          onPressed: _procesando ? null : _simularPago,
          style: ElevatedButton.styleFrom(backgroundColor: coral, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          icon: _procesando ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.star),
          label: Text(_procesando ? 'Activando...' : 'Activar Premium · \$99'),
        )),
        TextButton(onPressed: _procesando ? null : () => Navigator.of(context).pop(false), child: const Text('Continuar con el plan gratuito')),
        const SizedBox(height: 6),
        const Text('Al terminar los 7 días, la publicación vuelve a Free y permanece visible.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.black54)),
      ])),
    );
  }
}
