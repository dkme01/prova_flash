import 'dart:convert';

import 'package:prova_flash/data/http/http_client.dart';
import 'package:prova_flash/data/models/quote_model.dart';

abstract class IQuoteRepository {
  Future<List<QuoteModel>> getQuotes(referenceDate);
}

class QuoteRepository implements IQuoteRepository {
  final IHttpClient client;

  QuoteRepository({required this.client});

  @override
  Future<List<QuoteModel>> getQuotes(referenceDate) async {
    final response = await client.get(
      url:
          "https://olinda.bcb.gov.br/olinda/servico/PTAX/versao/v1/odata/CotacaoDolarDia(dataCotacao=@dataCotacao)?@dataCotacao='$referenceDate'&\$top=100&\$format=json",
    );

    if (response.statusCode == 200) {
      final List<QuoteModel> quotes = [];

      final body = jsonDecode(response.body);

      body['value'].map((item) {
        final QuoteModel quote = QuoteModel.fromJson(item);
        quotes.add(quote);
      }).toList();

      return quotes;
    } else if (response.statusCode == 404) {
      throw Exception('A url informada não é válida');
    } else {
      throw Exception('Não foi possível carregar a cotação solicitada');
    }
  }
}
