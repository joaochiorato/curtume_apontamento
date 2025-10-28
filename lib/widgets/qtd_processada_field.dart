import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QtdProcessadaField extends StatelessWidget {
  final TextEditingController controller;
  final bool obrigatorio;
  const QtdProcessadaField({super.key, required this.controller, this.obrigatorio = true});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: const InputDecoration(
        labelText: 'QTD PROCESSADA',
        suffixText: 'pçs',
      ),
      validator: (txt) {
        if (!obrigatorio && (txt == null || txt.isEmpty)) return null;
        if (txt == null || txt.isEmpty) return 'Informe a quantidade';
        final n = int.tryParse(txt);
        if (n == null) return 'Valor inválido';
        if (n <= 0) return 'Quantidade deve ser maior que 0';
        return null;
      },
    );
  }
}
