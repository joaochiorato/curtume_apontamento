// 🎯 ENUM DE STATUS DA ORDEM DE PRODUÇÃO
// Estados possíveis conforme regra de negócio

enum StatusOrdem {
  aguardando('Aguardando', 'Ordem criada, aguardando início'),
  emProducao('Em Produção', 'Apontamento iniciado'),
  finalizado('Finalizado', 'Todos os apontamentos concluídos'),
  cancelado('Cancelado', 'Ordem cancelada');

  final String label;
  final String descricao;

  const StatusOrdem(this.label, this.descricao);

  // 🎨 Cor associada ao status (para uso visual discreto)
  String get textoStatus => label;
  
  // ✅ Valida se pode transitar para outro status
  bool podeTransitarPara(StatusOrdem novoStatus) {
    switch (this) {
      case StatusOrdem.aguardando:
        // De Aguardando -> pode ir para Em Produção ou Cancelado
        return novoStatus == StatusOrdem.emProducao || 
               novoStatus == StatusOrdem.cancelado;
      
      case StatusOrdem.emProducao:
        // De Em Produção -> pode ir para Finalizado ou Cancelado
        return novoStatus == StatusOrdem.finalizado || 
               novoStatus == StatusOrdem.cancelado;
      
      case StatusOrdem.finalizado:
        // De Finalizado -> não pode mais mudar
        return false;
      
      case StatusOrdem.cancelado:
        // De Cancelado -> não pode mais mudar
        return false;
    }
  }

  // 📊 Retorna o próximo status na sequência normal
  StatusOrdem? get proximoStatus {
    switch (this) {
      case StatusOrdem.aguardando:
        return StatusOrdem.emProducao;
      case StatusOrdem.emProducao:
        return StatusOrdem.finalizado;
      case StatusOrdem.finalizado:
      case StatusOrdem.cancelado:
        return null; // Estados finais
    }
  }

  // 🔄 Converte string para enum
  static StatusOrdem fromString(String status) {
    switch (status.toLowerCase()) {
      case 'aguardando':
        return StatusOrdem.aguardando;
      case 'em produção':
      case 'em producao':
        return StatusOrdem.emProducao;
      case 'finalizado':
        return StatusOrdem.finalizado;
      case 'cancelado':
        return StatusOrdem.cancelado;
      default:
        return StatusOrdem.aguardando;
    }
  }
}

// 📋 REGRAS DE NEGÓCIO DO STATUS

/*
┌─────────────────────────────────────────────────────────────────────┐
│                    FLUXO DE STATUS DA ORDEM                         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  1. AGUARDANDO                                                       │
│     ├─ Estado inicial ao criar a ordem                              │
│     ├─ Nenhum apontamento foi iniciado                              │
│     └─> Transita para "Em Produção" ao iniciar primeiro apontamento │
│                                                                       │
│  2. EM PRODUÇÃO                                                      │
│     ├─ Pelo menos um apontamento foi iniciado                       │
│     ├─ Processo está em andamento                                   │
│     └─> Transita para "Finalizado" ao concluir todos apontamentos   │
│                                                                       │
│  3. FINALIZADO                                                       │
│     ├─ Todos os apontamentos foram concluídos                       │
│     ├─ Estado final (não permite mais alterações)                   │
│     └─> Não pode mais transitar                                     │
│                                                                       │
│  4. CANCELADO (opcional)                                             │
│     ├─ Ordem foi cancelada                                          │
│     ├─ Estado final (não permite mais alterações)                   │
│     └─> Não pode mais transitar                                     │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘

TRANSIÇÕES PERMITIDAS:
  Aguardando    → Em Produção ✅
  Aguardando    → Cancelado ✅
  Em Produção   → Finalizado ✅
  Em Produção   → Cancelado ✅
  Finalizado    → (nenhum) ❌
  Cancelado     → (nenhum) ❌

TRIGGER DE MUDANÇA DE STATUS:
  • Ao INICIAR o primeiro apontamento: Aguardando → Em Produção
  • Ao FINALIZAR todos os apontamentos: Em Produção → Finalizado
  • Se NENHUM apontamento for iniciado: mantém Aguardando
*/
