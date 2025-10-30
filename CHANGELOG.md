# 📋 CHANGELOG

## [2.0.0] - Outubro 2025

### 🎉 LANÇAMENTO VERSÃO 2.0 - Baseado no PDF Real

#### ✅ Bugs Corrigidos
- Corrigido SDK: `^3.9.0` → `'>=3.0.0 <4.0.0'`
- Corrigido theme.dart: `CardTheme` → `CardThemeData`
- Atualizado intl: `^0.19.0` → `^0.20.2`
- Resolvido conflito de versão do Dart SDK

#### ⭐ Recursos Novos
- **4 NOVOS ESTÁGIOS:**
  - ENXUGADEIRA (pressão + velocidades)
  - DIVISORA (navalhas + pesos)
  - REBAIXADEIRA (10 PLTs)
  - REFILA (pesos + refilador)

#### 📝 Campos Adicionados
- Campo "Responsável Superior" (em 4 estágios)
- Seleção de Máquina (1-6 dependendo do estágio)
- 10 campos PLT na Rebaixadeira
- Campo "Nome do Refilador" na Refila
- Campos de Peso (Bruto, Líquido, Diferença)
- Mais variáveis de controle por estágio

#### 📊 Baseado no PDF
- Todos os estágios seguem ORDEM_QUARTZO.pdf
- Variáveis com padrões reais (min/max)
- Nomenclatura idêntica ao documento
- Unidades de medida corretas

#### 🎨 Melhorias de Interface
- Indicadores visuais mais claros
- Formulários organizados por estágio
- Progresso visual (X de 6 estágios)
- Badges de conclusão

---

## [1.0.0] - Setembro 2025

### 🚀 Lançamento Inicial

#### Recursos
- 5 estágios básicos
- Formulários de apontamento
- Logo ATAK Sistemas
- Persistência em memória
- Interface limpa

#### Problemas Conhecidos
- SDK muito específico (^3.9.0)
- CardTheme deprecated
- intl desatualizado
- Faltando etapas do processo real

---

## Planos Futuros

### [3.0.0] - Em Planejamento
- [ ] Persistência permanente (SQLite)
- [ ] API REST
- [ ] Exportar PDF
- [ ] Dashboard
- [ ] Autenticação
- [ ] Modo offline
