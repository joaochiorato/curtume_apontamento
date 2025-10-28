PATCH REMOLHO — Observação logo após QTD Processada
======================================================
- O campo "Observação" foi movido para logo abaixo da QTD Processada (pcs).
- Fluxo visual: Responsável → Responsável Superior → QTD Processada → Observação → Variáveis.
- Mantém: numpad customizado, início/término automáticos, validações e contador.

Aplicar:
1) Backup de lib/widgets/stage_form.dart
2) Substitua pelo arquivo deste patch
3) flutter clean && flutter pub get && flutter run
