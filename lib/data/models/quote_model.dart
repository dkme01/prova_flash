// ignore_for_file: non_constant_identifier_names

class QuoteModel {
  final double cotacaoCompra;
  final double cotacaoVenda;
  final String dataHoraCotacao;
  bool selecionado;

  QuoteModel({
    required this.cotacaoCompra,
    required this.cotacaoVenda,
    required this.dataHoraCotacao,
    required this.selecionado,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> map) => QuoteModel(
        cotacaoCompra: map['cotacaoCompra'] * 1.0,
        cotacaoVenda: map['cotacaoVenda'] * 1.0,
        dataHoraCotacao: map['dataHoraCotacao'],
        selecionado: false,
      );

  Map<String, dynamic> toJson() => {
        "cotacaoCompra": cotacaoCompra,
        "cotacaoVenda": cotacaoVenda,
        "dataHoraCotacao": dataHoraCotacao,
        "selecionado": selecionado,
      };
}
